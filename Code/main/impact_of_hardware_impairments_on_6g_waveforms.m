%% Measuring Impact of Sub-THz Hardware Impairments on 6G Waveforms

% Set System Parameters
carrierFrequency = 140; % GHz
bandwidth = 2160; % MHz - transmission bandwidth and guardbands
subcarrierSpacing = 3840; % kHz
waveform = "OFDM"; % Waveform modulation

bandwidthOccupancy = 0.8; % Ratio of transmission bandwidth to channel bandwidth

% Create a carrier configuration, calculate the transmission bandwidth and required number of resource blocks
carrier = pre6GCarrierConfig;
carrier.SubcarrierSpacing = subcarrierSpacing;
channelBandwidth = bandwidth*1e6;
carrier.NSizeGrid = floor((channelBandwidth/(carrier.SubcarrierSpacing*1e3)*bandwidthOccupancy)/12); 
transmissionBandwidth = carrier.SubcarrierSpacing*1e3*carrier.NSizeGrid*12; 

numSubframes = 0.5; % Number of subframes to simulate
tddConfig.TDDPeriod = 10; % TDD period in slots
tddConfig.NumDownlinkSlots = 9; % Number of slots in TDD period containing PDSCH

numSlots = numSubframes*carrier.SlotsPerSubframe;
tddConfig.SlotAllocation = 0:tddConfig.NumDownlinkSlots-1; 
disp("Simulating "+numSlots+" slots")

visualizeTDDAllocation(tddConfig);

pdsch = pre6GPDSCHConfig;
pdsch.PRBSet = 0:(carrier.NSizeGrid-1);
pdsch.Modulation = "16QAM";
pdsch.EnablePTRS = true;

%% Add Impairments

% Impaired Waveform and Power Amplifier Modeling
enableLPF = true; % Enable low-pass filter
if enableLPF
    % Create low-pass filter object
    LPF = dsp.LowpassFilter;
    LPF.SampleRate = ofdmInfo.SampleRate;
    LPF.FilterType = "IIR";
    LPF.PassbandFrequency = (transmissionBandwidth + 24*carrier.SubcarrierSpacing*1e3)/2;
    LPF.StopbandFrequency = channelBandwidth/2; 
    LPF.PassbandRipple = 0.2;
    LPF.StopbandAttenuation = 40;
    figure;
    freqz(LPF); % Plot the response of the low-pass filter

    % Filter the waveform
    impariredWaveform = LPF(impariredWaveform);
    release(LPF);
end

enablePA = true; % Enable power amplifier model
if enablePA
    backoff = 6; 
    impariredWaveform = db2mag(-backoff)*impariredWaveform; % Apply PA backoff
    visualizeAMAMCharacteristic(@paMemorylessGaN,"GaN");
    
    impariredWaveform = paMemorylessGaN(impariredWaveform);    
end

% Custom AM/AM Visualization
function visualizeAMAMCharacteristic(signal)
    inputPower = abs(signal).^2; 
    outputPower = abs(signal).^2; 

    inputPowerDB = 10*log10(inputPower);
    outputPowerDB = 10*log10(outputPower);

    figure;
    plot(inputPowerDB, outputPowerDB);
    xlabel('Input Power (dBm)');
    ylabel('Output Power (dBm)');
    title('AM/AM Characteristic of Power Amplifier');
    grid on;
end

%% Measure ACPR

% Measure the ACPR to study spectral regrowth caused by the nonlinear PA model.

measureACPR = true;
if measureACPR
    numAdjacentChannels = floor((ofdmInfo.SampleRate/channelBandwidth-1)/2);
    if numAdjacentChannels>0        
        sa = spectrumAnalyzer;
        sa.SampleRate = ofdmInfo.SampleRate;
        sa.ChannelMeasurements.Type = "acpr";
        sa.ChannelMeasurements.Enabled = true;
        sa.ChannelMeasurements.Span = transmissionBandwidth;
        sa.ChannelMeasurements.NumOffsets = numAdjacentChannels;
        sa.ChannelMeasurements.AdjacentBW = transmissionBandwidth;
        sa.ChannelMeasurements.ACPROffsets = (1:numAdjacentChannels)*channelBandwidth;
        sa(impariredWaveform);
    else
        warning("Sample rate too low to measure ACPR, increase oversamplingFactor")
    end
end

%% Measure CCDF

% Measure the CCDF to evaluate the PAPR of the waveform.

measureCCDF = true;
if measureCCDF
    pm = powermeter(ComputeCCDF=true);
    averagePower = pm(impariredWaveform);
    disp("Average power: "+averagePower+" dBm")
    figure;
    plotCCDF(pm,GaussianReference=true)
end