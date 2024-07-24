#!/bin/bash

#TODO: Decide whether or not to use snap packages or not
#TODO: Add in neovim to the apps, make sure it's version 0.10.0
#TODO: Add in postman or fix
#TODO: Move success and failed messages to the end of the run of this script, so user can see what failed.

# For configuring git
read -p "Enter your git name: " git_name
read -p "Enter your git email: " git_email

# Initialize status messages
status_messages=()

# Arrays for packages to install
snap_packages=("postman" "nvim --classic")
flatpak_packages=("com.getpostman.Postman" "io.neovim.nvim")

# Function to install a package if it's not already installed
install_if_not_installed() {
  if ! dpkg -s "$1" &>/dev/null; then
    if sudo apt-get install -y "$1"; then
      status_messages+=("$1 installation succeeded")
    else
      status_messages+=("$1 installation failed")
    fi
  else
    status_messages+=("$1 is already installed")
  fi
}

# Function to install packages using Snap
install_snap_packages() {
  for package in "${snap_packages[@]}"; do
    echo "Installing $package via Snap..."
    sudo snap install $package
    status_messages+=("$package installed via Snap.")
  done
}

# Function to install packages using Flatpak
install_flatpak_packages() {
  for package in "${flatpak_packages[@]}"; do
    echo "Installing $package via Flatpak..."
    flatpak install -y flathub $package
    status_messages+=("$package installed via Flatpak.")
  done
}

# Update and upgrade the system
if sudo apt-get update && sudo apt-get upgrade -y; then
  status_messages+=("System update and upgrade succeeded")
else
  status_messages+=("System update and upgrade failed")
fi

# Install necessary packages
packages=(
  curl
  unzip
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

# Check for Snap and Flatpak, install Flatpak if neither is installed
if ! command -v snap &>/dev/null; then
  if ! command -v flatpak &>/dev/null; then
    echo "Flatpak not found. Installing Flatpak..."
    sudo apt-get update && sudo apt-get install -y flatpak
    status_messages+=("Flatpak installed.")
  else
    status_messages+=("Flatpak already installed.")
  fi
else
  status_messages+=("Snap already installed.")
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
    status_messages+=("Oh My Zsh installation succeeded")
  else
    status_messages+=("Oh My Zsh installation failed")
  fi
else
  status_messages+=("Oh My Zsh is already installed")
fi

# Change default shell to zsh
if chsh -s "$(which zsh)"; then
  status_messages+=("Default shell changed to zsh successfully")
else
  status_messages+=("Failed to change default shell to zsh")
fi

# Reload .zshrc to apply fnm configuration in the current session
if source ~/.zshrc; then
  status_messages+=(".zshrc reloaded successfully")
else
  status_messages+=("Failed to reload .zshrc")
fi

# Install Postman and Neovim based on Snap or Flatpak availability
if command -v snap &>/dev/null; then
  install_snap_packages
elif command -v flatpak &>/dev/null; then
  install_flatpak_packages
else
  status_messages+=("Neither Snap nor Flatpak are installed. Postman and Neovim installation skipped.")
fi

# Install fnm (Node.js version manager)
if curl -fsSL https://fnm.vercel.app/install | bash; then
  status_messages+=("fnm installation succeeded")
else
  status_messages+=("fnm installation failed")
fi

# Add fnm initialization to .zshrc
if cat <<'EOF' >>~/.zshrc; then

# Initialize fnm
export PATH="$HOME/.fnm:$PATH"
eval "$(fnm env)"
EOF
  status_messages+=("Added fnm initialization to .zshrc")
else
  status_messages+=("Failed to add fnm initialization to .zshrc")
fi

# Reload .zshrc to apply fnm configuration in the current session
if source ~/.zshrc; then
  status_messages+=(".zshrc reloaded successfully")
else
  status_messages+=("Failed to reload .zshrc")
fi

# Set default Node.js version
if fnm install 20 && fnm default 20; then
  status_messages+=("Node.js installation and default setting succeeded")
else
  status_messages+=("Node.js installation and default setting failed")
fi

# Set default terminal to kitty
if sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty; then
  status_messages+=("Default terminal set to kitty successfully")
else
  status_messages+=("Failed to set default terminal to kitty")
fi

# Configure git
if git config --global user.name "$git_name" && git config --global user.email "$git_email"; then
  status_messages+=("Git configured successfully")
else
  status_messages+=("Failed to configure git")
fi

# Update tldr
if tldr --update; then
  status_messages+=("tldr updated successfully")
else
  status_messages+=("Failed to update tldr")
fi

# Download and install JetBrainsMono Nerd Font
font_dir="$HOME/.local/share/fonts"
if mkdir -p "$font_dir" && curl -fLo "$font_dir/JetBrainsMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip && unzip "$font_dir/JetBrainsMono.zip" -d "$font_dir" && fc-cache -fv; then
  status_messages+=("JetBrainsMono Nerd Font installed successfully")
else
  status_messages+=("Failed to install JetBrainsMono Nerd Font")
fi

# Add font configuration to kitty
kitty_config_dir="$HOME/.config/kitty"
if mkdir -p "$kitty_config_dir" && cat <<'EOF' >>"$kitty_config_dir/kitty.conf"; then
font_family JetBrainsMono Nerd Font
#mouse_map right press grabbed,ungrabbed no-op
#mouse_map right click grabbed,ungrabbed paste_from_clipboard
EOF
  status_messages+=("Added font configuration to kitty successfully")
else
  status_messages+=("Failed to add font configuration to kitty")
fi

# Install Postman
if sudo snap install postman; then
  status_messages+=("Postman installed successfully")
else
  status_messages+=("Failed to install Postman")
fi

# Download and install LazyVim from the adamdetki/nvim repository
if git clone https://github.com/adamdetki/nvim ~/.config/nvim; then
  status_messages+=("LazyVim installed successfully from adamdetki/nvim")
else
  status_messages+=("Failed to install LazyVim from adamdetki/nvim")
fi

# Display status messages
echo "---- Setup Summary ----"
for message in "${status_messages[@]}"; do
  echo "$message"
done

echo "Setup is complete! Please restart your terminal with 'source ~/.zshrc' to apply all changes."
