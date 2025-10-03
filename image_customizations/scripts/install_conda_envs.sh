#!/bin/bash

# This scripts looks for .yml files in a given directory and creates corresponding conda environments
# It takes 2 positional arguments
# The first argument should be a valid directory path, containing Conda environment definition (.yml) files
# The second argument should be path to Conda executable
# No validation is done on the .yml files and it is left to Conda
# .yaml / .YML / .YAML extensions are NOT supported, be sure to use .yml only!

env_def_dir=$1  # arg1: The directory to search for conda env definition
conda_exec=$2   # arg2: Path to conda executable
pattern="*.yml" # Only look for .yml files

# Check if the env_def_dir is not a directory
if [ ! -d "$env_def_dir" ]; then
  echo "ERROR: First argument must be a valid directory"
  exit 1
fi

# Check if a valid Conda executable is not a valid file
if [ ! -f "$conda_exec" ]; then 
  echo "ERROR: Second argument must be a valid conda executable path"
  exit 1
fi

# Loop through yml files in the search directory
for file_path in "$env_def_dir"/$pattern; do
  if [ -f "$file_path" ]; then
    $conda_exec env create -f "$file_path"
  fi
done

exit 0
