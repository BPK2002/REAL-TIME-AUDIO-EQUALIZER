clc 
clear all
close all

% Define the sampling rate and block size
fs = 44100; % Sampling rate (Hz)
blockSize = 1024; % Block size for processing (samples)

% Load the input audio file
[input, fs_input] = audioread('mini_input.wav');
if size(input, 2) > 1 
    input = mean(input, 2); % convert stereo to mono
end

% Create a System object to play audio output through the speakers
audioOutput = audioDeviceWriter('SampleRate', fs, 'SupportVariableSizeInput', true);

% Define the frequency bands for the equalizer
freqBands = [0 60 170 310 600 1000 3000 6000 12000 14000 16000]; % Frequency bands (Hz)
numBands = length(freqBands)-1; % Number of frequency bands

% Initialize the equalization gains in decibels (dB)
%  gains = [0 0 0 0 0 0 0 0 0];
% gains = [-200 -200 -200 -200 -200 -200 -200 -200 -200];
% gains = [200 200 200 200 200 200 200 200 200];
% gains = [9 6 3 0 -3 -6 -9 -12 -20];
gains = [ 8 8 4.8 4.8 -3.2 -3.2 8.8 8.8 11.2 11.2];
% Create a System object to write audio output to a file

filename = 'mini_Output.wav';
audioFileWriter = dsp.AudioFileWriter(filename, 'FileFormat', 'WAV', 'SampleRate', fs );

% Compute the frequency spectrum of the input signal
spectrum_input = fft(input);
spectrum_input2 = fft(input);

% Apply the equalization gains to the frequency spectrum
for k = 1:numBands
    idx = (freqBands(k) < linspace(0, fs/2, blockSize/2)) & (linspace(0, fs/2, blockSize/2) < freqBands(k+1));
    spectrum_input(idx) = spectrum_input(idx) * 10^(gains(k)/20);
end

% Apply an inverse FFT to obtain the time-domain signal
output = (ifft(spectrum_input));

% Write the equalized audio signal to a file
audioFileWriter(output);

% Compute the frequency spectrum of the output signal
spectrum_output = fft(output);

% Plot the frequency spectra of the input and output signals
figure;
subplot(2,1,1);
plot(linspace(0,fs/2,blockSize/2),20*log10(abs(spectrum_input2(1:blockSize/2))));
title('Input Signal Frequency Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 23000])

subplot(2,1,2);
plot(linspace(0,fs/2,blockSize/2),20*log10(abs(spectrum_output(1:blockSize/2))));
title('Output Signal Frequency Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 23000])

% Cleanup
release(audioOutput);
release(audioFileWriter);
