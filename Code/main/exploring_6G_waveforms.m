% This script demonstrates the use of the 6G Exploration Library for 5G Toolbox
% to explore candidate 6G waveforms with extended capabilities. The examples 
% include subcarrier spacings greater than 960 kHz, resource grids larger than 
% 275 resource blocks, and modulation schemes beyond 1024-QAM.

%% Subcarrier Spacings Greater Than 960 kHz

% Configure a carrier with a subcarrier spacing of 3840 kHz and 36 resource blocks.
carrier = pre6GCarrierConfig(SubcarrierSpacing=3840, NSizeGrid=36);

% Compute and display the sample rate and transmission bandwidth.
ofdmInfo = hpre6GOFDMInfo(carrier);
sampleRate = ofdmInfo.SampleRate; 
disp(['Sample rate = ' num2str(sampleRate / 1e9) ' GHz'])

txBandwidth = carrier.NSizeGrid * 12 * carrier.SubcarrierSpacing * 1e3; 
disp(['Transmission bandwidth = ' num2str(txBandwidth / 1e9) ' GHz'])

% Display the number of slots per subframe.
disp(['Slots per subframe = ' num2str(carrier.SlotsPerSubframe)])

% Display cyclic prefix lengths of the first slot.
disp(['Cyclic prefix lengths (in samples) = ' num2str(ofdmInfo.CyclicPrefixLengths(1:carrier.SymbolsPerSlot))])

%% Resource Grids Larger Than 275 Resource Blocks

% Configure a carrier for a 700 MHz bandwidth with a subcarrier spacing of 120 kHz.
% This allows creating a resource grid with more than 275 resource blocks, which is 
% essential for utilizing wider bandwidths, such as those defined in the upper 6 GHz band.

bandwidthOccupancy = 0.9;
carrier = pre6GCarrierConfig(SubcarrierSpacing=120);
channelBandwidth = 700e6;
carrier.NSizeGrid = floor((channelBandwidth/(carrier.SubcarrierSpacing*1e3)*bandwidthOccupancy)/12)

% Compute and display the sample rate and transmission bandwidth.
ofdmInfo = hpre6GOFDMInfo(carrier);
sampleRate = ofdmInfo.SampleRate;
disp(['Sample rate = ' num2str(sampleRate / 1e6) ' MHz'])

txBandwidth = carrier.NSizeGrid * 12 * carrier.SubcarrierSpacing * 1e3;
disp(['Transmission bandwidth = ' num2str(txBandwidth / 1e6) ' MHz'])

% Configure PDSCH (Physical Downlink Shared Channel) with 64-QAM modulation.
pdsch = pre6GPDSCHConfig;
pdsch.PRBSet = 0:(carrier.NSizeGrid-1); 
pdsch.Modulation = '64QAM'; 

% Create a carrier resource grid and allocate PDSCH and DM-RS symbols.
nTxAnts = 1;
txGrid = hpre6GResourceGrid(carrier, nTxAnts);

[ind, indinfo] = hpre6GPDSCHIndices(carrier, pdsch); 
cw = randi([0 1], indinfo.G, 1); 
sym = hpre6GPDSCH(carrier, pdsch, cw); 
txGrid(ind) = sym; 

dmrsind = hpre6GPDSCHDMRSIndices(carrier, pdsch); 
dmrssym = hpre6GPDSCHDMRS(carrier, pdsch); 
txGrid(dmrsind) = dmrssym; 

% OFDM-modulate the resource grid to generate the waveform.
txWaveform = hpre6GOFDMModulate(carrier, txGrid);

% Plot the spectrum of the generated waveform.
scope = spectrumAnalyzer(SampleRate=sampleRate);
scope.Title = "Waveform for 700 MHz channel in upper 6 GHz band";
scope.ChannelMeasurements.Enabled = true;
scope.ChannelMeasurements.Span = 700e6; % Set measurement span
scope(txWaveform);

%% Extended Modulation Schemes

% Configure the PDSCH to use 4096-QAM modulation, which enables higher spectral efficiency.
pdsch.Modulation = '4096QAM'; 

% Generate and map PDSCH symbols for 4096-QAM.
[ind, indinfo] = hpre6GPDSCHIndices(carrier, pdsch);
cw = randi([0 1], indinfo.G, 1);
sym = hpre6GPDSCH(carrier, pdsch, cw); 

% Plot a constellation diagram for the 4096-QAM symbols.
constDiagram = comm.ConstellationDiagram;
constDiagram.ShowReferenceConstellation = false;
constDiagram(sym);