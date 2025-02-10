#!/bin/bash

SETTINGS_FILE="settings.txt"

declare -A OPTIONS

# Read settings.txt and populate OPTIONS array
if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo "Error: $SETTINGS_FILE not found!"
    exit 1
fi

echo "Available options:"
index=1
while IFS= read -r line; do
    [[ "$line" =~ ^# ]] && continue  # Skip header lines
    screen_name=$(echo "$line" | awk '{print $1}')
    dir=$(echo "$line" | awk '{print $2}')
    script=$(echo "$line" | awk '{print $3}')
    OPTIONS[$index]="$screen_name:$dir:$script"
    echo "$index) $screen_name ($dir, $script)"
    ((index++))
done < "$SETTINGS_FILE"

echo ""

# Prompt user for selection
read -p "Select an option: " choice

if [[ -z "${OPTIONS[$choice]}" ]]; then
    echo "Invalid selection!"
    exit 1
fi

screen_name=$(echo "${OPTIONS[$choice]}" | cut -d':' -f1)
dir=$(echo "${OPTIONS[$choice]}" | cut -d':' -f2)
script=$(echo "${OPTIONS[$choice]}" | cut -d':' -f3)

# Display selected option
echo "You selected: $screen_name ($dir, $script)"

# Check if the screen session exists
if screen -list | grep -q "$screen_name"; then
    echo "Connecting to existing screen session: $screen_name"
    screen -r "$screen_name"
else
    echo "Starting new screen session: $screen_name"
    cd "$dir" || exit 1
    screen -S "$screen_name" -dm bash -c "./$script; exec bash"
    screen -r "$screen_name"
fi
