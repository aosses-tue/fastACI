function Show_cell(in)
% function Show_cell(in)
%
% 1. Description:
%       Displays the content of each cell stored in the variable 'in';
% 
% 2. Stand-alone example:
%       cell_variable = {'element1','element2','element3'};
%       Show_cell(cell_variable);
% 
% 3. Additional info:
%       Tested cross-platform: Yes
%
% Programmed by Alejandro Osses, HTI, TU/e, the Netherlands, 2014-2017
% Created on    : 12/04/2016
% Last update on: 03/03/2021  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[N, M] = size(in);

for j = 1:M
    for i = 1:N
        if ischar( in{i,j} ) % isstr replaced by ischar for compatibility with newer versions
            
            if N == 1
                fprintf('(%.0f): %s\n', j,in{i,j});
            elseif M == 1 % && bShown == 0
                fprintf('(%.0f): %s\n', i,in{i,j});
            else
                fprintf('(%.0f,%.0f): %s\n', i,j,in{i,j});
            end
            
        elseif isnumeric( in{i,j} )
            fprintf('(%.0f,%.0f): %.4f\n', i,j,in{i,j});
        end
    end
end
