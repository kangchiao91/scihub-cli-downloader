#!/bin/bash

# Default download directory
DOWNLOAD_DIR="$HOME/Downloads"

# Parse arguments
while getopts u:d:m: flag
do
    case "${flag}" in
        u) ARTICLE_URL=${OPTARG};;
        d) DOWNLOAD_DIR=${OPTARG};;
    esac
done

# Ensure ARTICLE_URL is set
if [ -z "$ARTICLE_URL" ]; then
    echo "Usage: $0 -u <article_url> [-d <download_directory>]"
    exit 1
fi

# Determine the absolute path of this script's directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Call the Python script using its absolute path to get the download URL
DOWNLOAD_URL=$(python3 "$SCRIPT_DIR/scihub.py" "$ARTICLE_URL")

# Clean the URL by removing any leading/trailing whitespace or invalid characters
CLEANED_URL=$(echo "$DOWNLOAD_URL" | head -n 1 | xargs)

# Check if CLEANED_URL is valid
if [[ -z "$CLEANED_URL" || "$CLEANED_URL" != http* ]]; then
    echo "Failed to retrieve a valid download URL."
    exit 1
fi

# Extract the filename from the cleaned URL, removing the fragment part (if any)
FILENAME=$(basename "$CLEANED_URL" | sed 's/#.*//')

# Debugging: Print the cleaned URL and filename
echo "Cleaned URL: $CLEANED_URL"
echo "Filename: $FILENAME"

# Download the file using wget, with --no-check-certificate in case of certificate issues
wget --no-check-certificate -O "$DOWNLOAD_DIR/$FILENAME" "$CLEANED_URL"

if [ $? -eq 0 ]; then
    echo "File downloaded successfully to $DOWNLOAD_DIR/$FILENAME."
else
    echo "Failed to download the file."
    exit 1
fi
