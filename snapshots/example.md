## Full project tree
.
├── ./LICENSE
├── ./make_snapshot.sh
└── ./README.md

## All files code

### ./LICENSE

```bash
MIT License

Copyright (c) 2024 uxumax

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```


### ./make_snapshot.sh

```bash
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
```


### ./README.md

```bash
# Project Snapshot Maker for LLM

This Bash script is designed to create simple textual snapshots of projects for subsequent analysis using Large Language Models (LLMs) such as ChatGPT. It addresses the issue where sharing a project link for analysis doesn't always work effectively with LLMs, or the analysis of files might not be accurate enough. Providing a simple textual snapshot of the project helps present the data to the language model in a format that is easy for it to understand and analyze.

## Features

- Generates a full directory tree of the project, making it easy to understand the project's structure at a glance.
- Includes the content of files matching specified patterns, focusing on the most relevant data for LLM analysis.
- Supports custom excluding patterns in addition to default ones to enhance the relevance of the snapshot by excluding unnecessary files.
- Outputs everything into a Markdown file for easy viewing, sharing, and analysis by LLMs.

## Prerequisites

Before running this script, ensure you have the `tree` utility installed on your system. It is typically available on most Linux distributions by default. If not, it can be easily installed via your distribution's package manager.

## Usage

The script accepts the following arguments:

- **-p Project Directory Path**: The path to the project directory you want to snapshot. (e.g., `./myProject/`)
- **-o Output File Name** (Optional): The name of the Markdown file to generate. If not specified, the script will create a file in the `./snapshots/` directory with a name based on the current date (e.g., `snapshot_YYYY-MM-DD.md`).
- **-e Excluding Patterns** (Optional): A "|" separated list of additional file patterns to exclude from the snapshot. This is in addition to the default excluding patterns which include certain image and audio file extensions, log files, environment files, Python cache, and more. (e.g., `"*.tmp|*.backup"`)

### Example Command

To create a snapshot of the `./myProject/` directory, excluding additional patterns like `.tmp` and `.backup` files, and specifying the output file name:

```bash
./make_snapshot.sh -p "./myProject/" -o "custom_project_snapshot.md" -e "*.tmp|*.backup"
```

If you do not specify the -o option, the script will automatically create a snapshot file in the ./snapshots/ directory with a name based on the current date.
```

