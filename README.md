# VEME 2024 NGS *De novo* Assembly Tutorial

[![Open with Gitpod](https://img.shields.io/badge/Open%20with-Gitpod-908a85?logo=gitpod)](https://gitpod.io/#https://github.com/taylorpaisie/VEME_2024_NGS_Denovo_Assembly)

## Taylor K. Paisie
### CDC - Bacterial Special Pathogens Branch (BSPB)
### Email:  ltj8@cdc.gov
### `https://taylorpaisie.github.io/VEME_2024_NGS_Denovo_Assembly/`

#### Directory visualization
<figure>
    <img src="images/denovo_assembly_Graph.svg" width="600">
    <figcaption>How the structure of our directories should look</figcaption>
</figure>

#### Command line cheat sheet
<figure>
    <img src="images/command-line-cheat-sheet-large.png" height="800">
    <figcaption>Variant Calling Workflow</figcaption>
</figure>

### 1. Introduction to sequence assembly
#### What does "sequence assembly" mean?
#### Assembly is a “catch-all” term used to describe methods where we combine shorter individual reads into longer contiguous sequences called contigs
#### Because the sequencing process works by breaking the original DNA into smaller fragments, the assembly process is conceptually similar to putting together an image puzzle from its many pieces
#### The software that performs the assembly is called the assembler  
#### We will learn how to *de novo* assemble reads sequenced by the Illumina sequencing platform using [SPAdes](http://cab.spbu.ru/software/spades/), an assembly toolkit containing various assembly pipelines

<figure>
    <img src="images/denovo_assembly_newspaper.jpeg" weight="1000">
</figure>

#### *De novo* assembly usually includes the following steps:  
1. Improving of the reads quality (remove adapters, trim reads, etc..)  
2. De novo assembly of the overlapping reads into contigs
3. Joining contigs into scaffolds
4. Comparison with other known genomes
5. Filling the gaps
6. Annotation of the assembled genome
7. Visualize genome annotation  

#### Challenges of *de novo* assembly
#### Sequence assembly is perhaps the application domain of bioinformatics where skill and expertise are the most difficult to identify and define   
#### Assemblers are quite unlike any other software tool you will ever use  
#### Most come with a bewildering array of parameters - the purpose of which are not explained, yet many will have profound effects on the results that they produce  
#### Trial and error are one of the most commonly used strategies - you will have to keep tuning the parameters and rerun the entire process hoping that the results improve  
#### Assembling a large genome may take weeks and substantial computational resources  
#### Thus any expertise built on trial and error will have to be accumulated over a much more extended period  
#### Finally, even when assembly appears to work, almost always it will contain several severe and substantial errors. That is where, in our opinion, bioinformatics expertise matters more  
#### The ability to understand, visualize and correct the mistakes of an assembly has a utility that will outlast the present and is more valuable than knowing the exact invocation of a tool by heart  
#### N50: length for which the collection of all contigs of that length or longer covers at least 50% of assembly length  




<figure>
    <img src="images/denovo_pic1.png" width="500">
    <figcaption>Overlapping reads are assembled into contigs. Based on the info about paired-end reads, contigs may be further assembled into scaffolds</figcaption>
</figure>


#### What is the N50 statistic:  
* A simpler explanation of N50 starts by ordering contigs by length  
* Suppose we have 10 different contigs (designated by XXXXXX ) and we ordered these by their decreasing sizes:  
  
```
Contig         Length           Sum
XXXXXXXXXX       10              10
XXXXXXXXX         9              19
XXXXXXXX          8              27
XXXXXXX           7              34
XXXXXX            6              40
XXXXX             5              45
XXXX              4              49
XXX               3              52
XX                2              54
X                 1              55
```

* The sum of these lengths starting with the longest is 55. Half of that is 27.5  
* Go down on this list and add up the lengths to find the contig where the cumulative length exceeds this half value  
* When we hit contig number 7 we have 10 + 9 + 8 + 7 = 34, this value is larger than 27.5 so it is at this point at least half of the genome is stored in contigs of size 7 or greater - N50 is then 7  
* “At least half of the nucleotides in this assembly belong to contigs of size 8bp or longer”  

#### Problems with N50 statistic:  
* One of the biggest problems using the N50 metric as the primary means of evaluating assembly quality is that it rewards “misjoins”   
* A “misjoin” is the error of concatenating separate contigs into a single segment 
* Such mistakes can happen when the evidence is insufficient, but the algorithm is tuned to be overly generous in accepting these pieces of evidence  
* Also applying cutoffs can lead to odd situations when selecting contigs would lead us to be either well under or well over the 50%  

#### What are k-mers?  
* A k-mer are all possible subsequences of size k  
* The rationale for breaking our reads into even smaller pieces, k-mers is that we want to identify “correct” k-mers, those that originate from the real data  
* The assumption is that whatever errors the reads may have these are distributed randomly - hence will produce different erroneous k-mers  
* The correct k-mers will always be the most abundant  
* In general, the longer a k-mer is, the fewer identical k-mers to it exist  
* At the same time it is also true the longer a k-mer is, the more likely is that it will contain an error  
* When it comes to assembly processes the rule of reasoning is that:
  * A larger k value allows resolving more repetitions  
  * A smaller k increases the chances of seeing a given k-mer  
* Hence the selection of a k-mer is a tradeoff between longer repeats and more reliable measures  
* In general, you should assemble sequences using the largest k-mer size possible, such that the k-mer coverage is sufficient  
* You may estimate these via trial and error (as stated above) but there are also tools that will assist you in determining the most likely k-mer sizes and coverage cutoffs  



#### Multidrug resistant bacteria have become a major public health threat  
#### Phage therapy may to be used as an alternative to antibiotics or, as a supplementary approach to treat some bacterial infections   
#### Bacteriophages have been applied in clinical practice for the treatment of localized infections in wounds, burns, and trophic ulcers, including diabetic foot ulcers (PMC6083058)  
#### In this study, bacteria were collected from trophic ulcers of the patients  
#### Bacteriophages that were successful in treating diabetic foot disease were sequenced using NGS technology   
#### The sample we will be using is a 2x250 Illumina sequenced bacteriophage  
#### The goal of this exercise is to assemble the genome of a sequenced bacteriophage  

#### [Link to data](https://doi.org/10.6084/m9.figshare.25577178.v1)

#### Making directories for lesson:

`$ mkdir -p ~/denovo_assembly/data/untrimmed_fastq ~/denovo_assembly/data/trimmed_fastq`     


### 2. Trimming Fastq files  

#### Download the fastq and adapter files in the untrimmed fastq directory:  
`$ cd ~/denovo_assembly/data/untrimmed_fastq`  
`$ wget -nv https://figshare.com/ndownloader/files/45571629 -O 169_S7_L001_R1_001.fastq.gz --no-check-certificate`   
`$ wget -nv https://figshare.com/ndownloader/files/45571626 -O 169_S7_L001_R2_001.fastq.gz --no-check-certificate`  
`$ cp /home/gitpod/miniconda/envs/denovo_assembly/share/trimmomatic-0.39-2/adapters/TruSeq3-PE-2.fa .` 


#### Running FastQC on the raw fastq files:  

`$ fastqc *.fastq.gz`  


#### Now run Trimmomatic on the raw fastq files:  

```
$ trimmomatic PE \
169_S7_L001_R1_001.fastq.gz 169_S7_L001_R2_001.fastq.gz \
169_S7_L001_R1_001.trim.fastq.gz 169_S7_L001_R1_001un.trim.fastq.gz \
169_S7_L001_R2_001.trim.fastq.gz 169_S7_L001_R2_001un.trim.fastq.gz \
SLIDINGWINDOW:4:20 MINLEN:25 ILLUMINACLIP:TruSeq3-PE-2.fa:2:40:15
```

#### Run FastQC on newly trimmed fastq files:  

`$ fastqc *trim.fastq.gz`  

<figure>
    <img src="images/169_1_fastqc.png" width="500" height="400">
    <figcaption>FastQC graph output for trimmed forward reads</figcaption>
</figure>



<figure>
    <img src="images/169_2_fastqc.png" width="500" height="400">
    <figcaption>FastQC graph output for trimmed reverse reads</figcaption>
</figure>

#### Move trimmed fastq files to the trimmed fastq directory:  
`$ mv *trim* ../trimmed_fastq`  



#### Change to the `trimmed_fastq` directory:  
`$ cd ../trimmed_fastq`  
   

### 3. Sequence Assembly

#### We will be using the program [SPades](http://cab.spbu.ru/software/spades/) for *de novo* assembly  

#### Spades will automatically make the final scaffolds:  

`$ spades.py --isolate  -1 169_S7_L001_R1_001.trim.fastq.gz -2 169_S7_L001_R2_001.trim.fastq.gz -o spades_output`   

`$ ls -l spades_output`  

#### Notice in our `spades_output` directory we have both a `contigs.fasta` and a `scaffolds.fasta`  


#### Use [QUAST](https://quast.sourceforge.net/) to analyze the SPades output scaffolds fasta file:
`$ quast.py -o quast_output spades_output/scaffolds.fasta`  

<figure>
    <img src="images/quast_result.png" width="700" height="400">
    <figcaption>Result from running Quast on our scaffolds</figcaption>
</figure>

#### QUAST output contains:  
   * report.txt	- assessment summary in plain text format  
   * report.tsv	- tab-separated version of the summary, suitable for spreadsheets (Google Docs, Excel, etc)  
   * report.tex	- LaTeX version of the summary  
   * icarus.html - Icarus main menu with links to interactive viewers. See section 3.4 for details  
   * report.pdf - all other plots combined with all tables (file is created if matplotlib python library is installed)  
   * report.html - HTML version of the report with interactive plots inside  
   * contigs_reports/ - (only if a reference genome is provided)
   * misassemblies_report - detailed report on misassemblies  
   * unaligned_report - detailed report on unaligned and partially unaligned contigs  
   * k_mer_stats/ - (only if --k-mer-stats option is specified)
   * kmers_report - detailed report on k-mer-based metrics  
   * reads_stats/ - (only if reads are provided)  
   * reads_report - detailed report on mapped reads statistics  



#### SPades makes both files, but we will be using the `scaffolds.fasta` for this exercise


#### Create and move scaffolds from SPades to results directory:  

`$ mkdir -p ~/denovo_assembly/results/scaffolds`  
`$ mv ~/denovo_assembly/data/trimmed_fastq/spades_output/scaffolds.fasta ~/denovo_assembly/results/scaffolds`  
`$ cd ~/denovo_assembly/results/scaffolds`    

#### We now want to be at the `denovo_assembly` directory


### 4. Comparing the scaffolds to other known genomes

#### We will know take our scaffolds and use [NCBI BLAST](https://blast.ncbi.nlm.nih.gov/Blast.cgi) to compare our newly assembled genome to other genomes  

<figure>
    <img src="images/blast_results.png" width="1000">
    <figcaption>BLAST results from our scaffolds</figcaption>
</figure>

#### BLAST found similar genomes  
#### The closest is Pseudomonas phage CMS1, complete genome (OM937766.1), with coverage of 99% and identity of 98.53%   
#### Examination of the GenBank record for OM937766 finds that organism is "Pseudomonas phage CMS1" and the taxon ID is 2926659  
#### Another closely related genome is RefSeq NC_031063.1, Pseudomonas phage PEV2  



### 5. Filling the gaps  


#### Now we will take our scaffolds and use it as a reference as a 
#### Map the reads back to the scaffold as reference  
#### Set up BWA reference mapping with the scaffold `scaffolds.fasta` as reference and add the trimmed fastq files  

#### Make sure you are in the `denovo_assembly` directory and make `results` directories (helps with file organization, super important!!)

`$ cd ~/denovo_assembly`  
`$ mkdir -p results/sam results/bam`  

#### Index our `scaffolds.fasta` file we made with SPades:  

`$ bwa index results/scaffolds/scaffolds.fasta`  

#### Run BWA-MEM reference mapping with the indexed `scaffolds.fasta` as the reference and the original trimmed fastq files as the reads:  
`$ bwa mem results/scaffolds/scaffolds.fasta data/trimmed_fastq/169_S7_L001_R1_001.trim.fastq.gz data/trimmed_fastq/169_S7_L001_R2_001.trim.fastq.gz > results/sam/169.aligned.sam`    


#### Convert SAM file to BAM format:  
`$ samtools view -S -b results/sam/169.aligned.sam > results/bam/169.aligned.bam`  


#### Sort BAM file by coordinates:  
`$ samtools sort -o results/bam/169.aligned.sorted.bam results/bam/169.aligned.bam`  

#### Index new sorted BAM file:  
`$ samtools index results/bam/169.aligned.sorted.bam`  


#### Visualizing our new BAM file with IGV
#### We will use our `scaffolds.fasta` as the reference genome in IGV and the `169.aligned.sorted.bam` BAM file


<figure>
    <img src="images/IGV_pic1.png" width="2000" height="400">
    <figcaption>IGV visualization of our genome assembly</figcaption>
</figure>


#### Now we run the program [Pilon](https://github.com/broadinstitute/pilon)

#### Pilon is a software tool which can be used to automatically improve draft assemblies  
#### It attempts to make improvements to the input genome, including:  
   * Single base differences  
   * Small Indels  
   * Larger Indels or block substitution events  
   * Gap filling
   * Identification of local misassemblies, including optional opening of new gaps

#### Pilon outputs a FASTA file containing an improved representation of the genome from the read data  

`$ pilon --genome results/scaffolds/scaffolds.fasta --frags results/bam/169.aligned.sorted.bam --output results/scaffolds/169_improved`  

#### This command will give us the file `169_improved.fasta`  

#### After running this commmand, each fasta input in `169_improved.fasta` has `_pilon`
#### We want to remove this `_pilon` after each fasta input
#### Open `169_improved.fasta` in a text editor

`$ code results/scaffolds/169_improved.fasta`

#### We want to "replace all" `_pilon` with nothing



<figure>
    <img src="images/editing_fasta.png" width="1000">
    <figcaption>How to edit the improved fasta file (output from pilon)</figcaption>
</figure>



### 6. Annotation of the assembled genome

#### We will use [PROKKA](https://github.com/tseemann/prokka) on the improved sequence assembly

#### After you have *de novo* assembled your genome sequencing reads into scaffolds, it is useful to know what genomic features are on those contigs  
#### The process of identifying and labelling those features is called genome annotation  
#### Prokka is a "wrapper"; it collects together several pieces of software (from various authors), and so avoids "re-inventing the wheel"  
#### Prokka finds and annotates features (both protein coding regions and RNA genes, i.e. tRNA, rRNA) present on on a sequence  
#### Prokka uses a two-step process for the annotation of protein coding regions:  
   1. Protein coding regions on the genome are identified using Prodigal  
   2. The function of the encoded protein is predicted by similarity to proteins in one of many protein or protein domain databases  
#### Prokka is a software tool that can be used to annotate bacterial, archaeal and viral genomes quickly, generating standard output files in GenBank, EMBL and gff formats

#### Once Prokka has finished, examine each of its output files:
   * The GFF and GBK files contain all of the information about the features annotated (in different formats)  
   * The .txt file contains a summary of the number of features annotated  
   * The .faa file contains the protein sequences of the genes annotated  
   * The .ffn file contains the nucleotide sequences of the genes annotated  

#### We will use a protein set specific to Pseudomonas phage PEV2 (NC_031063.1), our closely related genome from BLAST, for the annotation

#### First we want to download the [protein coding regions of the Pseudomonas phage PEV2 (NC_031063.1) genome](https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus?SeqType_s=Nucleotide&VirusLineage_ss=Pseudomonas%20phage%20PEV2,%20taxid:1837850), we can do this from NCBI

<figure>
    <img src="images/download_proteins.png" width="1000">
    <figcaption>How to download a set of proteins from NCBI</figcaption>
</figure>

#### Running prokka on the improved alignment with our downloaded protein set for annotation:  

`$ mkdir -p results/annotation`  
`$ wget -nv https://raw.githubusercontent.com/taylorpaisie/VEME_2024_NGS_Denovo_Assembly/main/NC_031063.1.faa -O ~/denovo_assembly/results/annotation/NC_031063.1.faa`  

#### For this tutorial we will copy the protein set we will use for annotation  


#### Need to activate the Prokka conda environment (we can talk about this later if we have time):  
 

`$ prokka --outdir results/annotation/prokka_output --kingdom Viruses --proteins results/annotation/NC_031063.1.faa results/scaffolds/169_improved.fasta`  


### 7. Visualize genome annotation

#### We will use the program Artemis to visualize the genome annotation we made with PROKKA using [Artemis](https://sanger-pathogens.github.io/Artemis/Artemis/) 
#### Artemis is a free genome browser and annotation tool that allows visualisation of sequence features, next generation data and the results of analyses within the context of the sequence, and also its six-frame translation  
#### Artemis is written in Java, and is available for UNIX, Macintosh and Windows systems  
#### It can read EMBL and GENBANK database entries or sequence in FASTA, indexed FASTA or raw format  
#### Using the GFF file made from PROKKA, we will open it with Artemis:  

`$ /usr/local/share/artemis/art results/annotation/prokka_output/PROKKA_08222023.gff`  


<figure>
    <img src="images/artemis_output.png" width="1000">
    <figcaption>Visualizaing the genome annotation with Artemis</figcaption>
</figure>


#### Some tips for using Artemis:

1. There are 3 panels: feature map (top), sequence (middle), feature list (bottom)
2. Click right-mouse-button on bottom panel and select Show products
3. Zooming is done via the verrtical scroll bars in the two top panels

