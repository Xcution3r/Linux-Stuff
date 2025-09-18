#!/bin/bash

# Define paths for Oh My Zsh and custom plugins/themes
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Clone useful Zsh plugins into the custom plugins directory
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"

# Download and install the Zeroastro Zsh theme
mkdir -p "$ZSH_CUSTOM/themes"
curl -fsSL https://github.com/zeroastro/zeroastro-zsh-theme/raw/master/zeroastro.zsh-theme \
  -o "$ZSH_CUSTOM/themes/zeroastro.zsh-theme"

# Update the theme in .zshrc file to use the newly installed theme
sed -i.bak 's/^[[:space:]]*ZSH_THEME=.*/ZSH_THEME="zeroastro"/' "$HOME/.zshrc"

# Show a message to remind the user to enable plugins
echo "Make sure to enable the plugins in your .zshrc file:"
echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)"

# Launch Zsh
exec zsh
