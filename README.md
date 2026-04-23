# CNVnator Pipeline — CNV Detection from WGS Data

A pipeline for detecting copy number variants (CNVs) from whole genome sequencing (WGS) BAM files using **CNVnator**. The pipeline runs five sequential steps per sample — read depth histogram generation, statistical testing, signal partitioning, and CNV calling — producing a per-sample CNV call file.

---

## Requirements

- **CNVnator** (with ROOT framework dependency)
- Sorted and indexed BAM files (`.bam` + `.bai`)
- Reference genome: `Homo_sapiens.GRCh38.dna_sm.toplevel.fa.gz`

---

## Input Files

| File | Description |
|------|-------------|
| `*.bam` | Sorted, duplicate-marked, hg38-aligned WGS BAM file |
| `*.bam.bai` | BAM index file |
| `Homo_sapiens.GRCh38.dna_sm.toplevel.fa.gz` | Soft-masked GRCh38 reference genome (FASTA) |

---

## Pipeline Steps

All five steps must be run **in order** for each sample. Each step reads from and writes to the sample's `.root` file, which stores intermediate data in ROOT format.

---

### Step 1: Build Read Depth Tree (`-tree`)

**Purpose**: Reads the BAM file and extracts per-chromosome read depth information into a ROOT binary file. This is the data foundation for all subsequent steps. Chromosomes chr1–chr22, chrX, and chrY are processed.

| | |
|---|---|
| **Input** | Sample BAM file |
| **Output** | `<sample>.root` (created/updated) |
| **Chromosomes** | chr1–chr22, chrX, chrY |

> **Important**: The BAM file must be coordinate-sorted and indexed before running this step. Running `-tree` twice on the same `.root` file will append data — always start with a fresh `.root` for a new sample.

---

### Step 2: Generate Read Depth Histogram (`-his`)

**Purpose**: Computes a read depth histogram across the genome using a fixed bin size of **1000 bp**. The histogram is stored in the `.root` file and used for signal analysis in subsequent steps.

| | |
|---|---|
| **Input** | `<sample>.root`, reference FASTA |
| **Output** | Histogram data written into `<sample>.root` |
| **Bin size** | 1000 bp |

> **Important**: The bin size (1000 bp) must remain consistent across all steps (`-his`, `-stat`, `-partition`, `-call`). A bin size of 1000 bp is appropriate for WGS data at 30× coverage. Smaller bins increase resolution but require higher coverage.

---

### Step 3: Calculate Statistics (`-stat`)

**Purpose**: Computes per-chromosome read depth statistics (mean, standard deviation) from the histogram. These statistics are used to normalize the signal and set thresholds for CNV calling.

| | |
|---|---|
| **Input** | `<sample>.root` (with histogram) |
| **Output** | Statistics written into `<sample>.root` |
| **Bin size** | 1000 bp |

> **Important**: Review the statistics output to check for unusually low or high mean read depth, which may indicate BAM quality issues or contamination.

---

### Step 4: Partition Signal (`-partition`)

**Purpose**: Segments the read depth signal into regions of uniform copy number using a mean-shift algorithm. This step identifies breakpoints that define the boundaries of potential CNV regions.

| | |
|---|---|
| **Input** | `<sample>.root` (with statistics) |
| **Output** | Partition data written into `<sample>.root` |
| **Bin size** | 1000 bp |

> **Important**: The `-ngc` flag (no GC correction) was tested during development but **not used** in the final calls for this cohort. GC correction (default, without `-ngc`) is recommended for standard WGS data and was applied to the final results.

---

### Step 5: Call CNVs (`-call`)

**Purpose**: Calls CNV regions from the partitioned signal and outputs the final results. Each line in the output represents one CNV with coordinates, type (deletion/duplication), size, and quality metrics.

| | |
|---|---|
| **Input** | `<sample>.root` (with partition) |
| **Output** | `<sample>.cnv` — tab-separated CNV call file |
| **Bin size** | 1000 bp |

> **Important**: Output is redirected to a `.cnv` file using `>`. Review calls using q0 (normalized read depth) and e-value columns to filter high-confidence CNVs — a common filter is `q0 >= 0` and size ≥ 1 kb.

---

## Samples Processed

| Sample ID | BAM File | Output |
|-----------|----------|--------|
| GDN10398 | `GDN10398_S29.bam` | `GDN10398.cnv` |
| GDN10399 | `GDN10399_S31_hg38_aligned_sorted_MD.bam` | `GDN10399_sorted.cnv` |
| GDN10400 | `GDN10400_S32_hg38_aligned_sorted_MD.bam` | `GDN10400_sorted.cnv` |
| GDN10401 | `GDN10401_S30.bam` | `GDN10401.cnv` |

---

## Output File Format (`.cnv`)

Each row in the `.cnv` output file represents one CNV call:

| Column | Description |
|--------|-------------|
| CNV type | `deletion` or `duplication` |
| Coordinates | `chr:start-end` |
| Size | CNV size in base pairs |
| Normalized RD | Normalized read depth (expected = 1.0 for diploid) |
| e-value | Statistical significance (smaller = more significant) |
| q0 | Fraction of reads with mapping quality 0 (lower = better) |

---

## Notes

- **Bin size 1000 bp** was used consistently across all steps. This is the standard for WGS data and balances resolution with statistical stability.
- **GC correction** (default behavior, without `-ngc`) was applied for the final CNV calls. The `-ngc` flag was tested but not used in final results.
- The **`-genotype`** flag (for genotyping known CNV regions) was explored but is not part of the primary calling pipeline documented here.
- Each sample requires its own `.root` file — do not share `.root` files between samples.
- For large cohorts, the five steps can be wrapped in a loop or submitted as a job array on SLURM.

---

## References

- [CNVnator GitHub](https://github.com/abyzovlab/CNVnator)
- [CNVnator Publication — Abyzov et al., Genome Research 2011](https://genome.cshlp.org/content/21/6/974)
- [ROOT Framework](https://root.cern/)
