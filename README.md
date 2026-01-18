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

### Option 1: Docker (Recommended - Best for Reproducibility)

**First time setup (downloads database to persistent volume):**
```bash
# Build lightweight container (~500MB, no database included)
docker build -t pfam_setup https://github.com/sajalbhattarai/pfam_setup_scripts.git

# Create a persistent volume for the database
docker volume create pfam_db

# First run will auto-download and prepare database (~3GB, takes 10-15 min)
docker run -v pfam_db:/pfam_data -v $(pwd):/data pfam_setup \
    -i /data/proteins.faa -o /data/results/output
```

**Subsequent runs (uses cached database, starts instantly):**
```bash
# Fast! Database already exists in the volume
docker run -v pfam_db:/pfam_data -v $(pwd):/data pfam_setup \
    -i /data/proteins.faa -o /data/results/output
```

**Alternative: Use a local folder instead of Docker volume:**
```bash
# Download database to a local folder (more flexible, easier to backup)
mkdir -p ~/pfam_database

# First run downloads to ~/pfam_database
docker run -v ~/pfam_database:/pfam_data -v $(pwd):/data pfam_setup \
    -i /data/proteins.faa -o /data/results/output

# Future runs use the same folder - database persists!
docker run -v ~/pfam_database:/pfam_data -v $(pwd):/data pfam_setup \
    -i /data/another_genome.faa -o /data/results/genome2
```

### Option 2: Automated Setup (Local Install)
```bash
# Run complete setup pipeline
./one_stop_pfam_pipeline.sh

# Then run analysis on your proteins
./03_run_hmmer_pfam.sh -i your_proteins.faa -o results/output
```

### Option 3: Manual Step-by-Step
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

### Docker Usage
```bash
# Basic usage with Docker volume (recommended)
docker run -v pfam_db:/pfam_data -v $(pwd):/data pfam_setup \
    -i /data/proteins.faa -o /data/results/genome_001

# Using local folder for database
docker run -v ~/pfam_database:/pfam_data -v $(pwd):/data pfam_setup \
    -i /data/proteins.faa -o /data/results/genome_001

# With custom parameters
docker run -v pfam_db:/pfam_data -v $(pwd):/data pfam_setup \
    -i /data/proteins.faa \
    -o /data/results/genome_001 \
    -t 8 \              # Use 8 threads
    -e 0.001            # Stricter E-value

# Windows users (PowerShell)
docker run -v pfam_db:/pfam_data -v ${PWD}:/data pfam_setup \
    -i /data/proteins.faa -o /data/results/output
```

### Local Script Usage
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

- **Docker is recommended**: Consistent environment across all systems
- **Database is persistent**: Once downloaded, it's reused for all future runs
- **Choose your storage**: Use Docker volumes (managed) or local folders (easier to access)
- **First run downloads database**: Takes 10-15 minutes (~3 GB download)
- **Subsequent runs are instant**: Database is cached and ready
- **Gene prediction not included**: If starting from genome sequences, use tools like Prodigal to generate protein sequences first
- **Database updates**: Pfam releases new versions periodically - delete and recreate volume/folder to update
- **Steps 01-1 and 01-2 are independent**: Can be run in parallel to save time (local install)

## 🐳 Docker Tips

### Managing database storage:

**Using Docker volumes (recommended for most users):**
```bash
# List volumes
docker volume ls

# Inspect volume location
docker volume inspect pfam_db

# Remove volume (will re-download on next run)
docker volume rm pfam_db

# Backup volume
docker run --rm -v pfam_db:/data -v $(pwd):/backup ubuntu tar czf /backup/pfam_db_backup.tar.gz -C /data .

# Restore volume
docker run --rm -v pfam_db:/data -v $(pwd):/backup ubuntu tar xzf /backup/pfam_db_backup.tar.gz -C /data
```

**Using local folder (easier to manage, backup, and share):**
```bash
# Database location
ls -lh ~/pfam_database/
# You'll see: Pfam-A.hmm, Pfam-A.hmm.h3f, Pfam-A.hmm.h3i, Pfam-A.hmm.h3m, Pfam-A.hmm.h3p

# To update database, simply delete the folder
rm -rf ~/pfam_database
# Next run will download fresh database

# Easy backup
tar czf pfam_db_backup.tar.gz ~/pfam_database/
```

### Check image size:
```bash
docker images pfam_setup
# Expected size: ~500-600 MB (lightweight, no database in image)
```

### Share database across multiple projects:
```bash
# All projects can use the same database volume/folder
cd /project1
docker run -v pfam_db:/pfam_data -v $(pwd):/data pfam_setup -i /data/proteins.faa -o /data/results/out

cd /project2
docker run -v pfam_db:/pfam_data -v $(pwd):/data pfam_setup -i /data/proteins.faa -o /data/results/out
```

## 🔗 Resources

- [Pfam Database](https://pfam.xfam.org/)
- [HMMER Documentation](http://hmmer.org/)
- [Pfam FTP Server](https://ftp.ebi.ac.uk/pub/databases/Pfam/)

---

**License**: These scripts are provided as-is for academic and research use.
