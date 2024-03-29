function [str_stim,data_passation] = speechACI_varnet2013_user(cfg,data_passation)
% function [str_stim,data_passation] = speechACI_varnet2013_user(cfg,data_passation)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In the paper: 0 for ‘da’ and 1 for ‘ga’
% Here: 1 = 'da', 2 = 'ga'

i_current = data_passation.i_current;
SNR       = data_passation.expvar(i_current);
n_stim    = data_passation.n_stim(i_current);
n_signal  = cfg.n_targets_sorted(n_stim);

[signal,fs] = audioread([cfg.dir_target cfg.filename_target{n_signal}]); % will load one of the four utterances

% idx = round(0.25*fs); signal = signal(1:idx); error('Temporal')

fname_noise = [cfg.dir_noise cfg.ListStim(n_stim).name];
noise = audioread(fname_noise);

% noise = noise(1:idx); % warning('Temporal')

bSpeech_level_variable = 1;
bNoise_level_variable = ~bSpeech_level_variable;

if bSpeech_level_variable
    gain_snr = 10^(SNR/20);
    signal = gain_snr * signal;
end
if bNoise_level_variable
    error('Not validated yet...')
    % gain_snr = 10^(-SNR/20);
    % noise = gain_snr * noise;
end
tuser_cal = noise+signal;

str_stim.tuser = tuser_cal;

str_stim.stim_tone_alone  = signal;