%% Curations for release version x.y.z
% This script combines various curations on iYali vx.y.y to produce vx.y.z.
% Indicated is which issues are solved, more detailed explanation is given
% in the relevant pull requests.

%% Define root of repository, requires git to be installed
[status,root]=system('git rev-parse --show-toplevel');
if status~=0; error('Unable to determine root of repository, is Git installed?')
else; root(end)=[]; end; clear status

%% Load iYali
cd([root, '/code'])
model = getEarlierModel('4.1.1'); % Modify to fit relevant model version

%% Fixes Issue #xx
% Include code here that fixes the issue. If there is a lot of code, or
% whenever relevant for other reasons, you can also call other scripts from
% here.

%% Fixes Issue #yy
% Multiple issues can be fixed in one release, but keep the code separate
% so it can easily be traced back to the relevant issue.

%% Prepare necessary files before making pull-request to the `devel` branch
cd([root, '/code'])
newCommit(model)
