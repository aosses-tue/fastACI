%% Figures for Modulation Group presentation

dir_data = fastACI_paths('dir_data');

%% Plot targets

basef = 8000;
flags_gamma = {'basef',basef,'flow',40,'fhigh',8000,'bwmul',0.5,'dboffset',100,'no_adt','binwidth',0.01, ...
            'no_outerear','no_middleear'};

dir_subj = [dir_data 'speechACI_Logatome-abda-S43M' filesep 'S01' filesep];
[aba, fs] = audioread([dir_subj 'speech-samples' filesep 'S43M_ab_ba.wav']);
[ada, fs] = audioread([dir_subj 'speech-samples' filesep 'S43M_ad_da.wav']);

[G_aba, fc, t, outs] = Gammatone_proc(aba, fs, flags_gamma{:});
[G_ada, fc, t, outs] = Gammatone_proc(ada, fs, flags_gamma{:});

figure('Position',[100 100 500 250]); 
tiledlayout(1,2,'TileSpacing','Compact');
nexttile(1); affichage_tf(log(G_aba)', 'pow', t, fc); caxis([-8 -4.5]); title('/aba/ target');colorbar off;%ylabel('');%xlabel('');
nexttile(2); affichage_tf(log(G_ada)', 'pow', t, fc); caxis([-8 -4.5]); title('/ada/ target');ylabel('');set(gca,'YTickLabels',[]);%xlabel('')

%% Speech in noise

N_noise = 1000;
SNR = -14;

gain_snr = 10^(SNR/20);
for i_noise = 1:N_noise
    clear char_inoise noise signal
    char_inoise = num2str(i_noise);
    char_inoise = [repmat('0',1,5-length(char_inoise)) char_inoise];
    noise = randn(size(aba));%audioread([dir_subj 'NoiseStim-white' filesep 'Noise_' char_inoise '.wav']);
    noise = 0.01*noise/sqrt(mean(noise.^2));
    signal = gain_snr * aba;

    stim = noise+aba; % No SNR here...
    [G_Naba(:,:,i_noise), fc, t, outs] = Gammatone_proc(stim, fs, flags_gamma{:});
    [G_N(:,:,i_noise), fc, t, outs]    = Gammatone_proc(noise, fs, flags_gamma{:});
end

G_Naba_mean = mean(G_Naba,3);
G_N_mean = mean(G_N,3);
G_N_meanstd = G_N_mean + 2.2*std(G_N,[],3);

G_Naba_mean_thres = G_Naba_mean;
%G_Naba_mean_thres(G_Naba_mean_thres<G_N_meanstd) = nan;

idx_realization = round(.733*N_noise);
if N_noise ~= 1000
    warning('Less noise representations being used to derive the masking effects...');
end
G_Naba_thres = G_Naba(:,:,idx_realization);
%G_Naba_thres(G_Naba_thres<G_N_meanstd) = nan;

figure('Position',[100 100 1000 250]); 
tiledlayout(1,5,'TileSpacing','Compact');
nexttile; affichage_tf(log(G_aba)', 'pow', t, fc); caxis([-8 -4.5]); title('/aba/ target');colorbar off;
%nexttile; affichage_tf(log(G_ada)', 'pow', t, fc); caxis([-8 -4.5]); title('/ada/ target');colorbar off;ylabel('');set(gca,'YTickLabels',[]);xlabel('');set(gca,'XTickLabels',[]);%
nexttile; affichage_tf(log(G_Naba(:,:,1))', 'pow', t, fc); caxis([-8 -4.5]); title('/aba/ target in noise');colorbar off;ylabel('');set(gca,'YTickLabels',[]);
  
nexttile; affichage_tf(log(G_Naba_mean)', 'pow', t, fc); caxis([-8 -4.5]); title('EM');colorbar off;ylabel('');set(gca,'YTickLabels',[]);%
nexttile; affichage_tf(log(G_Naba_mean)', 'pow', t, fc); caxis([-8 -4.5]); title('EM+MM');colorbar off;ylabel('');set(gca,'YTickLabels',[]);%
nexttile; affichage_tf(log(G_Naba_thres)', 'pow', t, fc); caxis([-8 -4.5]); title('EM+MM+IM');ylabel('');set(gca,'YTickLabels',[]);%

listImage = findobj('Type','Image');

set(listImage(2),'AlphaData',1-0.5*(G_Naba_mean_thres<G_N_meanstd)')
set(listImage(1),'AlphaData',1-0.5*(G_Naba_thres<G_N_meanstd)')