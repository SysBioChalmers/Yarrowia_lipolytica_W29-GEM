%% Curations for release version 4.2.0
% This script combines various curations on iYali v4.1.2 to produce v4.2.0.
% Indicated is which issues are solved, more detailed explanation is given
% in the relevant pull requests.

%% Define root of repository, requires git to be installed
[status,root]=system('git rev-parse --show-toplevel');
if status~=0; error('Unable to determine root of repository, is Git installed?')
else; root(end)=[]; end; clear status

%% Load iYali
cd([root, '/code'])
model = getEarlierModel('4.1.2'); % Modify to fit relevant model version

%% Contributes to Issue #2
% Transfer annotations from yeast-GEM to iYali whenever possible
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

%% Fixes Issue #yy
% Multiple issues can be fixed in one release, but keep the code separate so
% it can easily be traced back to the relevant issue.

%% Prepare necessary files before making pull-request to the `devel` branch
cd([root, '/code'])
newCommit(model)
%% Script to convert iYali 4.1.2 to 4.3.0.

