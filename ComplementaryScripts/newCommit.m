function newCommit(model)
% newCommit
%   Prepares a new commit of the iYali model in a development branch, for
%   direct submission to GitHub. In contrast to new releases, new commits
%   in development branches do not contain .mat and .xlsx files. This
%   function should be run from the ComplementaryScripts directory.
%
%   model   RAVEN model structure to be used in commit. If no model
%           structure is provided, the stored XML file will be imported
%           prior to exporting other files
%
% Eduard Kerkhoven, 2018-15-08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Check if in master:
currentBranch = git('rev-parse --abbrev-ref HEAD');
if strcmp(currentBranch,'master')
    error('ERROR: in master branch. For new releases, use newRelease.m')
end

if ~exist('model')
    %Load model:
    model = importModel('../ModelFiles/xml/iYali.xml');
end

%Save model
exportForGit(model,'iYali','../',{'txt', 'xml', 'yml'});
end