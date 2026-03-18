#!/bin/bash
# wcomp.sh - Convert images to WebP with customizable quality, compression, and resolution
# Requires: ffmpeg (with libwebp support), GNU parallel (optional but recommended)
set -euo pipefail

usage() {
    cat << EOF
Usage: $(basename "$0") <input> <output_dir> [flags]

Convert images (or all images in a directory) to WebP format using ffmpeg.

Positional arguments:
  input              Input file or directory containing images
  output_dir         Output directory (will be created if it doesn't exist)

Flags:
  -c, --compression <0-6>    WebP compression level (0=fastest, 6=smallest file)  [default: 4]
  -q, --quality <1-100>      WebP quality (1=worst, 75=good default, 100=lossless) [default: 85]
  -r, --resolution <percent> Scale resolution by percentage (e.g. 50 = 50% of original) [default: 100]
  -j, --jobs <num>           Number of parallel conversions [default: 5]
  -h, --help                 Show this help message

Examples:
  $(basename "$0") photo.jpg ./webp_output -q 90 -c 6 -r 80
  $(basename "$0") ./images/ ./converted/ -q 75 -r 70 -j 8
EOF
    exit 1
}

# Default values
COMPRESSION=6 
QUALITY=85
RESOLUTION_PERCENT=100
JOBS=5

# Parse named arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--compression)
            COMPRESSION="$2"
            shift 2
            ;;
        -q|--quality)
            QUALITY="$2"
            shift 2
            ;;
        -r|--resolution)
            RESOLUTION_PERCENT="$2"
            shift 2
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            if [[ -z "${INPUT:-}" ]]; then
                INPUT="$1"
            elif [[ -z "${OUTPUT:-}" ]]; then
                OUTPUT="$1"
            else
                echo "Too many positional arguments."
                usage
            fi
            shift
            ;;
    esac
done

# Validate required arguments
[[ -z "${INPUT:-}" || -z "${OUTPUT:-}" ]] && usage

# Validate numeric ranges
if ! [[ "$COMPRESSION" =~ ^[0-6]$ ]]; then
    echo "Error: Compression level must be between 0 and 6"
    exit 1
fi

if ! [[ "$QUALITY" =~ ^[0-9]+$ ]] || (( QUALITY < 1 || QUALITY > 100 )); then
    echo "Error: Quality must be between 1 and 100"
    exit 1
fi

if ! [[ "$RESOLUTION_PERCENT" =~ ^[0-9]+$ ]] || (( RESOLUTION_PERCENT < 1 || RESOLUTION_PERCENT > 200 )); then
    echo "Error: Resolution percentage must be between 1 and 200"
    exit 1
fi

if ! [[ "$JOBS" =~ ^[0-9]+$ ]] || (( JOBS < 1 || JOBS > 32 )); then
    echo "Error: Jobs must be between 1 and 32"
    exit 1
fi

# Check if ffmpeg is available
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg is not installed or not in PATH"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT"

# Calculate scale filter if needed
SCALE_FILTER=""
if (( RESOLUTION_PERCENT != 100 )); then
    SCALE_FILTER="-vf scale=iw*${RESOLUTION_PERCENT}/100:ih*${RESOLUTION_PERCENT}/100"
fi

convert_file() {
    local file="$1"
    local basename=$(basename "$file" | rev | cut -d. -f2- | rev)
    local output_file="$OUTPUT/${basename}.webp"
    
    echo "Converting: $file → $output_file"
    
    GALLIUM_DRIVER=zink ffmpeg -hide_banner -loglevel error -i "$file" \
        $SCALE_FILTER \
        -c:v libwebp \
        -compression_level "$COMPRESSION" \
        -quality "$QUALITY" \
        "$output_file" </dev/null
    
    echo "✓ Saved: $output_file ($(du -h "$output_file" | cut -f1))"
}

export -f convert_file
export OUTPUT SCALE_FILTER COMPRESSION QUALITY

# Process input
if [[ -f "$INPUT" ]]; then
    convert_file "$INPUT"
elif [[ -d "$INPUT" ]]; then
    shopt -s nullglob
    files=("$INPUT"/*.{png,jpg,jpeg,gif,bmp,tiff,tif,webp,avif})
    
    # Filter out non-existent files from glob
    real_files=()
    for f in "${files[@]}"; do
        [[ -f "$f" ]] && real_files+=("$f")
    done
    
    if (( ${#real_files[@]} == 0 )); then
        echo "No supported images found in directory: $INPUT"
        exit 1
    fi
    
    echo "Found ${#real_files[@]} images to convert using $JOBS parallel jobs"
    
    # Check if GNU parallel is available (faster and more efficient)
    if command -v parallel >/dev/null 2>&1; then
        printf "%s\n" "${real_files[@]}" | parallel -j "$JOBS" convert_file {}
    else
        # Fallback: Use background jobs with job control
        echo "Note: Install 'parallel' for better performance (sudo apt install parallel)"
        
        active_jobs=0
        for img in "${real_files[@]}"; do
            # Wait if we've hit the job limit
            while (( active_jobs >= JOBS )); do
                wait -n 2>/dev/null || true
                ((active_jobs--))
            done
            
            # Start new job in background
            convert_file "$img" &
            ((active_jobs++))
        done
        
        # Wait for remaining jobs
        wait
    fi
else
    echo "Error: Input must be a file or directory: $INPUT"
    exit 1
fi

echo "All done! Output saved to: $OUTPUT"
