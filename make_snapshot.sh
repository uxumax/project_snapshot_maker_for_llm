#!/bin/bash

#| Description:
#| This script takes a snapshot of a project directory, capturing the directory structure and file contents based on specified inclusion and exclusion patterns. It outputs the project's structure and the content of included files into a markdown file.
#| Usage:
#| ./script_name.sh <PROJECT_DIR> <OUTPUT_FILE> <INCLUDING_PATTERNS> <EXCLUDING_PATTERNS>
#|  <PROJECT_DIR>          - The path to the project directory. Example: "./Etherscan/"
#|  <OUTPUT_FILE>          - The name for the output markdown file. Example: "project_snapshot.md"
#|  <INCLUDING_PATTERNS>   - Inclusion patterns: List of file extensions to include, separated by spaces. Example: "*.sol *.json"
#|  <EXCLUDING_PATTERNS>   - Exception patterns: List of file extensions or parts of names to exclude, separated by spaces. Example: "*.log ."
#| Options:
#|  --help, -h             - Display this help message and exit.

if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    grep '^#|' "$0" | sed 's/^#//'
    exit 0
fi

# Project directory path
PROJECT_DIR=$1  # ex. "./Etherscan/"
# Output file name
OUTPUT_FILE=$2  # ex. "project_snapshot.md"
# Inclusion patterns: list of extensions separated by spaces
INCLUDING_PATTERNS=$3  # ex. "*.sol *.json"
# Exception patterns: list of extensions or name parts separated by spaces
EXCLUDING_PATTERNS=$4  # "*.log Proxy"

check_utility() {
    if ! command -v $1 &> /dev/null
    then
        echo "The $1 utility was not found."
        exit 1
    fi
}

# Function for adding file content
add_file_content() {
    echo -e "\n### $1\n" >> "$OUTPUT_FILE"
    echo '```solidity' >> "$OUTPUT_FILE"
    cat "$1" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# Function for generating a string with parameters for the tree command
build_tree_pattern() {
    local include_pattern="" 
    for ext in $INCLUDING_PATTERNS; do
        if [ -z "$include_pattern" ]; then
            include_pattern="$ext" # For the first extension
        else
            include_pattern="$include_pattern|$ext" # Adding other extensions
        fi
    done
    local exclude_pattern="$EXCLUDING_PATTERNS"
    echo "$include_pattern" "$exclude_pattern"
}

build_find_pattern() {
    local find_args="" 
    for ext in $INCLUDING_PATTERNS; do
        find_args="$find_args -name \"$ext\" -o"
    done
    # Removing the last operator -o
    find_args="${find_args% -o}"
    for ext in $EXCLUDING_PATTERNS; do
        find_args="$find_args ! -name \"$ext\""
    done
    echo "$find_args" 
}

check_utility tree
check_utility find
> $OUTPUT_FILE

# Generating directory tree and saving the result to a file
echo "## Full project tree" >> "$OUTPUT_FILE"
read pattern exclude_pattern <<<$(build_tree_pattern)
tree "$PROJECT_DIR" -P "$pattern" -I "$exclude_pattern" --prune >> "$OUTPUT_FILE"

# Save all text to one file snapshot
echo "## All files code"  >> "$OUTPUT_FILE"
find_args=$(build_find_pattern)
# Use find with -print0 to output filenames separated by a null character, 
# ensuring accurate handling of filenames with special characters (including spaces).
eval find "$PROJECT_DIR" -type f "\( $find_args \)" -print0 |
while IFS= read -r -d $'\0' file; do
    add_file_content "$file"
done

echo "Project snapshot saved $OUTPUT_FILE"
