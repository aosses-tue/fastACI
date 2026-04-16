function Add_paths(misc)
% function Add_paths(misc)
%
% 1. Description:
%       Add to the MATLAB path all the directories specified in 'misc'
% 
% 2. Stand-alone example:
%       misc = Get_TUe_paths;
%       Add_paths(misc);
%   
% 3. Additional info:
%       Tested cross-platform: No
%
% Programmed by Alejandro Osses, HTI, TU/e, the Netherlands, 2014-2015
% Created on    : 13/05/2014
% Last update on: 13/05/2014 
% Last use on   : 31/03/2015 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fields = fieldnames(misc);

for i = 1:length(fields)
    try
        if strcmp( misc.(fields{i})(end) , filesep)
            addpath(misc.(fields{i}))
            disp(['Added to path: ' fields{i}])
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['EOF: ' mfilename '.m'])
