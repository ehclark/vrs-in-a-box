# VRS VCF Annotator for Assembly GRCh37 or GRCh38
Build a Docker image that executes the `vrs-annotate` tool with no external dependencies.
It contains a local copy of seqrepo that contains only GRCh37 or GRCh38 sequences.

## Building Seqrepo
How to build a GRCh38 assembly only version of seqrepo:
```shell
git clone https://github.com/biocommons/biocommons.seqrepo
cd biocommons.seqrepo
make devready
source venv/bin/activate
curl -O https://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_mammalian/Homo_sapiens/all_assembly_versions/GCF_000001405.26_GRCh38/GCF_000001405.26_GRCh38_genomic.fna.gz
seqrepo -r seqrepo init
seqrepo -r seqrepo load -n NCBI GCF_000001405.26_GRCh38_genomic.fna.gz 
seqrepo -r seqrepo add-assembly-names
```

How to build a GRCh37 assembly only version of seqrepo:
```shell
git clone https://github.com/biocommons/biocommons.seqrepo
cd biocommons.seqrepo
make devready
source venv/bin/activate
curl -O https://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_mammalian/Homo_sapiens/all_assembly_versions/GCF_000001405.13_GRCh37/GCF_000001405.13_GRCh37_genomic.fna.gz
seqrepo -r seqrepo init
seqrepo -r seqrepo load -n NCBI GCF_000001405.13_GRCh37_genomic.fna.gz
seqrepo -r seqrepo add-assembly-names
sqlite3 seqrepo/master/aliases.sqlite3 <<EOF
INSERT INTO seqalias (seq_id, namespace, alias, added, is_current) 
VALUES ('Ya6Rs7DHhDeg7YaOSg1EoNi3U_nQ9SvO', 'GRCh38', '1', DATE('now'), 1);
EOF
sqlite3 seqrepo/master/sequences/db.sqlite3 <<EOF
INSERT INTO seqinfo (seq_id, len, alpha, added, relpath) 
VALUES ('Ya6Rs7DHhDeg7YaOSg1EoNi3U_nQ9SvO', 248956422, 'ACGMNRT', date('now'), '2025/0331/1411/1743430287.165611.fa.bgz');
EOF
```
NOTE: On MacOS you may need to use the `--rsync-exe` option to specify a compatible rsync version install with Homebrew.

NOTE: The post-build seqrepo database modifications for GRCh37 are to workaround a check in the VCF annotate tool that
assumes that GRCh38 assembly is present in seqrepo.


## Building Images for Each Assembly
Build the image for GRCh38:
```shell
docker build --build-arg ASSEMBLY=GRCh38 -t vrs-vcf-annotator-grch38:latest .
```
Build the image for GRCh37:
```shell
docker build --build-arg ASSEMBLY=GRCh37 -t vrs-vcf-annotator-grch38:latest .
```

## Running the Image in Docker
Run the image to annotate the VCF file `NA12878.vcf` in the current directory:
```shell
docker run -it --rm -v $(pwd):/input vrs-vcf-annotator-grch38:latest /input/NA12878.vcf --vcf-out /input/NA12878_with_vrs.vcf
```
Run the image to annotate the VCF file `NA12878.vcf` in the current directory and capture the VRS objects in a separate file:
```shell
docker run -it --rm -v $(pwd):/input vrs-vcf-annotator-grch38:latest /input/NA12878.vcf --vcf-out /input/NA12878_with_vrs.vcf --ndjson-out /input/vrs-objects.json
```

Prebuilt Docker images are available [here](https://hub.docker.com/u/eugene75).

## Running as Part of a Workflow (WDL)
VRS annotation of a VCF file can be added to a workflow easily.  See the VrsVcfAnnotator.wdl as an example.
