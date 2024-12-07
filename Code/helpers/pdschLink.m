function results = pdschLink(simParameters, numSlotsPerWorker, workerIdx, constantStream)
    % pdschLink function to process PDSCH (Physical Downlink Shared Channel) data
    % based on given simulation parameters and worker index.
    %
    % Inputs:
    %   simParameters: Struct containing simulation parameters such as Carrier,
    %                  Channel, and others.
    %   numSlotsPerWorker: Number of slots to be processed by each worker.
    %   workerIdx: Index of the current worker for random number generation control.
    %   constantStream: A constant stream object used for random number generation.
    %
    % Outputs:
    %   results: A struct containing the computed results (NumSlots, NumBits, 
    %            and NumCorrectBits).
    
    % Initialize the random stream for reproducibility (without using Substream)
    stream = constantStream.Value; % Extract the stream from the constant
    stream.Substream = workerIdx;   % Set substream value to worker index
    RandStream.setGlobalStream(stream); % Set global random stream for each worker
    
    % Initialize results structure
    results = struct('NumSlots', 0, 'NumBits', 0, 'NumCorrectBits', 0);
    
    % Example computation logic (replace with actual PDSCH calculation)
    % Process each slot in the worker's allocated number of slots
    for slotIdx = 1:numSlotsPerWorker
        % Example: Placeholder for actual PDSCH calculation
        % Replace this with the actual PDSCH processing logic
        results.NumSlots = results.NumSlots + 1;
        results.NumBits = results.NumBits + randi([1000, 5000]); % Example bit count
        results.NumCorrectBits = results.NumCorrectBits + randi([900, 4500]); % Example correct bit count
    end
end
