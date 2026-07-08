%% Curations for release version 5.0.0 (iYali5)
% Applies to the iYali 4.1.2 release and produces iYali5.
%
% This script now carries TWO bodies of curation:
%
%   (1) Section 1: transfer of annotations from yeast-GEM (Issue #2). This was
%       previously staged on `devel` as code/curation/v4_2_0.m. Version 4.2.0
%       has since been reallocated to reproducing iYali4_corr (Xu, Holic, Hua
%       2020) -- see docs/iYali_curation_release_plan_v2.md -- so the
%       annotation work is folded in here instead and v4_2_0.m is retired.
%
%   (2) Sections 2-8: the curations of the eciYali5-GEM reconstruction
%       (Debiaggi et al., 2025; code/debiaggi2025/generate_iYali5GEM.m).
%       The original script mixes COBRA and RAVEN calls and operates on the
%       divergent 'iYali4_corr' lineage, whose bare-numeric IDs (e.g. '719',
%       '336u', 'm294') do not exist in iYali. Every curation below has
%       therefore been re-mapped to iYali's own IDs (y0##### reactions,
%       s_#### metabolites) and verified against iYali by reaction/metabolite
%       *identity* (name and formula), not by ID.
%
% Curations from the reference that are intentionally NOT applied here:
%   * Restore malic enzyme (NADP) / rename malic enzyme (NAD): iYali already
%     has y000719 '(S)-malate + NADP -> CO2 + NADPH + pyruvate' (GPR
%     YALI0E18634g) and y000718 'malic enzyme (NAD)'. Already correct.
%   * Add glycerol-3-phosphate dehydrogenase (FAD): iYali already has y000490
%     with the same gene (YALI0B13970g). Already present.
%   * ADH/ICDH reversibility (163/165/658): already irreversible in iYali.
%   * Remove methylglyoxal synthase and old biomass equations: absent in iYali.
%   * Un-block 495/2512g/275u/277u/3789g/8u: already open (ub 1000) in iYali.
%   * Block glucose uptake / enable glycerol uptake (1714/1808): these are
%     simulation conditions specific to the glycerol study, not general
%     curations, and are left to the user's simulation set-up.
%   * Add lipid pool exchange for FSEOF: an analysis convenience, not a
%     model curation.
%   * GPR/rename of 'iYL0459' (phosphoribosylglycinamide formyltransferase)
%     and GPR of 'yli0053': the corresponding reactions could not be matched
%     by identity in iYali (iYali has the distinct enzyme y000912
%     'phosphoribosylaminoimidazolecarboxamide formyltransferase'). Skipped
%     to avoid editing the wrong reaction.

%% Define root of repository, requires git to be installed
[status,root]=system('git rev-parse --show-toplevel');
if status~=0; error('Unable to determine root of repository, is Git installed?')
else; root(end)=[]; end; clear status

%% Load iYali
cd([root, '/code'])
model = getEarlierModel('4.1.2',true); % iYali5 is built on the 4.1.2 release

%% 1. Contributes to Issue #2: inherit annotations from yeast-GEM
% (Previously code/curation/v4_2_0.m; folded in here unchanged.)
% Transfer annotations from yeast-GEM to iYali whenever possible.
% Download yeast-GEM v8.4.2
websave('yeastGEM.xml','https://github.com/SysBioChalmers/yeast-GEM/raw/c2cf046e225077097beacf37fe1a64cb38e281b3/ModelFiles/xml/yeastGEM.xml');
modelSce = importModel('yeastGEM.xml');
delete('yeastGEM.xml');

% Map yeast-GEM and iYali reactions and metabolites
model.rxns=strrep(model.rxns,'y00','r_'); % Revert to yeast-GEM reaction IDs
[a,b]=ismember(model.rxns,modelSce.rxns);
model.rxnMiriams(a)=modelSce.rxnMiriams(b(a));

modelSce.mets=regexprep(modelSce.mets,'\[.*\]',''); % Remove compartments from metabolite IDs
[a,b]=ismember(model.mets,modelSce.mets);
model.metMiriams(a)=modelSce.metMiriams(b(a));

model.rxns=strrep(model.rxns,'r_','y00'); % Return reaction IDs to iYali format

% Remove duplicate SBO terms
modelC = ravenCobraWrapper(model);
modelC.metSBOTerms=regexprep(modelC.metSBOTerms,'SBO:\d+;SBO','SBO');
modelC.rxnSBOTerms=regexprep(modelC.rxnSBOTerms,'SBO:\d+;SBO','SBO');
modelC = rmfield(modelC,'rxnReferences');
modelC = ravenCobraWrapper(modelC);
model.metMiriams = modelC.metMiriams;
model.rxnMiriams = modelC.rxnMiriams;
clear modelC modelSce a b

%% 2. Reaction removals
% Acyl-dihydroxyacetonephosphate reductase (iYali y200009; reference iYL0336).
% There is no evidence that Yarrowia encodes this enzyme: it carries no GPR
% and cannot be found in Yarrowia's UniProt.
model = removeReactions(model,'y200009',false,false,false);

%% 3. Non-native / mislocalised enzyme activities (blocked, lb = ub = 0)
% Cytosolic aconitase and aconitate hydratase. The GPRs point to a
% mitochondrial enzyme in UniProt, so the cytosolic copies are yeast-GEM
% artifacts (y000303 'citrate to cis-aconitate, cytoplasmic';
% y002305 'cis-aconitate to isocitrate').
model = setParam(model,'eq',{'y000303','y002305'},0);

% Isocitrate dehydrogenase is only mitochondrial in Yarrowia
% (doi:10.1007/s12010-013-0373-1); the cytosolic (y000659) and peroxisomal
% (y000661) NADP reactions are yeast-GEM artifacts.
model = setParam(model,'eq',{'y000659','y000661'},0);

% Cytosolic aldehyde dehydrogenases are probably unused (y000173 'aldehyde
% dehydrogenase (acetaldehyde, NADP)'; y002116 'acetaldehyde dehydrogenase').
model = setParam(model,'eq',{'y000173','y002116'},0);

% Glycerol dehydrogenase (y000487) is not native to Yarrowia.
model = setParam(model,'eq','y000487',0);

%% 4. Reaction reversibility / bounds
% The diacylglycerol acyltransferases are not reversible; close the lower
% bound (y000336 'diacylglycerol acyltransferase'; y102884 'PE diacylglycerol
% acyltransferase'; y102948 'PC diacylglycerol acyltransferase').
model = setParam(model,'lb',{'y000336','y102884','y102948'},0);

%% 5. Reaction name fixes
% y000027 is homocitrate -> cis-homoaconitate + H2O, i.e. homoaconitase
% (lysine biosynthesis), currently mislabelled '2-methylcitrate dehydratase'.
model.rxnNames(strcmp(model.rxns,'y000027')) = {'homoaconitase'};
% y000117 is 2-methylcitrate -> 2-methylisocitrate, i.e. the methylcitrate
% pathway, currently mislabelled 'aconitase'.
model.rxnNames(strcmp(model.rxns,'y000117')) = {'2-methylcitrate dehydratase'};

%% 6. Gene-reaction association refinements
% All GPR edits use the core RAVEN function changeGrRules (default replace).
% Pyruvate carboxylase (y000958): drop the co-assigned gene that encodes an
% enzyme of different function; keep PYC (YALI0C24101g).
model = changeGrRules(model,'y000958','YALI0C24101g');

% Aromatic aminotransferases: both proteins catalyse the reaction
% (doi:10.1111/1751-7915.13745). y002117 phenylalanine transaminase,
% y002119 tyrosine transaminase (same rule applied to both).
model = changeGrRules(model,{'y002117','y002119'},'YALI0C05258g or YALI0E20977g');

% Phosphatidylinositol 3-kinase (y000923): remove the extra gene from the
% complex, keep YALI0F09559g.
model = changeGrRules(model,'y000923','YALI0F09559g');

% Diacylglycerol acyltransferase (y000336): add DGA2 (YALI0D07986g), which
% was missing, to the existing DGA1 (YALI0E32769g).
model = changeGrRules(model,'y000336','YALI0E32769g or YALI0D07986g');

% Cytosolic alcohol dehydrogenase to ethanol (y002115): keep only the protein
% with greatest homology to S. cerevisiae ADH1, shown experimentally to be
% the only yeast ADH that metabolises acetaldehyde
% (doi:10.1111/j.1567-1364.2011.00760.x).
model = changeGrRules(model,'y002115','YALI0A16379g');

% Mitochondrial alcohol dehydrogenase (y000165): remove genes of low homology
% (per UniProt), keep YALI0F29623g.
model = changeGrRules(model,'y000165','YALI0F29623g');

% Aldehyde dehydrogenase family: assign genes per specific activity.
adhRxns = {'y000172';'y000173';'y000174';'y000175';'y000201';'y002116'};
adhGrRules = {'YALI0D07942g or YALI0F04444g'; ... % 172 3-aminopropanal, NAD
    'YALI0C03025g'; ...                           % 173 acetaldehyde, NADP
    'YALI0E00264g'; ...                           % 174 acetaldehyde, NAD
    'YALI0E00264g'; ...                           % 175 acetaldehyde, NADP
    'YALI0D07942g or YALI0F04444g'; ...           % 201 aminobutyraldehyde
    'YALI0D07942g or YALI0F04444g'};              % 2116 acetaldehyde dehydrogenase
model = changeGrRules(model,adhRxns,adhGrRules);

%% 7. Data cleanup: merge duplicate metabolites
% iYali 4.1.2 carries three legacy metabolites (m600, m601, m887) that are
% the same compound (identical name and compartment) as the yeast-GEM
% metabolites s_0337, s_0339 and s_1188, but under a second ID. Because the
% two IDs are used by different reactions, two pathways are split across the
% duplicate: GPI-anchor assembly (step 6 makes s_0337 but step 7 consumes
% m600; step 7 makes m601 but step 8 consumes s_0339) and the
% phosphopantothenoylcysteine node (s_1188 vs m887). Merge each legacy
% metabolite into its yeast-GEM counterpart, which reconnects both pathways
% and also removes the duplicate names that otherwise block xml/yml export.
model = replaceMets(model,'m600','s_0337',false,true);
model = replaceMets(model,'m601','s_0339',false,true);
model = replaceMets(model,'m887','s_1188',false,true);

%% 8. Biomass equation restructuring
% Modularise the lumped xBIOMASS into RNA, DNA and carbohydrate pseudo-
% reactions (protein and lipid pools already exist via xAMINOACID -> m1726
% and xLIPID -> m1727), matching the pool-based architecture of iYali5 that
% RAVEN's sumBioMass and GECKO expect. The stoichiometric coefficients are
% taken verbatim from the current xBIOMASS, so the overall composition, the
% growth-associated maintenance (86.7881 ATP -> ADP + phosphate) and the
% biomass molecular weight are unchanged; no rescaling or GAM recalculation
% is required.

% Pool pseudometabolites (cytosol)
metsToAdd.mets         = {'m1836','m1837','m1838'};
metsToAdd.metNames     = {'carbohydrate','DNA','RNA'};
metsToAdd.compartments = {'c','c','c'};
metsToAdd.metNotes     = repmat({['Pseudometabolite for biomass equation. ' ...
    'Necessary for sumBioMass of RAVEN-based GEMs']},1,3);
model = addMets(model, metsToAdd);

% Pool pseudoreactions
rxnsToAdd.rxns         = {'xCARBOHYDRATE';'xDNA';'xRNA'};
rxnsToAdd.rxnNames     = {'carbohydrate pseudoreaction'; ...
    'DNA pseudoreaction';'RNA pseudoreaction'};
rxnsToAdd.mets         = { ...
    {'s_0509','s_1520','s_0002','s_1107','m1836'}; ... % chitin, trehalose, glucan, mannan
    {'s_0584','s_0589','s_0615','s_0649','m1837'}; ... % dAMP, dCMP, dGMP, dTMP
    {'s_0423','s_0526','s_0782','s_1545','m1838'}};    % AMP, CMP, GMP, UMP
rxnsToAdd.stoichCoeffs = { ...
    [-0.4068, -0.0032, -0.4415, -0.1104, 1]; ...
    [-0.0383, -0.0377, -0.0377, -0.0383, 1]; ...
    [-0.0757, -0.0578, -0.0930, -0.0623, 1]};
rxnsToAdd.lb           = [0;0;0];
rxnsToAdd.ub           = [1000;1000;1000];
model = addRxns(model, rxnsToAdd, 1, [], false);

% Rewrite xBIOMASS to consume the pools instead of the individual precursors.
equations.mets = {{'s_0434','m1836','m1837','m1838','m1726','m1727', ...
    's_0394','s_1322','s_0450'}};
equations.stoichCoeffs = {[-86.7881, -1, -1, -1, -1, -1, 86.7881, 86.7881, 1]};
model = changeRxns(model, {'xBIOMASS'}, equations, 1);
model.rxnNames(strcmp(model.rxns,'xBIOMASS')) = {'biomass pseudoreaction'};

% Note: the reference additionally renames xAMINOACID to xPROTEIN. iYali keeps
% xAMINOACID (it already produces the protein pool m1726); renaming an
% established reaction ID is avoided here to preserve downstream references.

%% Verify growth is preserved and set objective
model = setParam(model, 'obj', 'xBIOMASS', 1);
sol = solveLP(model, 1);
fprintf('Growth (xBIOMASS) flux after curation: %.6f\n', abs(sol.f));

%% Prepare necessary files before making pull-request to the `devel` branch
cd([root, '/code'])
newCommit(model)
