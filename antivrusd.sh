#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <dir> <malicious_dir> <interval-secs>"
    exit 1
fi

MONITOR_DIR="$1"
MALICIOUS_DIR="$2"
INTERVAL="$3"

mkdir -p "$MALICIOUS_DIR"

LAST_INFO="directory-info.last"
NEW_INFO="directory-info.new"
WHITELIST_FILE="whitelist.txt"

FLAGGED_EXTENSIONS=("exe" "bat" "vbs" "scr" "ps1")
FLAGGED_KEYWORDS=("virus" "trojan" "malware" "worm" "ransomware")

scan_directory() {
    echo "Scanning directory: $MONITOR_DIR"
    
    for file in "$MONITOR_DIR"/*; do
        [ -f "$file" ] || continue
        
        filename=$(basename "$file")
        is_malicious=0
        
        # Check Whitelist first
        if [ -f "$WHITELIST_FILE" ]; then
            is_whitelisted=0
            mapfile -t whitelist_entries < "$WHITELIST_FILE"
            for entry in "${whitelist_entries[@]}"; do
                entry=$(echo "$entry" | tr -d '\r' | xargs)
                [[ -z "$entry" || "$entry" =~ ^# ]] && continue
                if [ "$filename" = "$entry" ] || [ "${filename##*.}" = "$entry" ]; then
                    is_whitelisted=1
                    break
                fi
            done
            
            if [ "$is_whitelisted" -eq 1 ]; then
                echo "$filename is whitelisted. Skipping."
                continue
            fi
        fi
        
        ext="${filename##*.}"
        ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
        for bad_ext in "${FLAGGED_EXTENSIONS[@]}"; do
            if [ "$ext_lower" = "$bad_ext" ]; then
                is_malicious=1
                break
            fi
        done
        
        if [ "$is_malicious" -eq 0 ]; then
            for keyword in "${FLAGGED_KEYWORDS[@]}"; do
                if grep -qi "$keyword" "$file"; then
                    is_malicious=1
                    break
                fi
            done
        fi
        
        if [ "$is_malicious" -eq 1 ]; then
            echo "$filename is malicious and it is DELETED"
            cp "$file" "$MALICIOUS_DIR/$filename"
            rm "$file"
        fi
    done
}

if [ ! -f "$LAST_INFO" ]; then
    scan_directory
    ls -l "$MONITOR_DIR" > "$LAST_INFO"
fi

while true; do
    sleep "$INTERVAL"
    
    ls -l "$MONITOR_DIR" > "$NEW_INFO"
    
    if ! cmp -s "$LAST_INFO" "$NEW_INFO"; then
        scan_directory
        cp "$NEW_INFO" "$LAST_INFO"
    else
        cp "$NEW_INFO" "$LAST_INFO"
    fi
done