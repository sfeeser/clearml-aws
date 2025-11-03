#!/bin/bash

# save_terraform_files.sh
# Usage: cat input.txt | ./save_terraform_files.sh
#    or: ./save_terraform_files.sh < input.txt

set -euo pipefail

current_file=""

while IFS= read -r line || [[ -n "$line" ]]; do
  # Detect start of a new file block
  if [[ "$line" =~ ^---[[:space:]]FILE:[[:space:]](.+)[[:space:]]---$ ]]; then
    filepath="${BASH_REMATCH[1]}"

    # Close previous file if open
    if [[ -n "$current_file" ]]; then
      echo "Saved: $current_file"
    fi

    # Create directory structure
    mkdir -p "$(dirname "$filepath")"

    # Start writing to new file (truncate if exists)
    > "$filepath"
    current_file="$filepath"

    echo "Starting: $filepath"
    continue
  fi

  # If we're inside a file block, append the line
  if [[ -n "$current_file" ]]; then
    printf '%s\n' "$line" >> "$current_file"
  fi

done

# Final save message
if [[ -n "$current_file" ]]; then
  echo "Saved: $current_file"
fi

echo "All files processed."
