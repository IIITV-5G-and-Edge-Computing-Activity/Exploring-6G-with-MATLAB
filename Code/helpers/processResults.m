function [throughput, throughputMbps, summaryTable] = processResults(simParameters, results)
    % processResults function to process and analyze simulation results.
    %
    % Inputs:
    %   simParameters: Struct containing simulation parameters such as Carrier,
    %                  Channel, and others.
    %   results: The results from each worker, as returned by pdschLink.
    %
    % Outputs:
    %   throughput: Throughput calculated based on results.
    %   throughputMbps: Throughput in Mbps.
    %   summaryTable: A table containing summarized results (SNR, bits, Tr Blocks, Frames, Throughput, Mbps).
    
    % Initialize variables for throughput calculations
    throughput = zeros(1, numel(simParameters.SNRdB)); % Pre-allocate throughput
    simulatedBits = zeros(1, numel(simParameters.SNRdB)); % To store simulated bits
    numTrBlocks = zeros(1, numel(simParameters.SNRdB)); % To store transport blocks
    numFrames = simParameters.NFrames * ones(1, numel(simParameters.SNRdB)); % Number of frames
    
    % Loop through each SNR value
    for idx = 1:numel(simParameters.SNRdB)
        numSlots = 0;
        numBits = 0;
        numCorrectBits = 0;
        
        % Aggregate results across all workers
        for workerIdx = 1:size(results, 1)
            numSlots = numSlots + results(workerIdx, idx).NumSlots;
            numBits = numBits + results(workerIdx, idx).NumBits;
            numCorrectBits = numCorrectBits + results(workerIdx, idx).NumCorrectBits;
        end
        
        % Calculate throughput (percentage of correct bits)
        throughput(idx) = numCorrectBits / numBits * 100; % Percentage of correct bits
        
        % Calculate throughput in Mbps
        throughputMbps(idx) = throughput(idx) * numBits / 1e6; % Convert to Mbps
        
        % Calculate simulated bits (this is a placeholder; you may replace with actual values from your simulation)
        simulatedBits(idx) = numBits;
        
        % Calculate the number of transport blocks (again, placeholder for now)
        numTrBlocks(idx) = numSlots;  % Replace with the actual calculation if different
    end
    
    % Create the summary table
    summaryTable = table(simParameters.SNRdB', simulatedBits', numTrBlocks', numFrames', throughput', throughputMbps', ...
                         'VariableNames', {'SNR_dB', 'Simulated_Bits', 'Num_TrBlocks', 'Num_Frames', 'Throughput_Percentage', 'Throughput_Mbps'});
end