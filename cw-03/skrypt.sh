#!/bin/bash
# Aleksander Pugowski

# helpery do debugowania 
function print_map_array(){ 
    local -n array_name="$1"
    local text="$2"
    echo "==========$1=========$text="
    for x in "${!array_name[@]}"; do printf "[%s]=%s\n" "$x" "${array_name[$x]}" ; done
}

# flagi
HELP_CALLED=0
REPLACE_WITH_HARDLINKS=0
MAX_DEPTH=""
HASH_ALG="md5sum" 

# wczytanie & walidacja argumentow
OPTS=$(getopt -o "" --long help,replace-with-hardlinks,max-depth:,hash-algo: -- "$@")
eval set -- "$OPTS" 

while true; do
    case "$1" in
        --help)
            HELP_CALLED=1
            break;;
        --replace-with-hardlinks)
            REPLACE_WITH_HARDLINKS=1
            shift ;;
        --max-depth)
            MAX_DEPTH="$2"
            shift 2 ;;
        --hash-algo)
            HASH_ALG="$2"
            shift 2 ;;
        --)
            shift
            break ;;
    esac
done

# to wygenerowal chat
if [[ "$HELP_CALLED" -eq 1 ]]; then
    echo "Usage: $0 [OPTIONS] DIRNAME"
    echo "Options:"
    echo "  --help                      Show this help message."
    echo "  --replace-with-hardlinks    Replace duplicates with hardlinks."
    echo "  --max-depth=N               Set scan depth."
    echo "  --hash-algo=ALGO            Set hash algorithm (default: md5sum)."
    exit 0
fi

if ! command -v "$HASH_ALG" >/dev/null 2>&1
then
    echo "$HASH_ALG not supported." >&2
    exit 1
fi

# wlasciwy program
DIRNAME="$1"
declare -A size_to_file
declare -A hash_to_file
declare -A keep_to_copies_files
files_found=0
duplicates_found=0
duplicates_replaced=0

# to ze slajdow, kuloodporna iteracja po plikach
tempfile=$(mktemp tmpXXXXXXXXX)

find "$DIRNAME" ${MAX_DEPTH:+-maxdepth "$MAX_DEPTH"} -type f > "$tempfile"

while IFS= read -r filename; do    
    file_size=$(stat -c%s "$filename")
    if [[ "$filename" != "./$tempfile" ]]; then
        size_to_file["$file_size"]+="$filename"$'\n'
        (( files_found+=1 ))
    fi 
done < "$tempfile" 
rm "$tempfile"

## DEBUG
# print_map_array "size_to_file"

for size_key in "${!size_to_file[@]}"; do
    IFS=$'\n' read -r -d '' -a files_by_size <<< "${size_to_file[$size_key]}" # koncy na '' a nie n \n - stack
    
    if [[ "${#files_by_size[@]}" -gt 1 ]]; then
        for f in "${files_by_size[@]}"; do
            if [[ -n "$f" ]]; then
                hash_value=$($HASH_ALG "$f" 2>/dev/null | cut -d' ' -f1)
                if [[ -n "$hash_value" ]]; then
                    hash_to_file["$hash_value"]+="$f"$'\n'
                fi
            fi
        done
    fi
done

# # DEBUG
# print_map_array "hash_to_file" "Po hashowaniu"

# cmp dla plikow o tych samych HASHach
for hash_key in "${!hash_to_file[@]}"; do
    IFS=$'\n' read -r -d '' -a files_by_hash <<< "${hash_to_file[$hash_key]}"
    
    if [[ "${#files_by_hash[@]}" -gt 1 ]]; then
        file_to_keep="${files_by_hash[0]}" 
        
        for (( i=1; i<${#files_by_hash[@]}; i++)); do
            current_file="${files_by_hash[i]}"
            
            if cmp -s "$file_to_keep" "$current_file"; then
                keep_to_copies_files["$file_to_keep"]+="$current_file"$'\n'
                (( duplicates_found+=1 )) 
            fi
        done
    fi
done

## DEBUG
# print_map_array "keep_to_copies_files" "Po cmp"

if [[ "$REPLACE_WITH_HARDLINKS" -eq 1 ]]; then
    for keep_file in "${!keep_to_copies_files[@]}"; do
        IFS=$'\n' read -r -d '' -a files_to_replace <<< "${keep_to_copies_files[$keep_file]}"
        
        for copy_file in "${files_to_replace[@]}"; do
            if [[ -n "$copy_file" ]]; then
                ln -f "$keep_file" "$copy_file" 2>/dev/null 
                (( duplicates_replaced+=1 )) 
            fi
        done
    done
fi

echo "Liczba przetworzonych plikow: $files_found"
echo "Liczba znalezionych duplikatow: $duplicates_found"
echo "Liczba zastapionych duplikatow: $duplicates_replaced"