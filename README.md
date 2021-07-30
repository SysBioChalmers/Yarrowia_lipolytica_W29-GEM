### Yarrowia_lipolytica_W29-GEM: Genome-scale model of _Yarrowia lipolytica_

### Description

This repository contains the current genome-scale metabolic model **iYali** for the oleaginous yeast _Yarrowia lipolytica_ W29, among others a promising microbial cell factory for the production of oleochemicals and various other products.

### Citation

>Kerkhoven EJ, Pomraning KR, Baker SE, Nielsen J (2016) "Regulation of amino-acid metabolism controls flux to lipid accumulation in _Yarrowia lipolytica_." npj Systems Biology and Applications 2:16005. doi:[10.1038/npjsba.2016.5](http://www.nature.com/articles/npjsba20165) / pubmed:[28725468](https://pubmed.ncbi.nlm.nih.gov/28725468/)

The iYali model distributed on this GitHub repository is continuously updated, with the latest releases available [here](https://github.com/SysBioChalmers/Yarrowia_lipolytica_W29-GEM/releases). To get access to the model associated to the Kerkhoven _et al_. (2016) publication, use [iYali release 4.0.0](https://github.com/SysBioChalmers/Yarrowia_lipolytica_W29-GEM/releases/tag/4.0.0).

### Keywords

**Utilisation:** Experimental data reconstruction; Predictive simulation
**Field:** Metabolic-network reconstruction
**Type of Model:** Curated reconstruction
**Model Source:** [yeast-GEM](https://github.com/SysBioChalmers/yeast-GEM)
**Omic Source:** [Transcriptomics](http://www.ebi.ac.uk/arrayexpress/experiments/E-MTAB-5284/), [Proteomics](https://doi.org/10.6084/m9.figshare.4990394.v1), [Metabolomics](https://doi.org/10.6084/m9.figshare.4990394.v1)
**Taxonomic name:** Yarrowia lipolytica W29
**Taxonomic ID:** [taxonomy:100226](https://identifiers.org/taxonomy:4952)
**Metabolic System:** General Metabolism
**Strain:** W29
**Condition:** Minimal medium

### Model Overview

| Taxonomy | Latest change | Version | Reactions | Metabolites | Genes |
| ------------- |:-------------:|:-------------:|:-------------:|:-------------:|:-----:|
| _Yarrowia lipolytica_ W29 | 04-Apr-2021 | 4.1.2 | 2599 | 2065 | 1775 |

## Installation & Usage

### **User:**

To obtain iYali, clone it from [`main`](https://github.com/sysbiochalmers/Yarrowia_lipolytica_W29-GEM) in the GitHub repository, or just download the [latest release](https://github.com/sysbiochalmers/Yarrowia_lipolytica_W29-GEM/releases).

iYali is distributed in SBML L3V1 FBCv1 format (`model/iYali.xml`), and therefore works well with any appropriate constraint-based modelling package, such as [RAVEN Toolbox](https://github.com/sysbiochalmers/raven/), [cobrapy](https://github.com/opencobra/cobrapy),  and [COBRA Toolbox](https://github.com/opencobra/cobratoolbox). Installation instructions for each package are provided on their website, after which you can use their default functions for loading and exporting of the models:

***RAVEN Toolbox***
```matlab
model = importModel('iYali.xml')
exportModel(model, 'iYali.xml')
```

***cobrapy***
```python
import cobra
model = cobra.io.read_sbml_model('iYali.xml')
cobra.io.write_sbml_model(model, 'iYali.xml')
```

***COBRA Toolbox*** \*
```matlab
model = readCbModel('iYali.xml')
writeCbModel(model, 'iYali.xml')
```
\* note that some annotation might be lost when exporting the model from COBRA Toolbox.

### **Contributor:**

Development of the model is done via RAVEN, to ensure that model content is retained as much as possible (I/O through other software might result in undesired loss of annotation).

[Fork](https://github.com/sysbiochalmers/Yarrowia_lipolytica_W29-GEM/fork) the iYali repository to your own GitHub account, and create a new branch from `devel`.

Load the model in MATLAB using the default code specified [above](#user). Before making a pull-request to the `devel` branch, export the model with the `newCommit` function provided in the repository:
```matlab
cd ./code
newCommit(model);
```

More information on contributing to iYali can be found in the [contributing guidelines](.github/CONTRIBUTING.md), read these to get started. Contributions are always welcome!

### Contributors
* [Eduard J. Kerkhoven](https://www.chalmers.se/en/staff/Pages/Eduard-Kerkhoven.aspx) ([@edkerk](https://github.com/edkerk)), Chalmers University of Technology, Sweden
