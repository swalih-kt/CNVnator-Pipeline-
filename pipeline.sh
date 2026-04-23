#!/bin/bash

# ==========================================================
# CNVnator Pipeline — CNV Detection from WGS BAM Files
# ==========================================================
#
# Purpose:
#   Detect copy number variants (CNVs) from whole genome
#   sequencing (WGS) BAM files using CNVnator.
#   Runs the full 5-step pipeline per sample:
#   tree → his → stat → partition → call
#
# Input:
#   Sorted, indexed BAM files (hg38-aligned)
#   GRCh38 reference genome (FASTA)
#
# Output:
#   Per-sample .root file (intermediate)
#   Per-sample .cnv file (final CNV calls)
#
# Bin size: 1000 bp
# Reference: Homo_sapiens.GRCh38.dna_sm.toplevel.fa.gz
# Chromosomes: chr1–chr22, chrX, chrY
# ==========================================================


FASTA="ref/Homo_sapiens.GRCh38.dna_sm.toplevel.fa.gz"
CHROMS=$(seq -f 'chr%g' 1 22) chrX chrY


# ----------------------------------------------------------
# Sample: GDN10398
# ----------------------------------------------------------

cnvnator -root GDN10398.root \
    -tree GDN10398_S29.bam \
    -chrom $(seq -f 'chr%g' 1 22) chrX chrY

cnvnator -root GDN10398.root \
    -his 1000 \
    -fasta "$FASTA"

cnvnator -root GDN10398.root -stat 1000

cnvnator -root GDN10398.root -partition 1000

cnvnator -root GDN10398.root -call 1000 > GDN10398.cnv

echo "✅ GDN10398 done"


# ----------------------------------------------------------
# Sample: GDN10399
# ----------------------------------------------------------

cnvnator -root GDN10399_sorted.root \
    -tree GDN10399_S31_hg38_aligned_sorted_MD.bam \
    -chrom $(seq -f 'chr%g' 1 22) chrX chrY

cnvnator -root GDN10399_sorted.root \
    -his 1000 \
    -fasta "$FASTA"

cnvnator -root GDN10399_sorted.root -stat 1000

cnvnator -root GDN10399_sorted.root -partition 1000

cnvnator -root GDN10399_sorted.root -call 1000 > GDN10399_sorted.cnv

echo "✅ GDN10399 done"


# ----------------------------------------------------------
# Sample: GDN10400
# ----------------------------------------------------------

cnvnator -root GDN10400_sorted.root \
    -tree GDN10400_S32_hg38_aligned_sorted_MD.bam \
    -chrom $(seq -f 'chr%g' 1 22) chrX chrY

cnvnator -root GDN10400_sorted.root \
    -his 1000 \
    -fasta "$FASTA"

cnvnator -root GDN10400_sorted.root -stat 1000

cnvnator -root GDN10400_sorted.root -partition 1000

cnvnator -root GDN10400_sorted.root -call 1000 > GDN10400_sorted.cnv

echo "✅ GDN10400 done"


# ----------------------------------------------------------
# Sample: GDN10401
# ----------------------------------------------------------

cnvnator -root GDN10401.root \
    -tree GDN10401_S30.bam \
    -chrom $(seq -f 'chr%g' 1 22) chrX chrY

cnvnator -root GDN10401.root \
    -his 1000 \
    -fasta "$FASTA"

cnvnator -root GDN10401.root -stat 1000

cnvnator -root GDN10401.root -partition 1000

cnvnator -root GDN10401.root -call 1000 > GDN10401.cnv

echo "✅ GDN10401 done"


# ==========================================================
# End of CNVnator Pipeline
# ==========================================================
