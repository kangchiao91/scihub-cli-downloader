#!/bin/bash

# Default download directory
DOWNLOAD_DIR="$HOME/Downloads"
RENAME_FILE=false

# Parse arguments
while getopts u:d:m:r flag
do
    case "${flag}" in
        u) ARTICLE_URL=${OPTARG};;
        d) DOWNLOAD_DIR=${OPTARG};;
        r) RENAME_FILE=true;;
    esac
done

# Ensure ARTICLE_URL is set
if [ -z "$ARTICLE_URL" ]; then
    echo "Usage: $0 -u <article_url> [-d <download_directory>] [-r to rename file based on title]"
    exit 1
fi

# Determine the absolute path of this script's directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Call the Python script using its absolute path to get the download URL and title
SCRIPT_OUTPUT=$(python3 "$SCRIPT_DIR/scihub.py" "$ARTICLE_URL")

# Separate the URL and title from the script output
DOWNLOAD_URL=$(echo "$SCRIPT_OUTPUT" | head -n 1 | xargs)
TITLE=$(echo "$SCRIPT_OUTPUT" | tail -n 1 | xargs)

# Check if DOWNLOAD_URL is valid
if [[ -z "$DOWNLOAD_URL" || "$DOWNLOAD_URL" != http* ]]; then
    echo "Failed to retrieve a valid download URL."
    exit 1
fi

# Extract the filename from the cleaned URL, removing the fragment part (if any)
FILENAME=$(basename "$DOWNLOAD_URL" | sed 's/#.*//')

# Optionally rename the file based on the title
if [ "$RENAME_FILE" = true ] && [ -n "$TITLE" ]; then
    FILENAME="$TITLE.pdf"
fi

# Debugging: Print the cleaned URL and filename
echo "Cleaned URL: $DOWNLOAD_URL"
echo "Filename: $FILENAME"

# Download the file using wget, with --no-check-certificate in case of certificate issues
wget --no-check-certificate -O "$DOWNLOAD_DIR/$FILENAME" "$DOWNLOAD_URL"

if [ $? -eq 0 ]; then
    echo "File downloaded successfully to $DOWNLOAD_DIR/$FILENAME."
else
    echo "Failed to download the file."
    exit 1
fi
