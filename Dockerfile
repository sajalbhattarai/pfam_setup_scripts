# Pfam Domain Analysis Container
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    hmmer \
    gzip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /pfam

# Copy all scripts
COPY *.sh ./
COPY CITATIONS.txt ./

# Make scripts executable
RUN chmod +x *.sh

# Verify HMMER installation
RUN hmmscan -h > /dev/null 2>&1 || (echo "HMMER installation failed" && exit 1)

# Create entrypoint script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Default database path (can be overridden with -d flag)\n\
DB_PATH="${PFAM_DB_PATH:-/pfam_data/Pfam-A.hmm}"\n\
DB_DIR=$(dirname "$DB_PATH")\n\
\n\
# Check if database exists\n\
if [ ! -f "$DB_PATH" ]; then\n\
    echo "================================================"\n\
    echo "Pfam database not found at: $DB_PATH"\n\
    echo "Running first-time setup..."\n\
    echo "================================================"\n\
    \n\
    # Ensure db directory exists\n\
    mkdir -p "$DB_DIR"\n\
    \n\
    # Download database\n\
    echo "Step 1: Downloading Pfam database (~3GB)..."\n\
    cd "$DB_DIR"\n\
    wget -q --show-progress https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz\n\
    \n\
    # Extract and prepare\n\
    echo "Step 2: Extracting and preparing database..."\n\
    gunzip -f Pfam-A.hmm.gz\n\
    hmmpress -f Pfam-A.hmm\n\
    \n\
    echo "================================================"\n\
    echo "Setup complete! Database ready at: $DB_PATH"\n\
    echo "================================================"\n\
else\n\
    echo "Using existing Pfam database at: $DB_PATH"\n\
fi\n\
\n\
# Run the analysis script with all arguments\n\
cd /pfam\n\
exec ./03_run_hmmer_pfam.sh -d "$DB_PATH" "$@"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default help message if no arguments provided
CMD ["-h"]

# Add labels
LABEL maintainer="<i have not added any name here yet"
LABEL description="Pfam domain analysis using HMMER with persistent database storage"
LABEL version="1.0"
