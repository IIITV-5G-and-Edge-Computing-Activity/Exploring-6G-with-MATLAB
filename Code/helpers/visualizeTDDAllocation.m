function visualizeTDDAllocation(tddConfig)
    % Visualize TDD Allocation (simple example)
    figure;
    hold on;
    numSlots = tddConfig.TDDPeriod;
    slotWidth = 1;
    for i = 0:numSlots-1
        if ismember(i, tddConfig.SlotAllocation)
            bar(i, 1, 'FaceColor', 'g'); % Downlink slots in green
        else
            bar(i, 1, 'FaceColor', 'r'); % Uplink slots in red
        end
    end
    xlabel('Slot Index');
    ylabel('Slot Type');
    title('TDD Allocation');
    legend('Downlink', 'Uplink');
    hold off;
end