# Yarrowia_lipolytica_W29-GEM

- Brief Model Description

This repository contains the current genome-scale metabolic model of _Yarrowia lipolytica_ W29, named **iYali**. Various different updated versions can be downloaded as [releases](https://github.com/SysBioChalmers/Yarrowia_lipolytica_W29-GEM/releases).

- Abstract

_Yarrowia lipolytica_ is a promising microbial cell factory for the production of lipids to be used as fuels and chemicals, but there are few studies on regulation of its metabolism. Here we performed the first integrated data analysis of _Y. lipolytica_ grown in carbon and nitrogen limited chemostat cultures. We first reconstructed a genome-scale metabolic model and used this for integrative analysis of multilevel omics data. Metabolite profiling and lipidomics was used to quantify the cellular physiology, while regulatory changes were measured using RNAseq. Analysis of the data showed that lipid accumulation in _Y. lipolytica_ does not involve transcriptional regulation of lipid metabolism but is associated with regulation of amino-acid biosynthesis, resulting in redirection of carbon flux during nitrogen limitation from amino acids to lipids. Lipid accumulation in _Y. lipolytica_ at nitrogen limitation is similar to the overflow metabolism observed in many other microorganisms, e.g. ethanol production by Sacchromyces cerevisiae at nitrogen limitation.

- Model KeyWords

**GEM Category:** Species; **Utilisation:** experimental data reconstruction; **Field:** metabolic-network reconstruction; **Type of Model:** curated; **Model Source:** [yeast-GEM](https://github.com/SysBioChalmers/yeast-GEM); **Omic Source:** [Transcriptomics](http://www.ebi.ac.uk/arrayexpress/experiments/E-MTAB-5284/), [Proteomics](https://doi.org/10.6084/m9.figshare.4990394.v1), [Metabolomics](https://doi.org/10.6084/m9.figshare.4990394.v1); **Taxonomy:** Yarrowia lipolytica W29; **Metabolic System:** General Metabolism; **Bioreactor**; **Strain:** W29; **Condition:** Minimal medium;

- Reference:  
>Kerkhoven EJ, Pomraning KR, Baker SE, Nielsen J (2016) "Regulation of amino-acid metabolism controls flux to lipid accumulation in _Yarrowia lipolytica_." npj Systems Biology and Applications 2:16005. doi:[10.1038/npjsba.2016.5](http://www.nature.com/articles/npjsba20165)

- Pubmed ID: 28725468

- Last update: 2018-05-18

- The model:

|Taxonomy | Template Model | Reactions | Metabolites| Genes |
| ------------- |:-------------:|:-------------:|:-------------:|-----:|
|Yarrowia lipolytica W29 | yeast-GEM | 1924 | 1671 | 847 |


This repository is administered by [@edkerk](https://github.com/edkerk/), Division of Systems and Synthetic Biology, Department of Biology and Biological Engineering, Chalmers University of Technology

## Installation

### Recommended Software:
* A functional Matlab installation (MATLAB 7.3 or higher).
* [RAVEN Toolbox 2](https://github.com/SysBioChalmers/RAVEN) for MATLAB (required for contributing to development). 
* libSBML MATLAB API ([version 5.16.0](https://sourceforge.net/projects/sbml/files/libsbml/5.13.0/stable/MATLAB%20interface/)  is recommended).
* [Gurobi Optimizer for MATLAB](http://www.gurobi.com/registration/download-reg).
* For contributing to development: a [git wrapper](https://github.com/manur/MATLAB-git) added to the search path.

### Installation Instructions
* Clone the [master](https://github.com/SysBioChalmers/Yarrowia_lipolytica_W29-GEM) branch from [SysBioChalmers GitHub](https://github.com/SysBioChalmers).
* Add the directory to your Matlab path, instructions [here](https://se.mathworks.com/help/matlab/ref/addpath.html?requestedDomain=www.mathworks.com).

### Contribute To Development
1. Fork the repository to your own Github account
2. Create a new branch from [`devel`](https://github.com/SysBioChalmers/Yarrowia_lipolytica_W29-GEM/tree/devel).
3. Make changes to the model
    + [RAVEN Toolbox 2](https://github.com/SysBioChalmers/RAVEN) for MATLAB is highly recommended for making changes
    + Before each commit, run in Matlab the `newCommit(model)` function from the `ComplementaryScripts` folder, this exports the necessary `txt`, `yml` and `xml` files that can be used to track changes between different model versions
    + Make a Pull Request to the `devel` folder, including changed `txt`, `yml` and `xml` files

## Contributors
* [Eduard J. Kerkhoven](https://www.chalmers.se/en/staff/Pages/Eduard-Kerkhoven.aspx) ([@edkerk](https://github.com/edkerk)), Chalmers University of Technology, Göteborg, Sweden
