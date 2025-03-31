# VRS VCF Annotator for Assembly GRCh37 or GRCh38
Build a Docker image that executes the `vrs-annotate` tool with no external dependencies.
It contains a local copy of seqrepo that contains only GRCh37 or GRCh38 sequences.

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
NOTE: On MacOS you may need to use the `--rsync-exe` option to specify a compatible rsync version install with Homebrew.

Build the image for GRCh38:
```shell
docker build --build-arg ASSEMBLY=grch38 -t vrs-vcf-annotator-grch38:latest .
```

Run the image to annotate the VCF file `NA12878.vcf` in the current directory:
```shell
docker run -it --rm -v $(pwd):/input vrs-vcf-annotator-grch38:latest /input/NA12878.vcf --vcf-out /input/NA12878_with_vrs.vcf
```

Run the image to annotate the VCF file `NA12878.vcf` in the current directory and capture the VRS objects in a separate file:
```shell
docker run -it --rm -v $(pwd):/input vrs-vcf-annotator-grch38:latest /input/NA12878.vcf --vcf-out /input/NA12878_with_vrs.vcf --ndjson-out /input/vrs-objects.json
```
