function [outsig, fc, t, outs] = Gammatone_proc(insig, fs, varargin)
%GAMMATONE_PROC   Linear filtering for monaural masking (improved)
%   Usage: [outsig, fc] = Gammatone_proc(insig,fs);
%          [outsig, fc] = Gammatone_proc(insig,fs,...);
%
%   Input parameter:
%     insig  : input acoustic signal.
%     fs     : sampling rate.
%  

outs = [];

definput.import={'auditoryfilterbank','ihcenvelope','adaptloop','Gammatone_proc'};
definput.importdefaults={'afb_osses2021', 'ihc_breebaart2001','adt_osses2021'};%,'Gammatone_proc'}; 
definput.keyvals.subfs=[];

[flags,keyvals]  = ltfatarghelper({'flow','fhigh'},definput,varargin);

insig = gaindb(insig,keyvals.dboffset-100); % from here on, the input signal is
                               % assumed to be at a dboffset of 100 dB (default AMT)
                               
if flags.do_outerear
  hp_fir = headphonefilter(fs);% Getting the filter coefficients at fs
  N = round(25e-3*fs);  % fixed group delay
  M = 1; % assumes insig is monaural
  insig = [insig; zeros(N,M)]; % group delay compensation: step 1 of 2. 
  insig = filter(hp_fir,1,insig); % filtering
  insig = insig(N+1:end,1:M); % group delay compensation: step 2 of 2
end

if flags.do_middleear || flags.do_jepsen2008
    filtertype = 'lopezpoveda2001';
    me_fir     = middleearfilter(fs,filtertype);
    me_gain_TF = max( 20*log10(abs(freqz(me_fir,1,8192))) ); % max of the filter response

    N = round(25e-3*fs);  % fixed group delay
    M = 1; % assumes insig is monaural
    insig = [insig; zeros(N,M)]; % group delay compensation: step 1 of 2.
    insig = filter(me_fir,1,insig); % filtering
    insig = insig(N+1:end,1:M); % group delay compensation: step 2 of 2. 
    insig = gaindb(insig,-me_gain_TF); % if me_fir is a non-unit gain filter, 
                                       % the gain of the FIR filter is compensated.
end

t_orig = (1:size(insig,1))/fs;
dur_samples = length(t_orig);

subfs = 1/(keyvals.binwidth);
binwidth_samples = round(keyvals.binwidth*fs);

if mod(dur_samples, binwidth_samples) ~= 0
    % Zero padding needed:
    N2add = binwidth_samples - mod(dur_samples, binwidth_samples);
    insig = [insig; zeros(N2add,size(insig,2))];
    
    t_orig = (1:size(insig,1))/fs;
end

% Apply the auditory filterbank
[outsig, fc] = auditoryfilterbank(insig,fs,'argimport',flags,keyvals);
if flags.do_fc_nextpow2
    nfc_original = length(fc);
    if nfc_original > 64 || round(max(fc)) < 8000
        nfc = 2^nextpow2( length(fc)/2 ); % reduces one order
    else
        nfc = nfc_original;
    end
    
    if nfc_original > nfc
        % Then fc contains a subset of the original fcs:
        idx_i = find(fc>80,1,'first'); % first frequency above 80 Hz
        idx_f = min(idx_i+nfc-1, nfc_original);

        fc = fc(idx_i:idx_f);

        outsig = outsig(:,idx_i:idx_f);
    end
end
    
if flags.do_ihc
    % 'haircell' envelope extraction
    outsig = ihcenvelope(outsig,fs,'argimport',flags,keyvals);
    
    if flags.do_hilbert % Used by Varnet and Lorenzi (2022):
        fcut = 30; % 30 Hz
        LP_order = 1;
        [b,a] = butter(LP_order,fcut/(fs/2),'low');
        outsig=filter(b,a,outsig);
    end
end

if flags.do_adt
    % non-linear adaptation loops
    outsig = adaptloop(outsig,fs,'argimport',flags,keyvals);
end
    
dur_samples = length(t_orig);
if mod(dur_samples, binwidth_samples) ~= 0
    % Zero padding needed
    N2add = binwidth_samples - mod(dur_samples, binwidth_samples);
    outsig = [outsig; zeros(N2add,length(fc))];
    
    t_orig = (1:size(outsig,1))/fs;
end

outsig_orig = outsig;
if binwidth_samples ~= 1
    outsig = il_downsample(outsig,binwidth_samples);
end

t = (1:size(outsig,1))/subfs;

if nargout >= 4
    outs.subfs  = subfs;
    
    outs.t_orig = t_orig; 
    outs.outsig_orig = outsig_orig; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outsig = il_downsample(insig,binwidth_samples)

N_blocks = size(insig,1)/binwidth_samples;

for i = 1:N_blocks
    idxi = binwidth_samples*(i-1)+1;
    idxf = binwidth_samples*i;
    
    outsig(i,:) = mean(insig(idxi:idxf,:));
end
