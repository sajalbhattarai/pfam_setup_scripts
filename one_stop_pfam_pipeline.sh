#!/bin/bash
set -e

# Master script for complete Pfam analysis pipeline
# Automatically handles setup and runs analysis

INPUT_FILE=""
OUTPUT_PREFIX=""
DB_DIR="db"
DB_PATH="$DB_DIR/Pfam-A.hmm"
THREADS=4
EVALUE=0.01
EXTRA_ARGS=""
FORCE_SETUP=false

usage() {
    echo "Usage: $0 -i <input.faa> -o <output_prefix> [options]"
    echo "  -i FILE     Input protein FASTA"
    echo "  -o PREFIX   Output file prefix"
    echo "  -t INT      Threads (default: 4)"
    echo "  -e FLOAT    E-value (default: 0.01)"
    echo "  -x STRING   Extra hmmscan args"
    echo "  -f          Force fresh setup (re-download/re-extract)"
    exit 1
}

while getopts "i:o:t:e:x:fh" opt; do
    case $opt in
        i) INPUT_FILE="$OPTARG" ;;
        o) OUTPUT_PREFIX="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;
        e) EVALUE="$OPTARG" ;;
        x) EXTRA_ARGS="$OPTARG" ;;
        f) FORCE_SETUP=true ;;
        *) usage ;;
    esac
done

[ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_PREFIX" ] && usage
[ ! -f "$INPUT_FILE" ] && { echo "Error: Input file '$INPUT_FILE' not found!"; exit 1; }

echo "========================================="
echo "Pfam Analysis Pipeline"
echo "========================================="
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_PREFIX"
echo "========================================="

# Step 1: Check/Install HMMER
echo "[1/4] Checking HMMER installation..."
if ! command -v hmmscan &> /dev/null; then
    echo "  → HMMER not found. Installing..."
    ./install_hmmer.sh
else
    echo "  ✓ HMMER already installed"
fi

# Step 2: Check/Download Database
echo "[2/4] Checking Pfam database..."
if [ ! -f "$DB_DIR/Pfam-A.hmm.gz" ] && [ ! -f "$DB_PATH" ] || [ "$FORCE_SETUP" = true ]; then
    echo "  → Database not found. Downloading..."
    ./pfam_db_download.sh
else
    echo "  ✓ Database files present"
fi

# Step 3: Check/Extract Database
echo "[3/4] Checking database extraction..."
if [ ! -f "$DB_PATH" ] || [ ! -f "$DB_PATH.h3i" ] || [ "$FORCE_SETUP" = true ]; then
    echo "  → Extracting and indexing database..."
    ./extract_pfam_db.sh "$DB_DIR"
else
    echo "  ✓ Database ready"
fi

# Step 4: Run Analysis
echo "[4/4] Running Pfam analysis..."
mkdir -p "$(dirname "$OUTPUT_PREFIX")"
OUTPUT_FULL="${OUTPUT_PREFIX}_pfam_results.txt"
OUTPUT_TABLE="${OUTPUT_PREFIX}_pfam_domains.tsv"

hmmscan --domtblout "$OUTPUT_TABLE" --cpu "$THREADS" -E "$EVALUE" \
    --noali -o "$OUTPUT_FULL" $EXTRA_ARGS "$DB_PATH" "$INPUT_FILE"

echo "========================================="
echo "Analysis Complete!"
echo "========================================="
echo "Results: $OUTPUT_FULL"
echo "Table: $OUTPUT_TABLE"
if [ -f "$OUTPUT_TABLE" ]; then
    HITS=$(grep -vc "^#" "$OUTPUT_TABLE" || echo 0)
    echo "Total hits: $HITS"
fi
echo "========================================="
