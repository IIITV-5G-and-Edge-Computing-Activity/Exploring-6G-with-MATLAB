function validateParameters(simParameters)
    % validateParameters validates the consistency of simulation parameters.
    % Input:
    %   simParameters: Structure containing the simulation parameters.

    % Check Carrier configuration
    assert(isfield(simParameters.Carrier, 'NSizeGrid') && simParameters.Carrier.NSizeGrid > 0, ...
           'Carrier.NSizeGrid must be a positive integer.');
    assert(isfield(simParameters.Carrier, 'SubcarrierSpacing') && simParameters.Carrier.SubcarrierSpacing > 0, ...
           'Carrier.SubcarrierSpacing must be a positive integer.');

    % Check PDSCH configuration
    assert(isfield(simParameters.PDSCH, 'Modulation'), 'PDSCH.Modulation is missing.');
    assert(isfield(simParameters.PDSCH, 'NumLayers') && simParameters.PDSCH.NumLayers > 0, ...
           'PDSCH.NumLayers must be a positive integer.');

    % Check Antenna configuration
    assert(simParameters.NTxAnts > 0 && simParameters.NRxAnts > 0, ...
           'Both NTxAnts and NRxAnts must be positive integers.');

    % Check SNR settings
    assert(~isempty(simParameters.SNRdB) && isnumeric(simParameters.SNRdB), ...
           'SNRdB must be a numeric array.');

    % Check HARQ settings
    if isfield(simParameters.PDSCHExtension, 'NHARQProcesses')
        assert(simParameters.PDSCHExtension.NHARQProcesses > 0, ...
               'NHARQProcesses must be a positive integer.');
    end

    % Display success message
    disp('Simulation parameters validated successfully.');
end