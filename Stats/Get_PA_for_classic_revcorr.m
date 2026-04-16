function FitInfo = Get_PA_for_classic_revcorr(ACI,Data_matrix,y)
% function FitInfo = Get_PA_for_classic_revcorr(ACI,Data_matrix,y)
%
% This script calculates the mean square error (MSE) or the percentage of
%  Each row of Data_matrix is a different trial
%  y - expected output
% PC - output variable
%
% Author: Alejandro Osses and the fastACI team
% Date: 2021-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[N,M] = size(ACI);
for i_trial = 1:size(Data_matrix,1)
    
    TF_trial = reshape(Data_matrix(i_trial,:),N,M);
    
    % rp(i_trial) = corr(ACI(:),TF_trial(:),'type','Pearson');
    rp(i_trial) = sum(ACI(:).*TF_trial(:));
    if rp(i_trial) >= 0
        Decision(i_trial)=1;
    else
        Decision(i_trial)=0;
    end
end
PC = mean(Decision(:)==y(:));

FitInfo.PC = PC;
%%%
% yref = y(idx_train_or_test); % reference values
% n_of_trials = 1; % 
% pdf_train_or_test = binopdf(yref,n_of_trials,yhat)
% pdf_saturated     = binopdf(yref,n_of_trials,yref) % saturated model?

% lassoglmslow
% Dev_t = -2*(log(binopdf(y(idx_train_or_test),1,yhat))) - sum(log(binopdf(y(idx_train_or_test),1,y(idx_train_or_test))));
% Dev   = sum(Dev_t);
