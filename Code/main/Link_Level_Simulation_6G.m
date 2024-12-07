%% 6G Link-Level Simulation

% This script simulates the throughput of a pre-6G link using MATLAB.
% It leverages advanced 5G features while exploring extended bandwidths 
% and subcarrier spacings beyond the standard 5G NR specifications.


%% Initialize Simulation Parameters

simParameters = struct();      
simParameters.NFrames = 2;     
simParameters.SNRdB = -10:2:-6;
simParameters.enableParallelism = true; 

%% Configure Channel Estimator

simParameters.PerfectChannelEstimator = false; 

%% Configure Simulation Diagnostics

simParameters.DisplaySimulationInformation = true; 
simParameters.DisplayDiagnostics = false;        

%% Configure Carrier, PDSCH, and Propagation Channel

simParameters.Carrier = struct(); 
simParameters.Carrier.NSizeGrid = 330; 
simParameters.Carrier.SubcarrierSpacing = 120; 

% Calculate the number of slots per frame based on subcarrier spacing
if simParameters.Carrier.SubcarrierSpacing == 120
    simParameters.Carrier.SlotsPerFrame = 14;  
elseif simParameters.Carrier.SubcarrierSpacing == 60
    simParameters.Carrier.SlotsPerFrame = 20;  
elseif simParameters.Carrier.SubcarrierSpacing == 15
    simParameters.Carrier.SlotsPerFrame = 40;  
else
    error('Unsupported Subcarrier Spacing');
end

% PDSCH settings
simParameters.PDSCH = struct();  
simParameters.PDSCH.PRBSet = 0:simParameters.Carrier.NSizeGrid-1; 
simParameters.PDSCH.SymbolAllocation = [0, simParameters.Carrier.SlotsPerFrame];
simParameters.PDSCH.NumLayers = 1; 

% Modulation and codeword configuration based on SNR range
simParameters.PDSCH.Modulation = '16QAM';  
simParameters.PDSCHExtension = struct();
simParameters.PDSCHExtension.TargetCodeRate = 490/1024;

% Disable Phase Tracking Reference Signal (PT-RS)
simParameters.PDSCH.EnablePTRS = false;

% Hybrid Automatic Repeat Request (HARQ) settings
simParameters.PDSCHExtension.NHARQProcesses = 16; 
simParameters.PDSCHExtension.EnableHARQ = true;   

% LDPC decoder settings
simParameters.PDSCHExtension.LDPCDecodingAlgorithm = 'Normalized min-sum';
simParameters.PDSCHExtension.MaximumLDPCIterationCount = 20;

% Antenna configuration
simParameters.NTxAnts = 32;
simParameters.NRxAnts = 2; 

% Propagation channel settings
simParameters.DelayProfile = 'CDL-A';   
simParameters.DelaySpread = 10e-9;      
simParameters.MaximumDopplerShift = 70; 

% Validate configuration
validateParameters(simParameters); 

%% Configure Parallel Execution

if (simParameters.enableParallelism && canUseParallelPool)
    pool = gcp; 
    numWorkers = pool.NumWorkers; 
    maxNumWorkers = pool.NumWorkers;
else
    if (~canUseParallelPool && simParameters.enableParallelism)
        warning("Parallelism requires the Parallel Computing Toolbox.");
    end
    numWorkers = 1;    
    maxNumWorkers = 0; 
end

% Define random stream for reproducibility
str1 = RandStream('Threefry', 'Seed', 1);
constantStream = parallel.pool.Constant(str1);

% Calculate number of slots per worker
numSlotsPerWorker = ceil((simParameters.NFrames * simParameters.Carrier.SlotsPerFrame) / numWorkers);
disp("Parallelism: " + simParameters.enableParallelism);
disp("Number of workers: " + numWorkers);
disp("Number of slots per worker: " + numSlotsPerWorker);
disp("Total number of frames: " + (numSlotsPerWorker * numWorkers) / simParameters.Carrier.SlotsPerFrame);


%% PDSCH Link-Level Simulation

% Results storage
result = struct('NumSlots', 0, 'NumBits', 0, 'NumCorrectBits', 0);
results = repmat(result, numWorkers, numel(simParameters.SNRdB)); 

% Parallel processing:
parfor pforIdx = 1:numWorkers
    stream = constantStream.Value; 
    stream.Substream = pforIdx;   
    RandStream.setGlobalStream(stream); 

    % Per worker processing
    results(pforIdx, :) = pdschLink(simParameters, numSlotsPerWorker, pforIdx, constantStream);
end

%% Process and Display Results

% Calculate and display throughput results.

[throughput, throughputMbps, summaryTable] = processResults(simParameters, results);
disp(summaryTable);

% Plot throughput vs. SNR
figure;
plot(simParameters.SNRdB,throughput,'o-.')
xlabel('SNR (dB)'); ylabel('Throughput (%)'); grid on;
title(sprintf('%s (%dx%d) / NRB=%d / SCS=%dkHz', ...
              simParameters.DelayProfile,simParameters.NTxAnts,simParameters.NRxAnts, ...
              simParameters.Carrier.NSizeGrid,simParameters.Carrier.SubcarrierSpacing));