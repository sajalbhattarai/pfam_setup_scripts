#!/bin/bash
set -e

INPUT_FILE=""
OUTPUT_PREFIX=""
DB_PATH="db/Pfam-A.hmm"
THREADS=4
EVALUE=0.01
EXTRA_ARGS=""

usage() {
    echo "Usage: $0 -i <input.faa> -o <output_prefix> [options]"
    echo "  -i FILE     Input protein FASTA"
    echo "  -o PREFIX   Output file prefix"
    echo "  -d PATH     Pfam database (default: db/Pfam-A.hmm)"
    echo "  -t INT      Threads (default: 4)"
    echo "  -e FLOAT    E-value (default: 0.01)"
    echo "  -x STRING   Extra hmmscan args"
    exit 1
}

while getopts "i:o:d:t:e:x:h" opt; do
    case $opt in
        i) INPUT_FILE="$OPTARG" ;;
        o) OUTPUT_PREFIX="$OPTARG" ;;
        d) DB_PATH="$OPTARG" ;;
        t) THREADS="$OPTARG" ;;
        e) EVALUE="$OPTARG" ;;
        x) EXTRA_ARGS="$OPTARG" ;;
        *) usage ;;
    esac
done

[ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_PREFIX" ] && usage
[ ! -f "$INPUT_FILE" ] && { echo "Error: Input file not found!"; exit 1; }
[ ! -f "$DB_PATH" ] && { echo "Error: Database not found!"; exit 1; }
command -v hmmscan &> /dev/null || { echo "Error: hmmscan not found!"; exit 1; }

mkdir -p "$(dirname "$OUTPUT_PREFIX")"
OUTPUT_FULL="${OUTPUT_PREFIX}_pfam_results.txt"
OUTPUT_TABLE="${OUTPUT_PREFIX}_pfam_domains.tsv"

echo "Running hmmscan: $INPUT_FILE -> $OUTPUT_PREFIX"

hmmscan --domtblout "$OUTPUT_TABLE" --cpu "$THREADS" -E "$EVALUE" \
    --noali -o "$OUTPUT_FULL" $EXTRA_ARGS "$DB_PATH" "$INPUT_FILE"

echo "Done!"
echo "  Results: $OUTPUT_FULL"
echo "  Table: $OUTPUT_TABLE"

if [ -f "$OUTPUT_TABLE" ]; then
    HITS=$(grep -vc "^#" "$OUTPUT_TABLE" || echo 0)
    echo "  Total hits: $HITS"
fi
