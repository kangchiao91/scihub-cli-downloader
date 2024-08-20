#!/bin/bash

# Step 1: Find the absolute path of the script
SCRIPT_NAME="download_from_scihub.sh"
SCRIPT_PATH=$(realpath "$SCRIPT_NAME")

# Check if the script exists in the current directory
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: $SCRIPT_NAME not found in the current directory."
    exit 1
fi

echo "Script found at: $SCRIPT_PATH"

# Step 2: Extract the directory from the script's path
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

# Step 3: Add the script's directory to the PATH if not already present
if [[ ":$PATH:" != *":$SCRIPT_DIR:"* ]]; then
    echo "Adding $SCRIPT_DIR to PATH..."
    echo "export PATH=\"$PATH:$SCRIPT_DIR\"" >> ~/.bashrc
    source ~/.bashrc
    echo "$SCRIPT_DIR has been added to your PATH."
else
    echo "$SCRIPT_DIR is already in your PATH."
fi

# Step 4: Create an alias for easy access
ALIAS_NAME="scihubdown"
ALIAS_COMMAND="alias $ALIAS_NAME='$SCRIPT_NAME'"

# Check if the alias already exists
if ! grep -q "$ALIAS_COMMAND" ~/.bashrc; then
    echo "Creating alias '$ALIAS_NAME'..."
    echo "$ALIAS_COMMAND" >> ~/.bashrc
    source ~/.bashrc
    echo "Alias '$ALIAS_NAME' has been created."
else
    echo "Alias '$ALIAS_NAME' already exists."
fi

echo "Setup complete! You can now use the command '$ALIAS_NAME' to run the script."
