#!/bin/bash

# This script treats each line of a given text file as a downloadable URL and tries to download them to a given destination directory
# It takes 2 positional arguments
# The first argument is a path to a valid text file where all the URLs are listed
# The second argument is a path to the destination download directory
# Each of the URLs must be a valid, public link to a downloadable file
# The distination directory is created if it doesn't already exists, files are overwritten

url_file_path=$1    # arg1: Path to a text file that has list of downloadable URL files
dest_dir=$2         # arg2: Path to destination download directory

# Validate first arg
if [ ! -f "$url_file_path" ]; then
    echo "WARNING: First argument must be a valid path to a text file containing list of downloadable file URLs"
    echo "Skipped downloading of any files"
    exit 0
fi

# Validate second arg
if [ ! "$dest_dir"]; then
    echo "ERROR: Second argument must be path to download destination directory. Directory will be created if it doesn't exists already."
    exit 1
fi

while IFS= read -r line || [[ -n "$line" ]]
do
    echo "$line"
    wget -N -P "$dest_dir" "$line"
done < "$url_file_path"

exit 0
