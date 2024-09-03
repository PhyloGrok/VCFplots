<p align="right">
  <img src="https://github.com/PhyloGrok/VCFplots/blob/main/Images/merck_logo.png" width="100" height="auto">
  <img src="https://github.com/PhyloGrok/VCFplots/blob/main/Images/UMBC_logo.png" width="200" height="auto">
</p>
<h1>Mutation Rate Meta-Analysis of Human Pathogenic Bacteria</h1>


<h2>Introduction</h2>
  <p>Understanding genetic variations and their impacts is crucial in studying microbial evolution and antibiotic resistance. Deletions, missense mutation, and other types of mutations create variants, which result in differing degrees of protein alteration and play a significant role in the adaptability and survival of bacteria. Visualizing these mutations using circus plots and stacked bar plots allows researchers to identify patterns and trends across different strains. By integrating these visualizations with the theory of neutral evolution, which favors advantageous mutations that are more likely to persist, we can better comprehend the dynamics of bacterial evolution for antibiotic resistance in their genome. This project aims to process vast genomic datasets of <em>Staphylococcus aureus</em> and <em>Pseudomonas aeruginosa</em> to automate variant analysis and ultimately create a comprehensive database to enhance our understanding of genomic mutations and  inform possible further genome studies against antibiotic resistance.</p>
<h2>Data</h2>
  <p> The Variant Calling Format (VCF) was obtained from the National Center for Biotechnology Information (NCBI) Sequence Read Archives. 
  The files retrieved were in FASTQ format, a widely used text-based format containing raw data of biological sequences. This format is 
  essential as it includes the nucleotide sequence and its corresponding quality score (the accuracy of each nucleotide in a biological sequence).
  </p>
<h2>Code</h2>

[Concatenate CSV.R](https://github.com/PhyloGrok/VCFplots/blob/main/code/Concatenate_CSVs.R)

<p>Summary: Merges all the annotated CSVs together into one .csv file.</p>

- It utilizes dplr, readr, andd ggplot2 packages. In the code it retrieves the working directory and imports all the csv files of each SRA Run. These files are read into a list and merged into a signgle sata frame with "bind_rows". 

[Annotation Impact Bar Plot.R](https://github.com/PhyloGrok/VCFplots/blob/main/code/Annotation_Impacts_BarPlot.R)

<p>Summary: Visualizes each SRA Run mutation impact with the use of R.</p>

- It utilizes dplr, readr, andd ggplot2 packages. Reading eacg independent SRA run csv file to filter out rows with missing values in Annotation impact and counts each occurence of each Annotation Impact for the SRA Run. The code then arranged the graph based on "low" impact in descending order creating a stacked bar plot.

[QC plot.R](https://github.com/PhyloGrok/VCFplots/blob/main/code/QC_Plot_SA.R)

- Visualize viable strains for the experiment considering genomic range to the reference genome of the respective bacterium.

<h2>Plots</h2>

<h3> <em> Pseudomonas aeruginosa </em> </h3>

<img src="https://github.com/PhyloGrok/VCFplots/blob/main/plots/PA_Impact_Plot.png" width="400" height="auto">

<h3> <em>Staphylococcus aureus </em> </h3>

<img src="plots/SA_Impact_Plot.png" width="400" height="auto">
<img src="plots/SA_QC_Calc_Plot.png" width="400" height="auto">

<h2>Results</h2>
<h3> <em> Pseudomonas aeruginosa </em> </h3>
<p>The plot visualized in the Annotation Impact plot it reveals that the generlly more moderate and low mutation impacts being seen in each SRA Run.</p>

<h3> <em>Staphylococcus aureus </em> </h3>

<h2>Acknowledgements</h2>
UMBC Translational Life Science Technology (TLST) student interns Nhi Luu, Aimee Icaza, and Ketsia Pierrelus are supported by Merck Data Science Fellowship for Observational Research Program and the UMBC College of Natural and Mathematical Sciences.  Nhi Luu developed the annotation scripts and R-Shiny framework and integration. 
