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
freqBands = [0 100 200 400 800 1600 3200 6400 12800 22050]; % Frequency bands (Hz)
numBands = length(freqBands)-1; % Number of frequency bands

% Initialize the equalization gains to unity (i.e., no equalization)
gains = ones(numBands, 1);

% Create a graphic user interface (GUI) to adjust the equalization gains
fig = figure('Name', 'Real-time Audio Equalizer');

% Create a slider for each frequency band
for k = 1:numBands
    slider(k) = uicontrol('Style', 'slider', 'Units', 'normalized', 'Position', [0.05 0.1*k 0.9 0.05], 'Min', -12, 'Max', 12, 'Value', 0, 'SliderStep', [1/24 1/12]);
    uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.05 0.1*k-0.025 0.9 0.025], 'String', sprintf('%d Hz - %d Hz', freqBands(k+1), freqBands(k)));
end

% Define a callback function for the sliders that updates the equalization gains
set(slider, 'Callback', {@updateGains});

% Main loop for real-time processing
while ishandle(fig)
    % Read a block of audio input from the microphone
    audioIn = audioInput();

   

    % Compute the frequency spectrum of the audio signal
    spectrum = fft(audioIn);

    % Apply the equalization gains to the frequency spectrum
    for k = 1:numBands
        idx = (freqBands(k) < linspace(0, fs/2, blockSize/2)) & (linspace(0, fs/2, blockSize/2) <= freqBands(k+1));
        spectrum(idx) = spectrum(idx) * 10^(gains(k)/20);
    end

    % Apply an inverse FFT to obtain the time-domain signal
    audioOut = (ifft(spectrum));

    % Write the equalized audio signal to the speakers
    audioOutput(audioOut);
end

% Cleanup when the GUI is closed
release(audioInput);
release(audioOutput);

% Callback function for the sliders that updates the equalization gains
function updateGains(src, ~)
    % Get the current slider values
    sliderVals = get(src, 'Value');

    % Update the equalization gains based on the slider values
    global gains;

    for k = 1:length(sliderVals)
        gains(k) = sliderVals(k);
    end
end
