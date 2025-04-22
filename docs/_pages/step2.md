---
layout: default
title: "2. Assessing Read Quality and Trimming"
nav_order: 2
parent: Tutorial
permalink: /step2/
---

# Step 2: Trimming Fastq files  

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
    <img src="../images/169_1_fastqc.png" width="500" height="400">
    <figcaption>FastQC graph output for trimmed forward reads</figcaption>
</figure>



<figure>
    <img src="../images/169_2_fastqc.png" width="500" height="400">
    <figcaption>FastQC graph output for trimmed reverse reads</figcaption>
</figure>

#### Move trimmed fastq files to the trimmed fastq directory:  
`$ mv *trim* ../trimmed_fastq`  



#### Change to the `trimmed_fastq` directory:  
`$ cd ../trimmed_fastq` 

---

👉 Ready? Continue to [Step 3 - Sequence Assembly]({{ "/step3/" | relative_url }})