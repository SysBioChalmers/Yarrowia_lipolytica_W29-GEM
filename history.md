# History

### Next Release
- Annotation
  - Infer metabolite and reaction annotation to MetaNetX by matching IDs to yeast-GEM 8.3.2.
  - Proceed to infer metabolite and reaction annotation to KEGG, BiGG and Biocyc from the MetaNetX 3.1
    releases `chem_xref.tsv` and `reac_xref.tsv`.

### iYali v4.1.1: fix SBML, standardized repo
- Curation:
  - most chemical formulae are without brackets.
  - remove reactions that were not connected to remaining network and had no gene annotation
  - partial correct KEGG and subSystem annotations
  - correct metabolite charge and annotations
- Refactoring:
  - `fbc_label` is now specified for each gene.
  - `x_BIOMASS` is set as default objective function.
  - move towards a standardized format of versioning, inspired by `yeast-GEM`, including not tracking binaries in `devel`
- New features:
  - scripts `newCommit` and `newRelease` for updating repository.
  - add `.gitignore`.

### iYali v4.1.0: significant update by new reconstruction

- Model is completely reconstructed from scratch, using Yeast 7.6 as template.
- Standardized reaction IDs are introduced, referencing where the reaction came from (y0 is derived from yeast concensus network, y1 is modified from yeast concensus network, y2 is from other Yarrowia lipolytica reconstructions, y3 is manual curation).
- Gap-filling during model reconstruction was automated via MENECO. Some reactions from the previous model that were identified through gap-filling are omitted in this version.

### iYali v4.0.3: correct grRules, metFormula, additional annotation
- Curation:
  - removed incorrect annotation of FAD:ubiquinone oxidoreductse (yli0053), while allowing flux through NADH:ubiquinone oxidoreductse (773).
  - some complex grRules were incorrect.
  - some metFormula gave error message when loaded as SBML.
  - cytosolic and mitochondrial branched-chain amino-acid transaminases are encoded by different genes (BAT2 and BAT1, respectively).
  - metabolite annotation (InChi, ChEBI, KEGG) that were previously lost during conversion from RAVEN to COBRA format are now included by exporting the file in RAVEN format. This format is now fully COBRA compatible.

### iYali v4.0.2: correct energetics, SBML L3V1 FBCv2
- Curation:
  - changed equations of complex III, IV and V of oxidative phosphorylation to correct the transport of protons over the mitochondrial membrane (reactions 226, 438, 439). This was incorrectly represented in the template model.
  - made asparate transport over the mitochondrial membrane irreversible (reaction 1117), otherwise this would transport protons for 'free' over the mitochondrial membrane. This was already identified in the Yeast consensus network.
- Refactoring:
  - updated SBML to L3V1 with FBCv2, also using updated RAVEN functions. This changed the compartment IDs slightly (removed C_). Amended README.md to reflect the changes.

### iYali v4.0.1: corrected metabolite names
- Fixes:
  - corrected metabolite names: due to an error in model generation, some of the metabolite names were appended with "_ActiveX VT_ERROR:"

### iYali v4.0.0: published model
This is the model as published in
>Kerkhoven EJ, Pomraning KR, Baker SE, Nielsen J (2016) "Regulation of amino-acid metabolism controls flux to lipid accumulation in _Yarrowia lipolytica_." npj Systems Biology and Applications 2:16005. doi:[10.1038/npjsba.2016.5](http://www.nature.com/articles/npjsba20165)
