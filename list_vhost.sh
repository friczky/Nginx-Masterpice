#!/bin/bash

# Function to print table
print_table() {
    local format="%-30s %-30s\n"
    printf "$format" "Domain" "Path"
    printf "%-30s %-30s\n" "------------------------------" "------------------------------"

    for file in /etc/nginx/sites-available/*; do
        if [ -f "$file" ]; then
            domain=$(awk '/server_name/ {gsub(";", "", $2); print $2}' "$file")
            root=$(awk '/root/ {print $2}' "$file" | grep -oP '(?<=/)[^/]+(?=;)')
            printf "$format" "$domain" "$root"
        fi
    done
}

# Check if Nginx is installed
if ! [ -x "$(command -v nginx)" ]; then
    echo "Nginx is not installed on this system."
    exit 1
fi

print_table
