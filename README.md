
# Project Snapshot Maker for LLM

This Bash script is designed to create simple textual snapshots of projects for subsequent analysis using Large Language Models (LLMs) such as ChatGPT. It addresses the issue where sharing a project link for analysis doesn't always work effectively with LLMs, or the analysis of files might not be accurate enough. Providing a simple textual snapshot of the project helps present the data to the language model in a format that is easy for it to understand and analyze.

## Features

- Generates a full directory tree of the project, making it easy to understand the project's structure at a glance.
- Includes the content of files matching specified patterns, focusing on the most relevant data for LLM analysis.
- Excludes files based on specified patterns to avoid clutter and ensure the snapshot is concise and relevant.
- Outputs everything into a Markdown file for easy viewing, sharing, and analysis by LLMs.

## Prerequisites

Before running this script, ensure you have `tree` and `find` utilities installed on your system. These are typically available on most Linux distributions by default. If not, they can be easily installed via your distribution's package manager.

## Usage

The script accepts four arguments:

1. **Project Directory Path**: The path to the project directory you want to snapshot. (e.g., `./myProject/`)
2. **Output File Name**: The name of the Markdown file to generate. (e.g., `project_snapshot.md`)
3. **Including Patterns**: Space-separated list of file patterns to include in the snapshot. (e.g., `"*.txt *.md"`)
4. **Excluding Patterns**: Space-separated list of file patterns to exclude from the snapshot. (e.g., `"*.log *.tmp"`)

### Example Command

```bash
./project_snapshot.sh "./myProject/" "project_snapshot.md" "*.txt *.md" "*.log *.tmp"
