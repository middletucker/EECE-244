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

% Low-pass Filter
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

% Cascade Filters
d = designfilt('bandstopiir','FilterOrder',2,'HalfPowerFrequency1',59,...
    'HalfPowerFrequency2',61, 'DesignMethod', 'butter', 'SampleRate',Fs);
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

% High Pass Filter
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

%% Algorithm 1 (best algorithm)
[~, locs_Rwave] = findpeaks(ecg_filterNotch2, 'MinPeakHeight', 2, ...
    'MinPeakDistance', 1800); % Find peaks above value 2

Rtimes1 = t(locs_Rwave); % Convert to time in seconds
Rperiod1 = diff(Rtimes1); % Convert to period
MeanRperiod1 = mean(Rperiod1); % Find mean/average period
Rfreq1 = 1/mean(Rperiod1); 
average1 = Rfreq1*60; % Lines 66-67 takes period and converts to heart rate
disp(average1)

%% Algorithm 2 (does not work)

aboveThresh = locs_Rwave > 2; % Find points above 2
n = diff(aboveThresh); % Find rising edges
numPeaks = sum(n); % Count rising edges

average2 = numPeaks/MeanRperiod1; 
disp(average2)


