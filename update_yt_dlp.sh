#!/bin/bash

# Check if pip is up-to-date
python -m pip install --upgrade pip &>/dev/null

# Install or upgrade yt-dlp to the latest version
latest_version=$(pip install --upgrade yt-dlp 2>&1)
echo "Latest yt-dlp version: $latest_version"

