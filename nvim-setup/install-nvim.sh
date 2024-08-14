#!/bin/bash

set -ex

# Acquire sudo privileges
sudo -v

# Keep the sudo session alive until the script finishes
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Function to disable mouse support in nvim
disable_mouse_support() {
    nvim_config_dir="$HOME/.config/nvim"
    nvim_config_file="$nvim_config_dir/init.vim"

    # Ensure the config directory exists
    mkdir -p "$nvim_config_dir"

    # Disable mouse support by adding the setting to init.vim
    if ! grep -q "set mouse=" "$nvim_config_file"; then
        echo "Disabling mouse support in nvim..."
        echo "set mouse=" >> "$nvim_config_file"
        echo "Mouse support disabled in nvim."
    else
        echo "Mouse support is already disabled in nvim."
    fi
}

# Check if nvim is already in the PATH
if command -v nvim &> /dev/null; then
    echo "nvim is already in the PATH."
    disable_mouse_support
    exit 0
fi

# Detect the shell
if [ -n "$ZSH_VERSION" ]; then
    shell_rc="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    shell_rc="$HOME/.bashrc"
else
    echo "Unsupported shell. This script supports Bash and Zsh."
    exit 1
fi

# Detect if we are on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS. Installing nvim for macOS..."

    # Download and extract nvim for macOS
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz
    tar xzf nvim-macos-arm64.tar.gz

    # Move nvim to a directory in the PATH
    mkdir -p "$HOME/.local/bin"
    mv nvim-macos-arm64/bin/nvim "$HOME/.local/bin/"

    # Clean up
    rm -rf nvim-macos-arm64 nvim-macos-arm64.tar.gz

    # Update the PATH
    echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$shell_rc"
    echo "Neovim installed and PATH updated in $shell_rc."

else
    # Check for ARM64 architecture
    architecture=$(uname -m)
    if [ "$architecture" = "aarch64" ]; then
        echo "Detected ARM64 Linux. Installing nvim from source..."

        MISSING_PACKAGES=""
        
        # Ensure CMake is installed
        if ! command -v cmake &> /dev/null; then
            echo "CMake not found. Installing CMake..."
            MISSING_PACKAGES='cmake'
        fi

        # this is required for the build
        if ! command -v gettext &> /dev/null; then
            echo "Gettext not found. Installing Gettext..."
            MISSING_PACKAGES="$MISSING_PACKAGES gettext"
        fi

        # Check if there are any missing packages
        if [ -n "$MISSING_PACKAGES" ]; then
            echo "Installing missing packages: $MISSING_PACKAGES"
            sudo apt-get update
            sudo apt-get install -y $MISSING_PACKAGES
        else
            echo "All required packages are already installed."
        fi
        

        # Clone the Neovim repository and build from source
        git clone https://github.com/neovim/neovim.git
        cd neovim
        git checkout stable
        make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/opt
        sudo make install

        # Clean up
        cd ..
        
        echo "Now go into the build directory of neovim, install the executable where you want it"
        echo "The rest keeps having issues so you get to do it manually"

    else
        echo "Detected x64 Linux. Installing nvim for x64..."

        # Download and extract nvim for Linux
        curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
        sudo tar xzf nvim-linux64.tar.gz -C /opt

        # Clean up
        rm nvim-linux64.tar.gz
    fi

    # Update the PATH
    echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> "$shell_rc"
    echo "Neovim installed and PATH updated in $shell_rc."
fi

# After installation, disable mouse support in nvim
disable_mouse_support

echo "Installation complete. Please restart your terminal or source the file to apply changes."