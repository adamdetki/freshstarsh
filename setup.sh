#!/bin/bash

# For configuring git
read -p "Enter your git name: " git_name
read -p "Enter your git email: " git_email

# Function to install a package if it's not already installed
install_if_not_installed() {
  if ! dpkg -s "$1" &>/dev/null; then
    if sudo apt-get install -y "$1"; then
      echo "$1 installation succeeded"
    else
      echo "$1 installation failed"
    fi
  else
    echo "$1 is already installed"
  fi
}

# Update and upgrade the system
if sudo apt-get update && sudo apt-get upgrade -y; then
  echo "System update and upgrade succeeded"
else
  echo "System update and upgrade failed"
fi

# Install necessary packages
packages=(
  curl
  git
  bat
  ripgrep
  fd-find
  fzf
  neofetch
  tldr
  gnome-tweaks
  taskwarrior
  vim
  neovim
  tmux
  lazygit
  docker.io
  kitty
  zsh
  build-essential
  libstdc++6
)

for package in "${packages[@]}"; do
  install_if_not_installed "$package"
done

# Install fnm (Node.js version manager)
if curl -fsSL https://fnm.vercel.app/install | bash; then
  echo "fnm installation succeeded"
else
  echo "fnm installation failed"
fi

# Add fnm initialization to .zshrc
if cat <<'EOF' >>~/.zshrc; then

# Initialize fnm
export PATH="$HOME/.fnm:$PATH"
eval "$(fnm env)"
EOF
  echo "Added fnm initialization to .zshrc"
else
  echo "Failed to add fnm initialization to .zshrc"
fi

# Reload .zshrc to apply fnm configuration in the current session
if source ~/.zshrc; then
  echo ".zshrc reloaded successfully"
else
  echo "Failed to reload .zshrc"
fi

# Set default Node.js version
if fnm install 20 && fnm default 20; then
  echo "Node.js installation and default setting succeeded"
else
  echo "Node.js installation and default setting failed"
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
    echo "Oh My Zsh installation succeeded"
  else
    echo "Oh My Zsh installation failed"
  fi
else
  echo "Oh My Zsh is already installed"
fi

# Change default shell to zsh
if chsh -s "$(which zsh)"; then
  echo "Default shell changed to zsh successfully"
else
  echo "Failed to change default shell to zsh"
fi

# Set default terminal to kitty
if sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty; then
  echo "Default terminal set to kitty successfully"
else
  echo "Failed to set default terminal to kitty"
fi

# Configure git
if git config --global user.name "$git_name" && git config --global user.email "$git_email"; then
  echo "Git configured successfully"
else
  echo "Failed to configure git"
fi

# Update tldr
if tldr --update; then
  echo "tldr updated successfully"
else
  echo "Failed to update tldr"
fi

# Download and install JetBrainsMono Nerd Font
font_dir="$HOME/.local/share/fonts"
if mkdir -p "$font_dir" && curl -fLo "$font_dir/JetBrainsMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip && unzip "$font_dir/JetBrainsMono.zip" -d "$font_dir" && fc-cache -fv; then
  echo "JetBrainsMono Nerd Font installed successfully"
else
  echo "Failed to install JetBrainsMono Nerd Font"
fi

# Add font configuration to kitty
kitty_config_dir="$HOME/.config/kitty"
if mkdir -p "$kitty_config_dir" && cat <<'EOF' >>"$kitty_config_dir/kitty.conf"; then
font_family JetBrainsMono Nerd Font
#mouse_map right press grabbed,ungrabbed no-op
#mouse_map right click grabbed,ungrabbed paste_from_clipboard
EOF
  echo "Added font configuration to kitty successfully"
else
  echo "Failed to add font configuration to kitty"
fi

# Install Postman
if sudo snap install postman; then
  echo "Postman installed successfully"
else
  echo "Failed to install Postman"
fi

# Download and install LazyVim from the adamdetki/nvim repository
if git clone https://github.com/adamdetki/nvim ~/.config/nvim; then
  echo "LazyVim installed successfully from adamdetki/nvim"
else
  echo "Failed to install LazyVim from adamdetki/nvim"
fi

echo "Setup is complete! Please restart your terminal with 'source ~/.zshrc' to apply all changes."
