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

# Call the Python script to get the download URL and capture only the first line
DOWNLOAD_URL=$(python3 scihub.py "$ARTICLE_URL" | head -n 1)

# Check if DOWNLOAD_URL was retrieved
if [ -z "$DOWNLOAD_URL" ]; then
    echo "Failed to retrieve download URL."
    exit 1
fi

# Remove the fragment identifier (if any) from the URL
CLEANED_URL=$(echo "$DOWNLOAD_URL" | sed 's/#.*//')

# Debugging: Print the cleaned URL
echo "Cleaned URL: $CLEANED_URL"

# Extract the filename from the cleaned URL
FILENAME=$(basename "$CLEANED_URL")

# Download the file using wget, with --no-check-certificate in case of certificate issues
wget --no-check-certificate -O "$DOWNLOAD_DIR/$FILENAME" "$CLEANED_URL"

if [ $? -eq 0 ]; then
    echo "File downloaded successfully to $DOWNLOAD_DIR/$FILENAME."
else
    echo "Failed to download the file."
    exit 1
fi
