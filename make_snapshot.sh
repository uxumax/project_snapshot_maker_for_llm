#!/bin/bash

# Initialize variables for options
project_dir=""
output_file=""
custom_excluding_patterns=""

# Define default exclusion patterns
DEFAULT_EXCLUDING_PATTERNS=(
    "*.log|env"
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
excluding_patterns=$(printf "%s" "${DEFAULT_EXCLUDING_PATTERNS[@]}")
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

# Write the markdown prompt to the output file
cat << 'EOF' > "$output_file"
# Project Snapshot Overview

This document is a comprehensive textual snapshot of a software project. It is designed for analysis by Large Language Models (LLMs), like ChatGPT, to facilitate in-depth understanding and exploration of the project's codebase and structure. The snapshot aims to provide a clear and organized presentation of the project components for effective analysis and interpretation.

## How to Navigate This Snapshot

- **Full Project Tree**: Initially, you'll find a complete tree structure of the project directory, offering a high-level overview of the project's organization. This section helps in understanding how the project is structured at a glance, including directories, subdirectories, and file locations.

- **All Files Code**: Following the project tree, there is a detailed inclusion of the content of each file within the project. Each file's content is preceded by its relative path, providing a context for where it fits within the project structure. This part focuses on presenting the actual code, configurations, and any other textual data contained within the files, formatted within code blocks for clarity.

### Tips for LLM Analysis

- When analyzing the code or documentation contained in this snapshot, consider the context provided by the file's location within the project tree.
- Pay attention to the specified excluding patterns that were used to generate this snapshot. They help in focusing the analysis on the most relevant files by omitting common file types that are not typically necessary for understanding the project's functionality (e.g., log files, media files).
- Use the detailed file content presented to gain insights into the project's coding conventions, architectural decisions, and overall functionality.

## Purpose of This Document

The primary purpose of this document is to serve as a bridge between complex software projects and LLMs, enhancing the accessibility of project data for AI-driven analysis. It simplifies the process of presenting a project's structure and codebase in a format that is both comprehensive and easy for LLMs to interpret, thus supporting a wide range of analytical and developmental tasks.

EOF

# Generating directory tree and saving the result to a file
echo "## Full project tree" >> "$output_file"
tree "$project_dir" \
    -I "$excluding_patterns" \
    -f --prune | head -n -1 >> "$output_file"

# Save all text to one file snapshot
echo "## All files code"  >> "$output_file"
# Clear tree symbols and skip directories
paths=$(grep -v '/$' "$output_file" | sed -e 's/^.*── //' -e '/^##/d') 
# Add text to $output_file 
while IFS= read -r path; do
    if [ -f "$path" ]; then # Проверка, является ли путь файлом
        mime_type=$(file --mime-type -b "$path") # Get MIME type of the file
        if [[ $mime_type == text/* ]]; then # Check if MIME type starts with "text/"
            # Save filepath
            echo -e "\n### $path\n" >> "$output_file"
            # Save file text
            echo '```bash' >> "$output_file"
            cat "$path" >> "$output_file"
            echo '```' >> "$output_file"
            # New line
            echo "" >> "$output_file"
        fi
    fi
done <<< "$paths"
