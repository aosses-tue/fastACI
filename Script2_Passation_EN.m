function Script2_Passation_EN(experiment, Subject_ID)
% function Script2_Passation_EN(experiment, Subject_ID)
%
%
% Changes by AO:
%   - cfg_game.resume set to 1 (for oui) or 0 (for non)
%   - cfg_game.ordre_aleatoire renamed to 'randorder_idxs'
%   - init_staircase.m renamed to staircase_init.m
%
% TODO:
%   - bSimulation: convert to some option 'artificial_observer'...
%   - Move init_staircase.m to a predefined folder...
%   - Each experiment should have msg_warmup, msg_instructions, msg_mainexp
%   - istarget = (ListStim(n_stim).N_signstartdateal)==2; % in this line it is assumed a 1-I AFC, change in procedures...
%   - convert displayN to silent or something comparable...
%
% TOASK:
%   - 10^(m_dB/10) seems not to be the typical definition of depth
%   - Add an additional variable 'dir_results' (splitting dir_main)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup

if nargin < 1
    Subject_ID = input('Enter the Subject ID (e.g., ''S01''): ');
end
if nargin == 0
    experiment = 'modulationACI'; 
end

% close all
% clc

bSimulation = 0;
bDebug      = 1;

% -------------------------------------------------------------------------
% 1. Loading set-up: 
%    1.1. Loads cfgcrea*.mat
[path,name,ext]=fileparts(which(mfilename)); % path will be the folder where this file is located...
dir_main = [path filesep];    %'C:\Users\Varnet L�o\Dropbox\Professionnel\Matlab\MyScripts\modulationACI\AM';
dir_results = [dir_main 'Interim_results' filesep];

stored_cfg = Get_filenames(dir_results,['cfgcrea*' Subject_ID '_' experiment '.mat']);
N_stored_cfg = length(stored_cfg);
if N_stored_cfg==1
    var      = load([dir_results stored_cfg{1}]);
    cfg_game = var.cfg_crea;
    % cfg_game.cfg_crea   = var.cfg_crea;
elseif N_stored_cfg > 1
    error('Multiple participants option: has not been validated yet (To do by AO)')
else
    error('%s: no cfg_crea available',upper(mfilename));
end
cfg_game.N = cfg_game.N_noise*cfg_game.N_signal;

if ~isfield(cfg_game,'resume')
    cfg_game.resume = []; % 'no' -> new game, 'yes' -> load last saved game, [] -> load last saved game if exists or start a new game
end

% -------------------------------------------------------------------------
%     1.2. Loading parameters: Looks for an existing 'game' (or previous 
%          session for the same participant)
if isempty(cfg_game.resume)
    ListSavegame = dir([dir_results 'savegame*.mat']);
    if isempty(ListSavegame)
        cfg_game.resume = 0; % 'non';
    else
        cfg_game.resume = 1; % 'oui';
    end
else
	error('Not validated yet...')
end

if ~isfield(cfg_game,'load_name')
    cfg_game.load_name = [];
else
    error('Not validated yet...')
end

switch cfg_game.resume
    case {1,'oui','yes'}
        if isfield(cfg_game,'load_name')
            if isempty(cfg_game.load_name)
                ListSavegame = dir([dir_results 'savegame*.mat']);
                if isempty(ListSavegame)
                    error('%s: No savegame to be loaded',upper(mfilename));
                end
                index_savegame = 0;
                bytes = 0;
                for j=1:length(ListSavegame)
                    if ListSavegame(j).bytes > bytes
                        index_savegame=j;
                        bytes = ListSavegame(j).bytes; % looks for the largest MAT file
                    end
                end
                load_name = [dir_results ListSavegame(index_savegame).name];
            end
            
            i = [];
            cfg_game = []; % it will be re-loaded now:
            ListStim = [];
            
            load(load_name);
            cfg_game.load_name = load_name;
            i_savegame=i;
            
            % display welcome message
            msg_welcomeback
             
            cfg_game.resume = 1;
            
            if ~isfield(cfg_game,'dBFS')
                warning('You are loading an ''old'' participant')
                cfg_tmp = il_set(cfg_game);
                cfg_game.dBFS = cfg_tmp.dBFS;
                cfg_game.dir_stim = cfg_tmp.dir_stim;
            end
            if ~isfield(cfg_game,'experiment')
                cfg_game.experiment = 'modulationACI';
            end
            
            cfg_game.is_simulation =  bSimulation;
            cfg_game.is_experiment = ~bSimulation;
        else
            error('%s: No savegame with the specified name',upper(mfilename))
        end
        % cfg_game.current_folder = [cfg_game.current_folder(:)', {cd}];
        % cfg_game.script_name = [cfg_game.script_name(:)', {mfilename}];
        data_passation.resume_trial = [data_passation.resume_trial, i];
        clock_str = Get_date_and_time_str;
        data_passation.startdate = {data_passation.startdate, clock_str};
        
    case {0,'non','no'}
        if ~isfield(cfg_game,'experiment')
            cfg_game.experiment = 'modulationACI';
        end
            
        % Parameters for targets
        exp2eval = sprintf('cfg_game = %s_set(cfg_game);',experiment); % experiment dependent
        eval(exp2eval);
        
        exp2eval = sprintf('cfg_game = %s_cfg(cfg_game);',experiment);
        eval(exp2eval);
        
        % Parameters for game
        cfg_game.is_simulation =  bSimulation;
        cfg_game.is_experiment = ~bSimulation;
        % Simulation parameters
        if cfg_game.is_simulation == 1
            error('Not validated yet...')
            % modelparameters;
            % cfg_game.fadein_s           = 0;
            % cfg_game.N_template         = 0;
            % cfg_game.warmup             = 'no';
            % cfg_game.sessionsN          = 500;
            % cfg_game.stim_dur           = 0.75;
        end

    cfg_game.current_folder{1} = dir_main; % cd;
    cfg_game.script_name{1} = [mfilename('fullpath') '.m'];

    data_passation.resume_trial = 0;
    data_passation.startdate{1} = Get_date_and_time_str;

	if cfg_game.is_simulation == 1
        error('Not validated yet...')
        % % display welcome message
        % msg_welcome
	end        
end

dir_stim = cfg_game.dir_stim;
% clear temp bytes ListSavegame index_savegame clock_now
 
%% Load stims, create templates for simulation

if cfg_game.resume == 0
    ListStim = dir(strcat([dir_stim cfg_game.folder_name filesep], '*.wav'));
    
    ListStim = rmfield(ListStim,{'date','datenum','bytes', 'isdir'});
    if cfg_game.N ~= length(ListStim)
        error('Number of stimuli does not match.')
    end
    liste_signaux = [];
    for i=1:cfg_game.N_signal
        % for N_signal == 2 ==> first half equal to one, second half equal to two
        liste_signaux = [liste_signaux i*ones(1,ceil(cfg_game.N/cfg_game.N_signal))];%
    end
    for i=1:cfg_game.N
        ListStim(i).N_signal = liste_signaux(i);
    end    
end

% if ~isfield(cfg_game,'ListStim')
%     % cfg_game.ListStim = struct([]);
%     cfg_game.ListStim = ListStim;
% end

% Create template
 
if cfg_game.is_simulation == 1
    error('Not validated yet...')
    % Signal{1} = create_AM(cfg_game.fc, cfg_game.fm, 0, cfg_game.stim_dur, cfg_game.fs)';
    % Signal{2} = create_AM(cfg_game.fc, cfg_game.fm, 10^(cfg_game.m_start/10), cfg_game.stim_dur, cfg_game.fs)';
    % 
    % if cfg_game.N_template>0 
    %     cfg_game.IR{1} = 0; cfg_game.IR{2} = 0;
    %     for i=1:cfg_game.N_template
    %         fprintf(['Template: stim #' num2str(i) ' of ' num2str(cfg_game.N_template) '\n']);
    % 
    %         WavFile = strcat(cfg_game.folder_name, '/', ListStim(i).name);
    %         [noise,cfg_game.fs] = audioread(WavFile); noise = noise/std(noise);
    %         fadein_samples = cfg_game.fs*cfg_game.fadein_s;
    %         Target{1} = generate_stim( Signal{1}, noise, cfg_game.SNR, fadein_samples);
    %         Target{2} = generate_stim( Signal{2}, noise, cfg_game.SNR, fadein_samples);
    % 
    %         %plot_modep(cfg_game.fc,cfg_game.fmc, auditorymodel(Target{1}, cfg_game.fs, cfg_game.model)/cfg_game.N_template)
    % 
    %         IRind1(:,:,:,i) = auditorymodel(Target{1}, cfg_game.fs, cfg_game.model)/cfg_game.N_template; %cfg_game.IR{1} +
    %         IRind2(:,:,:,i) = auditorymodel(Target{2}, cfg_game.fs, cfg_game.model)/cfg_game.N_template; %cfg_game.IR{2} +
    %     end
    %     cfg_game.IR{1} = mean(IRind1,4);
    %     cfg_game.IR{2} = mean(IRind2,4);
    % else
    %     cfg_game.IR{1} = auditorymodel(Signal{1}, cfg_game.fs, cfg_game.model);
    %     cfg_game.IR{2} = auditorymodel(Signal{2}, cfg_game.fs, cfg_game.model);
    % end
    % %cfg_game.IR{1} = zeros(size(cfg_game.IR{2}));
    % cfg_game.Template = cfg_game.IR{2} - cfg_game.IR{1};     
end
 
%cfg_game.N = length(ListStim);
% clear liste_signaux ordre_alea i j IRind1 IRind2
 
%% Experiment
if cfg_game.resume == 0
    if cfg_game.randorder == 1
        cfg_game.randorder_idxs = randperm(cfg_game.N); 
    else
        cfg_game.randorder_idxs = 1:cfg_game.N; 
    end
    debut_i=1;
else
    debut_i=i_savegame;
end

cfg_game.bDebug = bDebug;

str_inout = [];
str_inout.debut_i = debut_i;

str_inout = staircase_init(str_inout,cfg_game);

response   = str_inout.response;
n_correctinarow = str_inout.n_correctinarow;
m          = str_inout.m;
i_current  = str_inout.i_current;
stepsize   = str_inout.stepsize;
isbreak    = str_inout.isbreak;

iswarmup = cfg_game.warmup;
if cfg_game.is_experiment == 1
    if iswarmup
        % display instructions warmup
        msg_warmup
    else
        % display instructions main exp
        msg_mainexp
    end
end
 
N = cfg_game.N;

bLevel_norm_version = 2; % 1 is 'as received'

i = nan(1);
while i_current <= N && (cfg_game.is_simulation == 1 || i~=debut_i+cfg_game.sessionsN) && isbreak == 0
    
    cfg_game.i_current = i_current;
    n_stim = cfg_game.randorder_idxs(i_current);
    
    % Create signal
    istarget = (ListStim(n_stim).N_signal)==2;
    
    if bDebug == 1
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        fprintf('\nDependent variable: m = %.4f dB\n',m)
    end
    
    str_inout = [];
    str_inout.m = m;
    str_inout.istarget = istarget;
    str_inout.bLevel_norm_version = bLevel_norm_version;
    str_inout.filename = ListStim(i_current).name;
    
    str_stim = [];
    str2eval = sprintf('str_stim=%s_user(str_inout,cfg_game);',cfg_game.experiment);
    eval(str2eval);
    stim_normal = str_stim.tuser;
    
    % stim_normal = il_user(str_inout,cfg_game);
    %%% Create signal: end
    
    if cfg_game.is_experiment
        sil4playing = zeros(0.1*cfg_game.fs,1);
        player = audioplayer([sil4playing; stim_normal],cfg_game.fs);
    end
    if cfg_game.is_simulation
        sil4playing = [];
    end
     
    % save trial data
    if ~iswarmup
        ListStim(n_stim).n_presentation=i_current; 
        data_passation.n_stim(i_current) = n_stim;
        ListStim(n_stim).m = m; 
        data_passation.m(i_current) = m;
        data_passation.N_signal(i_current) = ListStim(n_stim).N_signal;
        clock_now = clock;
        data_passation.date(i_current,:) = clock_now;
        ListStim(n_stim).date = clock_now;
    end
     
    % Display message, play sound and ask for response
    tic
     
    if cfg_game.is_experiment
        % display
        if iswarmup
            fprintf('\n    * WARM-UP PHASE *\n\n');
        else
            fprintf('\n    * MAIN EXPERIMENT *\n\n');
            if cfg_game.displayN == 1
                fprintf('    Playing stimulus # %.0f of %.0f\n',i_current,cfg_game.N);
            else
                fprintf('    Playing stimulus\n');
            end
        end
        % response = Reponse_clavier([cfg_game.response_names {'r\351ecouter le stim'}], 3.14);
        play(player)
        if iswarmup
            response = Reponse_clavier([cfg_game.response_names {'to play the stim again' ['to play a ' cfg_game.response_names{1}] ['to play a ' cfg_game.response_names{2}] 'to leave the warm-up phase'}]);
        else
            response = Reponse_clavier([cfg_game.response_names {'to take a break'}], 3.14);
        end
        stop(player)
    elseif cfg_game.is_simulation
        error('Not validated yet...')
        % fprintf(['analyse stim # ' num2str(i) ' of ' num2str(cfg_game.N) '\n']);
        % Stim_IR = auditorymodel(stim_normal, cfg_game.fs, cfg_game.model);
        % % redefine the template
        % Signal{2} = create_AM(cfg_game.fc, cfg_game.fm, 10^(m/10), cfg_game.stim_dur, cfg_game.fs)';
        % % Signal{2} = [zeros(cfg_game.cfg_crea.stim_dur*cfg_game.fs-length(Signal{2}),1); Signal{2}];
        % cfg_game.IR{2} = auditorymodel(Signal{2}, cfg_game.fs, cfg_game.model);
        % 
        % % audiowrite(['StimsStims/', ListStim(n_stim).name], stim_normal/max(abs(stim_normal)), cfg_game.fs)
        % % [ response ] = auditorymodel_detection( {cfg_game.IR{1}, cfg_game.IR{2}}, Stim_IR, cfg_game.model );
        % % [ response ] = auditorymodel_PEMO( Stim_IR, {cfg_game.IR{1}, cfg_game.IR{2}}, cfg_game.model );
        % % [ response ] = auditorymodel_PEMO( Stim_IR, cfg_game.IR{2}, cfg_game.model );
        % [ response ] = auditorymodel_TMdetect( Stim_IR, cfg_game.IR{2}, cfg_game.model );
    end
     
    responsetime = toc;
    ListStim(n_stim).responsetime  = responsetime; 
    data_passation.responsetime(i_current) = responsetime;
     
    switch response
        case 3.14 % This is a ''pause''
            clock_str = Get_date_and_time_str;
            data_passation.datefin{length(data_passation.startdate)} = clock_str;
            savename = ['savegame_' clock_str];
            save([dir_main savename], 'i', 'ListStim', 'cfg_game', 'data_passation');
            fprintf('  Saving game to "%s.mat" (folder path: %s)\n',savename,dir_main);
            
        case 3 % play again (if warm-up) or take a break (if main experiment)
            if ~iswarmup
                isbreak = 1;
            end
        case 4 % play pure tone
            str_stim = [];
            cfg_tmp = cfg_game;
            str_inout.istarget = 0;
            str_inout.m = 0;
            exp2eval = sprintf('str_stim =  %s_user(str_inout,cfg_tmp);',experiment);
            eval(exp2eval);
            stim_normal = str_stim.stim_tone_alone;
            
            player = audioplayer([sil4playing; stim_normal],cfg_game.fs);
            playblocking(player)
            
            fprintf(['\n    Press any key\n']);
            pause;

        case 5 % play modulated tone
            str_stim = [];
            cfg_tmp = cfg_game;
            str_inout.istarget = 1;
            str_inout.m = m;
            exp2eval = sprintf('str_stim =  %s_user(str_inout,cfg_tmp);',experiment);
            eval(exp2eval);
            stim_normal = str_stim.stim_tone_alone;
            
            player = audioplayer([sil4playing; stim_normal],cfg_game.fs);
            playblocking(player)
            
            fprintf(['\n    Press any key\n']);
            pause;

        case 6 % escape training
            iswarmup = 0;
            clc
            
            cfg_game.warmup = iswarmup;
            
            str_inout = [];
            str_inout.debut_i = debut_i;
            
            str_inout = staircase_init(str_inout,cfg_game); % actual initialisation
            
            response   = str_inout.response;
            n_correctinarow = str_inout.n_correctinarow;
            m          = str_inout.m;
            i_current  = str_inout.i_current;
            stepsize   = str_inout.stepsize;
            isbreak    = str_inout.isbreak;
            
            %%%% TODO %%%%
            % display instructions main exp

        case {1,2} % responded 1 or 2
            iscorrect = (response == ListStim(n_stim).N_signal);
            % save trial data
            if ~iswarmup
                ListStim(n_stim).n_response = response; 
                data_passation.n_response(i_current) = response;
                
                ListStim(n_stim).response = cfg_game.response_names{ListStim(n_stim).n_response};
                
                ListStim(n_stim).is_correct = iscorrect; 
                data_passation.is_correct(i_current) = iscorrect;
            end
            if iswarmup || bDebug
                % ListStim(n_stim).response 
                switch iscorrect
                    case 1
                        txt_extra = 'You were right';
                    case 0
                        txt_extra = 'You were wrong';
                end
                  
                % feedback
                fprintf(['\n %s => Correct answer was : ' num2str(ListStim(n_stim).N_signal) ' ( ' cfg_game.response_names{ListStim(n_stim).N_signal} ' )\n\n   Press any key to continue.\n'],txt_extra);
                pause;
            end
            
            if iscorrect
                n_correctinarow = n_correctinarow+1;
            else
                n_correctinarow = 0;
            end
             
            if cfg_game.adapt
                str_inout = [];
                str_inout.iscorrect = iscorrect;
                str_inout.m         = m;
                str_inout.stepsize  = stepsize;
                str_inout.n_correctinarow = n_correctinarow;
                
                str_inout = staircase_update(str_inout,cfg_game);
                
                % load updated parameters
                m         = str_inout.m;
                stepsize  = str_inout.stepsize;
                n_correctinarow = str_inout.n_correctinarow;
                
                % plot(data_passation.m,'-'); drawnow
            end
             
            i_current=i_current+1;
        otherwise
            warning('%s: Keyboard response not recognised',upper(mfilename))
    end
    
end
 
%% Save game
 
clock_str = Get_date_and_time_str;
data_passation.datefin{length(data_passation.startdate)} = clock_str;
savename = ['savegame_' clock_str];
save([dir_main savename], 'i', 'ListStim', 'cfg_game', 'data_passation');
msg_close