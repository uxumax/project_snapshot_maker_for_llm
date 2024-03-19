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
