function outcell = Cell_sum(cell1,cell2)
% function outcell = Cell_sum(cell1,cell2)
%
% Author: Alejandro Osses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outcell = cell(size(cell1));
for i = 1:length(cell1)
    
    outcell{i} = cell1{i}+cell2{i};
    
end
