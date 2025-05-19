#!/bin/zsh
# fileinfo.sh - Display detailed information about a file
# Usage: fileinfo.sh <filename>

# Check if filename is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

FILENAME="$1"

# Color codes
RESET="\033[0m"
BLUE="\033[1;34m"   # Directories
GREEN="\033[1;32m"  # Executables
CYAN="\033[1;36m"   # Links
RED="\033[1;31m"    # Special files - Write permissions
YELLOW="\033[1;33m" # Read permissions
# WHITE="\033[1;37m"  # Write permissions

# Function to colorize permissions because why not ¯\_(ツ)_/¯
# Thanks Claude!
colorize_permissions() {
    local perm="$1"
    local result=""

    # First character (file type)
    case ${perm:0:1} in
    d) result="${BLUE}d${RESET}" ;;          # Directory
    l) result="${CYAN}l${RESET}" ;;          # Link
    -) result="${RESET}-${RESET}" ;;         # Regular file
    *) result="${RED}${perm:0:1}${RESET}" ;; # Special files
    esac

    # Owner permissions (rwx)
    for ((i = 1; i <= 3; i++)); do
        case ${perm:$i:1} in
        r) result="${result}${YELLOW}r${RESET}" ;;
        w) result="${result}${RED}w${RESET}" ;;
        x) result="${result}${GREEN}x${RESET}" ;;
        s) result="${result}${GREEN}s${RESET}" ;;
        S) result="${result}${RED}S${RESET}" ;;
        -) result="${result}${RESET}-${RESET}" ;;
        esac
    done

    # Group permissions (rwx)
    for ((i = 4; i <= 6; i++)); do
        case ${perm:$i:1} in
        r) result="${result}${YELLOW}r${RESET}" ;;
        w) result="${result}${RED}w${RESET}" ;;
        x) result="${result}${GREEN}x${RESET}" ;;
        s) result="${result}${GREEN}s${RESET}" ;;
        S) result="${result}${RED}S${RESET}" ;;
        -) result="${result}${RESET}-${RESET}" ;;
        esac
    done

    # Other permissions (rwx)
    for ((i = 7; i <= 9; i++)); do
        case ${perm:$i:1} in
        r) result="${result}${YELLOW}r${RESET}" ;;
        w) result="${result}${RED}w${RESET}" ;;
        x) result="${result}${GREEN}x${RESET}" ;;
        t) result="${result}${GREEN}t${RESET}" ;;
        T) result="${result}${RED}T${RESET}" ;;
        -) result="${result}${RESET}-${RESET}" ;;
        esac
    done

    echo -e "$result"
}

# Check if file exists
if [ ! -e "$FILENAME" ]; then
    echo "Error: File '$FILENAME' not found"
    exit 1
fi

# Get basic file info
NAME=$(basename "$FILENAME")
SIZE=$(stat -f "%z" "$FILENAME")
HUMAN_SIZE=$(du -h "$FILENAME" | cut -f1)
MOD_DATE=$(stat -f "%Sm" -t "%b %d %Y %H:%M:%S" "$FILENAME")
INODE=$(stat -f "%i" "$FILENAME")

PERMISSIONS=$(stat -f "%Sp" "$FILENAME")

OWNER=$(stat -f "%Su" "$FILENAME")
GROUP=$(stat -f "%Sg" "$FILENAME")

FILE_TYPE=$(file -b "$FILENAME")
MIME_TYPE=$(file -b --mime-type "$FILENAME")
UTI=$(mdls -name kMDItemContentType -raw "$FILENAME" 2>/dev/null)
UTI_TREE=$(mdls -name kMDItemContentTypeTree -raw "$FILENAME" 2>/dev/null | sed 's/(//' | sed 's/)//' | sed 's/,/    /' | sed 's/"//g')

# Output with formatting
echo ""
echo "FILE NAME"
echo "  '$NAME'"
echo ""
echo "METADATA"
echo "  Size: $HUMAN_SIZE ($SIZE bytes)"
echo "  Modified: $MOD_DATE"
echo -e "  Permissions: $(colorize_permissions $(stat -f "%Sp" "$FILENAME"))@"
echo "  Owner: $OWNER"
echo "  Group: $GROUP"
echo "  Inode: $INODE"
echo ""
echo "TYPE INFORMATION"
echo "  Type: $FILE_TYPE"
echo "  MIME Type: $MIME_TYPE"
[ -n "$UTI" ] && echo "  UTI: $UTI"
if [ -n "$UTI_TREE" ]; then
    echo -n "  UTI Type Tree:"
    echo -e "$UTI_TREE"
fi
