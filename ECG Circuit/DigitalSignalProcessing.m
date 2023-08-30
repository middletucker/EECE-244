% GenerateECG inputs are: total time in seconds, 1 for default ecg
% (note: default heartrate is 72 bpm)
close all; clear all;
%% Generate Signal
[t, ecg_clean, ts] = GenerateECG(6, 1);
Fs = 1/ts;

WhiteNoise = 0.10*max(ecg_clean)*rand(size(t));
WallNoise = 0.05*max(ecg_clean)*sin(2*pi*60*t);

FluoresLights = 0.05*max(ecg_clean)*sin(2*pi*50000*t);

ecg_noisy = WhiteNoise + WallNoise + FluoresLights + ecg_clean;

figure(1)
subplot(2,1,1); 
title('Noisy')
plot(t, ecg_noisy, 'b');
hold on

subplot(2,1,2); 
title('Clean')
plot(t, ecg_clean, 'b');
hold on




%% Low-pass Filter
ecg_filterLP = lowpass(ecg_noisy,4,Fs);

figure(2)
subplot(2,1,1); 
title('Noisy')
plot(t, ecg_noisy, 'b');
hold on

subplot(2,1,2); 
title('Noisy with Lowpass')
plot(t, ecg_filterLP, 'b');
hold on

%% Notch Filter
d = designfilt('bandstopiir','FilterOrder',2,'HalfPowerFrequency1',59,...
    'HalfPowerFrequency2',61, 'DesignMethod', 'butter', 'SampleRate',Fs);
ecg_filterNotch = filtfilt(d, ecg_noisy);

figure(3)
subplot(2,1,1); 
title('Noisy')
plot(t, ecg_noisy, 'b');
hold on

subplot(2,1,2); 
title('Noisy with Notch')
plot(t, ecg_filterNotch, 'b');
hold on

%% Cascade Filters

ecg_filterNotch2 = filtfilt(d, ecg_filterLP);

figure(4)
subplot(2,1,1); 
title('Noisy')
plot(t, ecg_noisy, 'b');
hold on

subplot(2,1,2); 
title('Noisy Cascaded 1')
plot(t, ecg_filterNotch2, 'b');
hold on

%% High Pass Filter
ecg_filterHP = highpass(ecg_filterNotch2, 0.001, Fs);

figure(5)
subplot(2,1,1); 
title('Noisy')
plot(t, ecg_noisy, 'b');
hold on

subplot(2,1,2); 
title('Noisy Cascaded 1')
plot(t, ecg_filterHP, 'b');
hold on

%% Smoothing Filter
smoothECG = sgolayfilt(ecg_filterHP, 7, 201);

figure(6)
subplot(2,1,1); 
title('Noisy')
plot(t, ecg_noisy, 'b');
hold on

subplot(2,1,2); 
title('Noisy Cascaded 1')
plot(t, smoothECG, 'b');
hold on

%% Peak Detection

%Noisy
[~, locs_Rwave] = findpeaks(ecg_clean, 'MinPeakHeight', 2, ...
    'MinPeakDistance', 1800);
ECG_Inverted = -ecg_clean;

[~, locs_Swave] = findpeaks(ECG_Inverted, 'MinPeakHeight', -0.8, ...
    'MinPeakDistance', 1800);

figure(7)
plot(t, ecg_clean)
hold on;
plot(t(locs_Rwave), ecg_clean(locs_Rwave), 'rv', 'MarkerFaceColor', 'r')
plot(t(locs_Swave), ecg_clean(locs_Swave), 'rs', 'MarkerFaceColor', 'b')

%Clean

[~, locs_Rwave2] = findpeaks(ecg_noisy, 'MinPeakHeight', 2, ...
    'MinPeakDistance', 1800);
ECG_Inverted2 = -ecg_noisy;

[~, locs_Swave2] = findpeaks(ECG_Inverted2, 'MinPeakHeight', -0.8, ...
    'MinPeakDistance', 1800);

figure(8)
plot(t, ecg_noisy)
hold on;
plot(t(locs_Rwave2), ecg_clean(locs_Rwave2), 'rv', 'MarkerFaceColor', 'r')
plot(t(locs_Swave2), ecg_clean(locs_Swave2), 'rs', 'MarkerFaceColor', 'b')


