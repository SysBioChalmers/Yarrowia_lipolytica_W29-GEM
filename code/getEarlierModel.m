function model = getEarlierModel(version,unversion)
% getEarlierModel
%   Obtain an earlier model version from the Git repository. If no output
%   is specified, it will keep the file as _earlierModel.xml in the current
%   directory, otherwise it will return the model as loaded by importModel.
%
%   Input:
%   version     string of either 'main' for latest release, or e.g. 
%               '4.1.2' for a specific release.
%   unversion   logical whether version information should be stripped from
%               the model (opt, default false, only applies if output is
%               specified)
%
%   Output:
%   model       model structure from obtained model (opt)
%
%   Usage: model = getEarlierModel(version,unversion)

nargoutchk(0,1)
if nargin<2
    unversion = false;
end

if strcmp(version,'main')
    status=system('git show main:model/iYali.xml > _earlierModel.xml')
    if status~=0
        disp('Trying legacy ''ModelFiles/xml/iYali.xml'' instead.')
        status=system('git show main:ModelFiles/xml/iYali.xml > _earlierModel.xml')
        if status~=0
            delete('./_earlierModel.xml')
            error('Failed to obtain the desired model version.');
        end
    end
elseif regexp(version,'^\d+\.\d+\.\d+$')
    tagpath = ['refs/tags/' version ':model/iYali.xml'];
    status=system(['git show ' tagpath ' > _earlierModel.xml']);
    if status~=0
        disp('Trying legacy ''ModelFiles/xml/iYali.xml'' instead.')
        tagpath = ['refs/tags/' version ':ModelFiles/xml/iYali.xml'];
        status=system(['git show ' tagpath ' > _earlierModel.xml']);
        if status~=0
            delete('./_earlierModel.xml')
            error('Failed to obtain the desired model version.');
        end
    end
else
    error('''version'' should be either ''main'' or of the format ''4.1.2''.')
end
switch nargout
    case 0
        disp('Earlier model version is stored as ''_earlierModel.xml'' in the current working directory')   
    case 1
        disp('Loading earlier model version.')
        model=importModel('_earlierModel.xml');
        if unversion==true
            model.description='iYali';
        end
        delete('_earlierModel.xml');
end
