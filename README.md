# Pfam Domain Analysis Scripts

A collection of shell scripts to set up and run Pfam domain analysis on protein sequences using HMMER.

## 📁 Files Overview

### Step 1a: `01-1_pfam_db_download.sh`
Downloads the Pfam-A HMM database from the official FTP server.
- Creates `db/` directory
- Downloads Pfam-A.hmm.gz (~2-3 GB)
- **Run once** to obtain the database

### Step 1b: `01-2_install_hmmer.sh`
Installs HMMER software suite (required for running hmmscan).
- Detects your package manager (Homebrew/Conda)
- Installs HMMER and verifies installation
- **Run once** before first use
- Can run in parallel with Step 1a

### Step 2: `02_extract_pfam_db.sh`
Extracts and prepares the Pfam database for use.
- Decompresses Pfam-A.hmm.gz
- Runs `hmmpress` to index the database
- **Run once** after downloading (requires Step 1a and 1b complete)

### Step 3: `03_run_hmmer_pfam.sh`
Main analysis script - runs hmmscan to identify Pfam domains in protein sequences.
- Takes protein FASTA file as input
- Outputs domain predictions and detailed results
- **Run for each protein set** you want to analyze

### `one_stop_pfam_pipeline.sh`
Automated pipeline that runs all setup steps in sequence.
- Executes steps 01-1, 01-2, and 02 automatically
- Ideal for first-time setup
- Stops if any step fails

### `CITATIONS.txt`
Citation information for Pfam and HMMER.

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)
```bash
# Run complete setup pipeline
./one_stop_pfam_pipeline.sh

# Then run analysis on your proteins
./03_run_hmmer_pfam.sh -i your_proteins.faa -o results/output
```

### Option 2: Manual Step-by-Step
```bash
# Step 1a & 1b can run simultaneously
./01-1_pfam_db_download.sh &
./01-2_install_hmmer.sh

# Step 2: Prepare database (after both Step 1a & 1b complete)
./02_extract_pfam_db.sh

# Step 3: Run analysis on your proteins
./03_run_hmmer_pfam.sh -i your_proteins.faa -o results/output
```

## 📋 Requirements

- **Input**: Protein sequences in FASTA format (`.faa`)
- **System**: macOS or Linux
- **Software**: HMMER (installed by `01-2_install_hmmer.sh`)
- **Disk space**: ~3-4 GB for Pfam database

## 💡 Usage Example

```bash
# Basic usage
./03_run_hmmer_pfam.sh -i proteins.faa -o results/genome_001

# Custom parameters
./03_run_hmmer_pfam.sh -i proteins.faa -o results/genome_001 \
    -t 8 \           # Use 8 threads
    -e 0.001 \       # Stricter E-value
    -d custom/Pfam-A.hmm  # Custom database path
```

### Options for `03_run_hmmer_pfam.sh`:
- `-i FILE`: Input protein FASTA file (required)
- `-o PREFIX`: Output file prefix (required)
- `-d PATH`: Pfam database path (default: `db/Pfam-A.hmm`)
- `-t INT`: Number of threads (default: 4)
- `-e FLOAT`: E-value threshold (default: 0.01)
- `-x STRING`: Additional hmmscan arguments

## 📤 Output Files

After running `03_run_hmmer_pfam.sh`, you'll get:
- `{prefix}_pfam_results.txt`: Detailed HMMER output
- `{prefix}_pfam_domains.tsv`: Tab-separated domain table (parseable)

## 📖 Citations

### Pfam Database
> Mistry J, Chuguransky S, Williams L, et al. (2021)  
> **Pfam: The protein families database in 2021.**  
> *Nucleic Acids Research*, 49(D1):D412-D419.  
> DOI: [10.1093/nar/gkaa913](https://doi.org/10.1093/nar/gkaa913)

### HMMER
> Eddy SR. (2011)  
> **Accelerated profile HMM searches.**  
> *PLOS Computational Biology*, 7(10):e1002195.  
> DOI: [10.1371/journal.pcbi.1002195](https://doi.org/10.1371/journal.pcbi.1002195)

## 📝 Notes

- **First-time setup takes time**: Database download is ~2-3 GB
- **Gene prediction not included**: If starting from genome sequences, use tools like Prodigal to generate protein sequences first
- **Database updates**: Pfam releases new versions periodically - rerun scripts 01-1 and 02 to update
- **Steps 01-1 and 01-2 are independent**: Can be run in parallel to save time

## 🔗 Resources

- [Pfam Database](https://pfam.xfam.org/)
- [HMMER Documentation](http://hmmer.org/)
- [Pfam FTP Server](https://ftp.ebi.ac.uk/pub/databases/Pfam/)

---

**License**: These scripts are provided as-is for academic and research use.
