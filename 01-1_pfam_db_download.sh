#!/bin/bash
set -e

BASE_URL="https://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam38.1"
OUTPUT_DIR="db"

echo "Downloading Pfam 38.1 to $OUTPUT_DIR..."
mkdir -p "$OUTPUT_DIR" && cd "$OUTPUT_DIR"

files=(
    "Pfam-A.hmm.gz" "Pfam-A.hmm.dat.gz" "Pfam-A.fasta.gz" "Pfam-A.seed.gz"
    "Pfam-A.full.gz" "Pfam-A.clans.tsv.gz" "Pfam-A.regions.tsv.gz" 
    "Pfam-A.dead.gz" "Pfam-C.gz" "pfamA.txt.gz" "active_site.dat.gz"
    "relnotes.txt" "userman.txt" "md5_checksums" "Pfam.version.gz" 
    "diff.gz" "trees.tgz"
)

for file in "${files[@]}"; do
    wget -q --show-progress -c "$BASE_URL/$file"
done

echo "Done! Run extract_pfam_db.sh to prepare database."
