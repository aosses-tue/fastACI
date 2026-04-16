% Author: Leo Varnet
% This is an inherited script from the original ACI toolbox

if isfield(cfg_game,'expvar_description')
    expvar_description = [', ' cfg_game.expvar_description];
else
    expvar_description = '';
end

switch cfg_game.Language
    case 'EN'
        
    case 'FR'
        
end
clc
switch cfg_game.Language
    case 'EN'
        fprintf('\n\t*** MAIN EXPERIMENT ***\n\n');
        fprintf('\tPlaying stimulus # %.0f of %.0f (Next session stop in %.0f trials)\n',i_current,cfg_game.N_trials,N_for_next_stop);
        if cfg_game.feedback == 1
            fprintf('\tDependent variable: expvar = %.2f%s \n',expvar,expvar_description);
        end %% should extend to bias?
        fprintf('\n');
        
        if cfg_game.adapt
            N_here = min(i_current-1,100);
            if i_current>10 && cfg_game.intervalnum == 1 % don't plot information about bias if more than one interval
                if N_here < 100 && cfg_game.is_simulation
                    fprintf('Averaging first %.0f trials\n',N_here);
                end
                response_biases = 100*sum(data_passation.n_responses(end-N_here+1:end)==[1 2 3]',2)/N_here;
                if cfg_game.is_simulation == 1
                    % Extra info for the simulations:
                    for i_responses = 1:length(cfg_game.response_names)
                        fprintf('\tPercentage of "%s" responses: %.1f %%\n',cfg_game.response_names{i_responses},response_biases(i_responses));% plot all biases
                    end
                    fprintf('\tPercentage of correct responses: %.1f %%\n',100*sum(data_passation.is_correct(end-N_here+1:end)==1)/N_here);
                else
                    if i_current > 100
                        [max_response_bias,i_max] = max(response_biases);
                        [min_response_bias,i_min] = min(response_biases);
                        targeted_bias = 100/length(cfg_game.response_names);
                        if max_response_bias>targeted_bias+10 % previously: bias_r1>60
                            fprintf('\tPercentage of "%s" responses = %.0f %% (too much "%s") \n',cfg_game.response_names{i_max},max_response_bias,cfg_game.response_names{i_max});
                        elseif min_response_bias<targeted_bias-10 % previously: bias_r1<40
                            fprintf('\tPercentage of "%s" responses = %.0f %% (not enough "%s") \n',cfg_game.response_names{i_min},min_response_bias,cfg_game.response_names{i_min});
                        else
                            %fprintf('\tResponses are normally balanced \n');
                        end
                    end
                end
            end
        end
        
    case 'FR'
        fprintf('\n\t*** EXP\311RIENCE PRINCIPALE ***\n\n');
        fprintf('\t\311coute num\351ro %.0f sur %.0f -- Prochaine pause dans %.0f \351coutes\n',i_current,cfg_game.N_trials,N_for_next_stop);
        if cfg_game.feedback == 1
            fprintf('\tVariable dépendante : expvar = %.2f%s \n',expvar,expvar_description);
        end

        if cfg_game.adapt
            N_here = min(i_current-1,100);
            if i_current>10 && cfg_game.intervalnum == 1 % don't plot information about bias if more than one interval
                if N_here < 100 && cfg_game.is_simulation
                    fprintf('Moyenner %.0f essais avant de calculer le biais\n',N_here);
                end
                response_biases = 100*sum(data_passation.n_responses(end-N_here+1:end)==[1 2 3]',2)/N_here;
                if cfg_game.is_simulation == 1
                    % Extra info for the simulations:
                    for i_responses = 1:length(cfg_game.response_names)
                        fprintf('\tPourcentage de r\351ponses "%s" : %.1f %%\n',cfg_game.response_names{i_responses},response_biases(i_responses));% plot all biases
                    end
                    fprintf('\tPourcentage de r\351ponses correctes: %.1f %%\n',100*sum(data_passation.is_correct(end-N_here+1:end)==1)/N_here);
                else
                    if i_current > 100
                        [max_response_bias,i_max] = max(response_biases);
                        [min_response_bias,i_min] = min(response_biases);
                        targeted_bias = 100/length(cfg_game.response_names);
                        if max_response_bias>targeted_bias+10 % previously: bias_r1>60
                            fprintf('\tPourcentage de r\351ponses "%s" : %.1f %% (trop de "%s") \n',cfg_game.response_names{i_max},max_response_bias,cfg_game.response_names{i_max});
                        elseif min_response_bias<targeted_bias-10 % previously: bias_r1<40
                            fprintf('\tPourcentage de r\351ponses "%s" : %.1f %% (trop peu de "%s") \n',cfg_game.response_names{i_min},min_response_bias,cfg_game.response_names{i_min});
                        else
                            %fprintf('\tPourcentages de r\351ponses normaux \n',cfg_game.response_names{1},cfg_game.response_names{2});
                        end
                    end
                end
            end
        end

end
fprintf('\n');
