#!/bin/bash

# Initialize variables for options
project_dir=""
output_file=""
custom_excluding_patterns=""

# Define default exclusion patterns
default_excluding_patterns=(
    "*.jpg|*.gif|*.svg"
    "|*.mp3|*.oga"
    "|*.log|env"
    "|__pycache__|*.pyc"
)

# Function to display usage information
usage() {
    echo "Usage: $0 -p <project_dir> -o <output_file> -e <excluding_patterns>"
    exit 1
}

# Process command line options
while getopts "p:o:e:" opt; do
    case ${opt} in
        p )
            project_dir=$OPTARG
            ;;
        o )
            output_file=$OPTARG
            ;;
        e )
            custom_excluding_patterns=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done

# Set exclusion patterns
excluding_patterns=$(printf "%s" "${default_excluding_patterns[@]}")
if [ -n "$custom_excluding_patterns" ]; then
    excluding_patterns="${custom_excluding_patterns}|${excluding_patterns}"
fi

# Set default output file if not specified
if [ -z "$output_file" ]; then
    output_file="./snapshots/snapshot_$(date +%Y-%m-%d).md"
fi

# Check for required parameters
if [ -z "$project_dir" ]; then
    echo "Error: Option -p <project_dir> is required."
    usage
fi

if ! command -v tree &> /dev/null
then
    echo "The tree utility was not found."
    exit 1
fi

# Clear output file at first
> "$output_file"

# Generating directory tree and saving the result to a file
echo "## Full project tree" >> "$output_file"
tree -I "$excluding_patterns" "$project_dir" -f --prune | head -n -1 >> "$output_file"

# Save all text to one file snapshot
echo "## All files code"  >> "$output_file"
# Clear tree symbols and skip directories
paths=$(grep -v '/$' "$output_file" | sed -e 's/^.*── //' -e '/^##/d') 
# Add text to $output_file 
while IFS= read -r path; do
    if [ -f "$path" ]; then # Проверка, является ли путь файлом
        # Save filepath
        echo -e "\n### $path\n" >> "$output_file"
        # Save file text
        echo '```bash' >> "$output_file"
        cat "$path" >> "$output_file"
        echo '```' >> "$output_file"
        # New line
        echo "" >> "$output_file"
    fi
done <<< "$paths"
