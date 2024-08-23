#!/bin/bash

# Determine the shell configuration file to update
if [ -n "$ZSH_VERSION" ]; then
    SH_CONFIG_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SH_CONFIG_FILE="$HOME/.bashrc"
else
    echo "Unsupported shell. Only bash and zsh are supported."
    exit 1
fi

# Define unique script directory and alias names
SCIHUB_SCRIPT_DIR=$(dirname "$(realpath "$0")")
SCIHUB_ALIAS_NAME="scihubdown"
SCIHUB_ALIAS_COMMAND="alias $SCIHUB_ALIAS_NAME='$SCIHUB_SCRIPT_DIR/download_from_scihub.sh'"

# Add the script's directory to PATH if not already present
if ! grep -q "export PATH=.*$SCIHUB_SCRIPT_DIR" "$SH_CONFIG_FILE"; then
    echo "Adding $SCIHUB_SCRIPT_DIR to PATH in $SH_CONFIG_FILE..."
    echo "export PATH=\"\$PATH:$SCIHUB_SCRIPT_DIR\"" >> "$SH_CONFIG_FILE"
else
    echo "$SCIHUB_SCRIPT_DIR is already in PATH in $SH_CONFIG_FILE."
fi

# Add the alias for scihubdown if not already present
if ! grep -q "$SCIHUB_ALIAS_COMMAND" "$SH_CONFIG_FILE"; then
    echo "Adding alias '$SCIHUB_ALIAS_NAME' in $SH_CONFIG_FILE..."
    echo "$SCIHUB_ALIAS_COMMAND" >> "$SH_CONFIG_FILE"
else
    echo "Alias '$SCIHUB_ALIAS_NAME' is already configured in $SH_CONFIG_FILE."
fi

# Inform the user to reload their shell configuration
echo "Setup complete! Please run 'source $SH_CONFIG_FILE' or restart your terminal to apply the changes."
