#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <dir> <malicious_dir>"
    exit 1
fi

MONITOR_DIR="$1"
MALICIOUS_DIR="$2"

if [ ! -d "$MALICIOUS_DIR" ]; then
    echo "No malicious files to review."
    exit 0
fi

while true; do
    files=("$MALICIOUS_DIR"/*)
    valid_files=()
    for f in "${files[@]}"; do
        [ -f "$f" ] && valid_files+=("$f")
    done
    
    if [ ${#valid_files[@]} -eq 0 ]; then
        echo "No malicious files to review."
        break
    fi
    
    echo ""
    echo "--- Quarantined Files ---"
    i=1
    for f in "${valid_files[@]}"; do
        echo "$i) $(basename "$f")"
        i=$((i + 1))
    done
    
    read -p "Enter the number of the file to review (or 0 to exit): " choice
    
    if [ "$choice" -eq 0 ]; then
        break
    fi
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -gt ${#valid_files[@]} ] || [ "$choice" -lt 1 ]; then
        echo "Invalid choice. Try again."
        continue
    fi
    
    selected_file="${valid_files[$((choice - 1))]}"
    filename=$(basename "$selected_file")
    
    echo "Selected file: $filename"
    echo "1) Restore this file back into $MONITOR_DIR (false positive)"
    echo "2) Permanently delete this file from $MALICIOUS_DIR (genuinely malicious)"
    echo "3) Leave this file as-is and go back to the list"
    read -p "Choose an option (1-3): " option
    
    case "$option" in
        1)
            mv "$selected_file" "$MONITOR_DIR/$filename"
            echo "Restored $filename to $MONITOR_DIR."
            ;;
        2)
            rm "$selected_file"
            echo "$filename permanently deleted."
            ;;
        3)
            echo "Leaving file as-is."
            ;;
        *)
            echo "Invalid option. Going back to list."
            ;;
    esac
done