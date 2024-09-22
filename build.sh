#!/bin/sh    
  
# This script deploys a Python package using Poetry.  
# It takes a package path as input and an optional output path.  
# If no output path is provided, packages will be deployed to $HOME/deployed_packages by default.  
  
# Help function to display script usage  
usage() {  
  echo "Usage: $0 <package_path> [output_path]"  
  echo "Deploy a Python package using Poetry."  
  echo ""  
  echo "Arguments:"  
  echo "  package_path   The path to the Python package you want to deploy"  
  echo "  output_path    Optional. The directory where you want the deployed package to be saved. If not provided, the script will use a default directory (\$HOME/deployed_packages)"  
  echo ""  
  echo "Example usage:"  
  echo "  $0 /path/to/your/package /path/to/output_directory"  
  echo "  $0 /path/to/your/package"  
  exit 1  
}  
  
# If no arguments were provided, display the usage information  
if [ $# -eq 0 ]; then  
  usage  
fi  
  
# If the first argument is -h or --help, display the usage information  
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then  
  usage  
fi  
  
# Check for input arguments    
if [ -z "$1" ]; then    
  echo "Error: No package path provided."  
  usage  
fi    
  
 
# Check for input arguments    
if [ -z "$1" ]; then    
  echo "Usage: $0 <package_path> [output_path]"    
  exit 1    
fi    
  
# Define input and output paths    
PACKAGE_PATH="$1"    
OUTPUT_PATH="${2:-$HOME/deployed_packages}"    
  
# Extract the package name from the path    
PACKAGE_NAME=$(basename "$PACKAGE_PATH")    
  
# Handle the case where PACKAGE_NAME is '.' or empty    
if [ "$PACKAGE_NAME" = "." ] || [ -z "$PACKAGE_NAME" ]; then    
  PACKAGE_NAME=$(basename "$(pwd)")    
fi    
  
# Define the package directory at the same level as the pyproject.toml file    
PACKAGE_DIR="$PACKAGE_PATH/package"    
  
# Define the zip file name and location    
ZIP_FILE="$PACKAGE_PATH/${PACKAGE_NAME}.zip"    
  
# Define the pyproject.toml file location    
PYPROJECT_FILE="$PACKAGE_PATH/pyproject.toml"    
  
# Replace '-' with '_' in PACKAGE_NAME    
INNER_PACKAGE_NAME=$(echo $PACKAGE_NAME | sed 's/-/_/g')    
  
# Define the inner source directory based on the INNER_PACKAGE_NAME    
INNER_SOURCE_DIR="$PACKAGE_PATH/$INNER_PACKAGE_NAME"    
  
# Check if pyproject.toml exists    
if [ ! -f "$PYPROJECT_FILE" ]; then    
  echo "pyproject.toml not found in $PACKAGE_PATH"    
  exit 1    
fi    
  
# Clean up any previous builds    
rm -f "$ZIP_FILE"    
rm -rf "$PACKAGE_DIR"    
  
# Create the package directory    
mkdir -p "$PACKAGE_DIR"  
  
# Set the Python keyring backend to null  
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring  
  
# Configure Poetry to create the virtual environment in the project's root directory  
poetry config virtualenvs.in-project true  
  
# Install the package and its dependencies into the 'package' directory    
# Ensure the command is run in the directory containing pyproject.toml    
(cd "$PACKAGE_PATH" && poetry install -v --no-root && poetry run pip install --upgrade -t package .)    
  
# Copy the source files from the inner source directory to the 'package' directory    
cp -r "$INNER_SOURCE_DIR"/* "$PACKAGE_DIR"  
  
# Create a zip file of the 'package' directory, excluding .pyc files    
(cd "$PACKAGE_DIR" && zip -r "../$PACKAGE_NAME.zip" . -x '*.pyc')    
  
# Ensure the output directory exists    
mkdir -p "$OUTPUT_PATH"    
  
# Move the new zip package to the output directory    
mv "$ZIP_FILE" "$OUTPUT_PATH"  
  
# Clean-up: Remove the virtual environment directory  
rm -rf "$PACKAGE_PATH/.venv"  
  
# Clean-up: Remove the 'package' directory  
rm -rf "$PACKAGE_DIR"  
  
# Clean-up: Remove the poetry.lock file  
rm "$PACKAGE_PATH"/poetry.lock  
    
echo "Package has been deployed to $OUTPUT_PATH"    
