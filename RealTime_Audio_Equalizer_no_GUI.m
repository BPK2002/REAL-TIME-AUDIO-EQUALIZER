clc 
clear all
close all

% Real-time Audio Equalizer using Digital Signal Processing
% This code assumes that you have a microphone and speakers connected to your computer.

% Define the sampling rate and block size
fs = 44100; % Sampling rate (Hz)
blockSize = 1024; % Block size for processing (samples)

% Create a System object to read audio input from the microphone
audioInput = audioDeviceReader('SamplesPerFrame', blockSize, 'NumChannels', 1, 'SampleRate', fs);

% Create a System object to play audio output through the speakers
audioOutput = audioDeviceWriter('SampleRate', fs, 'SupportVariableSizeInput', true);

% Define the frequency bands for the equalizer
freqBands = [0 50 100 200 400 1600 3200 6400 12800 22050]; % Frequency bands (Hz)
numBands = length(freqBands)-1; % Number of frequency bands

% Initialize the equalization gains in decibels (dB)
%same as input
% gains = [0 0 0 0 0 0 0 0 0];

% Create a System object to write audio output to a file
filename = 'RealTimeEqu_File_Output.wav';
audioFileWriter = dsp.AudioFileWriter(filename, 'FileFormat', 'WAV', 'SampleRate', fs );

% Main loop for real-time processing
while true
    % Read a block of audio input from the microphone
    audioIn = audioInput();

    % Compute the frequency spectrum of the audio signal
    spectrum = fft(audioIn);

    % Apply the equalization gains to the frequency spectrum
    for k = 1:numBands
        idx = (freqBands(k) < linspace(0, fs/2, blockSize/2)) & (linspace(0, fs/2, blockSize/2) < freqBands(k+1));
        spectrum(idx) = spectrum(idx) * 10^(gains(k)/20);
    end

    % Apply an inverse FFT to obtain the time-domain signal
    audioOut = (ifft(spectrum));

    % Write the equalized audio signal to the speakers
    audioOutput(audioOut);
    
    % Write the equalized audio signal to a file
    audioFileWriter(audioOut);
end



% Cleanup when the loop is exited
release(audioInput);
release(audioOutput);
