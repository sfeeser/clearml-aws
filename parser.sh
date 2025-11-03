#!/bin/bash
#
# SAAYN Artifact Parser: Reconstructs the directory structure and files
# from a single composite output block using the '--- FILE: <path> ---' delimiter.
#
# Usage:
#   1. Save the synthesized IaC output to a file (e.g., 'terraform-artifact.txt').
#   2. Run the script: cat terraform-artifact.txt | ./parse_artifact.sh
#

# Ensure the script stops on the first error
set -e

# Define the delimiter used in the composite file
DELIMITER="--- FILE: "
DELIMITER_ESCAPED="--- FILE: "

# Temporary file to store the content between delimiters
TEMP_FILE=$(mktemp)
CURRENT_FILE_PATH=""
FIRST_FILE_SEEN=false

echo "Starting SAAYN Artifact Parser..."

# Function to process the content found for the previous file
process_content() {
    if [ "$CURRENT_FILE_PATH" != "" ]; then
        # 1. Create the directory if it doesn't exist
        DIR_NAME=$(dirname "$CURRENT_FILE_PATH")
        if [ ! -d "$DIR_NAME" ]; then
            mkdir -p "$DIR_NAME"
            echo "Created directory: $DIR_NAME"
        fi

        # 2. Extract content from the temp file (removing leading/trailing blank lines from stream)
        # Note: 'tail -n +2' is used to skip the initial blank line often present after a delimiter
        # 'cat "$TEMP_FILE" | sed -e 's/^[ \t]*//' | sed -e 's/[ \t]*$//' | sed '/^$/d' > "$CURRENT_FILE_PATH"'
        
        # We will use simple cat to preserve content exactly as generated, including
        # necessary blank lines in code files, but strip the leading blank line.
        
        sed '1,/^$/d' "$TEMP_FILE" > "$CURRENT_FILE_PATH"

        echo "Wrote content to: $CURRENT_FILE_PATH ($(wc -l < "$CURRENT_FILE_PATH" | tr -d ' ') lines)"

        # 3. Clear the temp file for the next file's content
        > "$TEMP_FILE"
    fi
}

# Read the input line by line from standard input
while IFS= read -r LINE || [ -n "$LINE" ]; do
    # Check if the line starts with the file delimiter
    if [[ "$LINE" == *"$DELIMITER"* ]]; then
        # Process the content of the PREVIOUS file (if one was active)
        process_content

        # Extract the new file path (everything after the delimiter and leading/trailing spaces)
        CURRENT_FILE_PATH=$(echo "$LINE" | sed "s/^.*$DELIMITER_ESCAPED//g" | xargs)
        FIRST_FILE_SEEN=true
    elif [ "$FIRST_FILE_SEEN" = true ]; then
        # If a file delimiter has been seen, pipe all subsequent lines to the temp file
        echo "$LINE" >> "$TEMP_FILE"
    fi
done

# Process the content of the LAST file encountered
process_content

# Cleanup the temporary file
rm "$TEMP_FILE"

echo "Artifact parsing complete."
