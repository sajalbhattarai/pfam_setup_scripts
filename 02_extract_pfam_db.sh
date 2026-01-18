#!/bin/bash
set -e

DB_DIR="${1:-db}"

[ ! -d "$DB_DIR" ] && { echo "Error: Directory '$DB_DIR' not found!"; exit 1; }
command -v gunzip &> /dev/null || { echo "Error: gunzip not found"; exit 1; }

cd "$DB_DIR"

echo "Extracting Pfam files..."
[ -f "Pfam-A.hmm.gz" ] && gunzip -f Pfam-A.hmm.gz
for file in Pfam-A.hmm.dat.gz Pfam-A.seed.gz pfamA.txt.gz Pfam-A.clans.tsv.gz; do
    [ -f "$file" ] && gunzip -f "$file"
done

echo "Indexing Pfam-A.hmm..."
command -v hmmpress &> /dev/null || { echo "Error: hmmpress not found. Run install_hmmer.sh first"; exit 1; }
[ ! -f "Pfam-A.hmm" ] && { echo "Error: Pfam-A.hmm not found!"; exit 1; }

hmmpress -f Pfam-A.hmm

echo "Done! Database ready."
ls -lh Pfam-A.hmm*
