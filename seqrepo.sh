#!/bin/bash
set -e  # Exit on any error


# Check if an argument is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <fasta_file> <assembly_name>"
    exit 1
fi

FASTA_FILE=$1
ASSEMBLY_NAME=$2

export SEQREPO_ROOT=$(pwd)/seqrepo-$ASSEMBLY_NAME

# Check if the file exists
if [ ! -f "$FASTA_FILE" ]; then
    echo "Error: File '$FASTA_FILE' not found!"
    exit 1
fi

# Check if openrsync is in the output of /usr/bin/rsync --version
if /usr/bin/rsync --version | grep -q "openrsync"; then
    RSYNC_OPTION="--rsync-exe /opt/homebrew/bin/rsync"
else
    RSYNC_OPTION=""
fi

# Initialize seqrepo
echo "Initializing seqrepo in $SEQREPO_ROOT..."
seqrepo -r seqrepo --root-directory $SEQREPO_ROOT $RSYNC_OPTION init

# Load the provided FASTA file
echo "Loading FASTA file: $FASTA_FILE"
seqrepo -r seqrepo --root-directory $SEQREPO_ROOT $RSYNC_OPTION load "$FASTA_FILE" -n $ASSEMBLY_NAME

# Add assembly names
echo "Adding assembly names..."
seqrepo -r seqrepo --root-directory $SEQREPO_ROOT $RSYNC_OPTION add-assembly-names

echo "Process completed successfully."

# Insert data into SQLite database a WILD HACK to workaround vrs-annotate issue
echo "Inserting data into seqalias table..."
sqlite3 $SEQREPO_ROOT/master/aliases.sqlite3 <<EOF
INSERT INTO seqalias (seq_id, namespace, alias, added, is_current)
VALUES (1, 'GRCh38', 'MT', CURRENT_TIMESTAMP, 1);
EOF

echo "Data inserted successfully."

# Create a tar.gz archive of the seqrepo directory
echo "Archiving seqrepo directory..."
tar -czf "${ASSEMBLY_NAME}-seqrepo.tar.gz" -C "$(pwd)" seqrepo

echo "Archive created: ${ASSEMBLY_NAME}-seqrepo.tar.gz"