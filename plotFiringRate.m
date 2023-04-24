function stimFire = plotFiringRate(allSessions,condMap,time)
condMap(condMap > 8) = condMap(condMap > 8) - 8;
numStimuli = max(condMap) - min(condMap) + 1;
gaussianWindow = gausswin(50);
numSess = size(allSessions, 1); 
stimFire = nan(9, 8);
for sess = 1:numSess
    figure
    for stimuli = 1:numStimuli
        stimuliIdx = find(condMap == stimuli);
        stimuliSessData = sum(allSessions(sess, stimuliIdx, :), 2);
        z = size(stimuliSessData);
        stimuliSessData = reshape(stimuliSessData,[z(2:end) 1]);
        windowedData = filter(gaussianWindow, 1, stimuliSessData);
        des = 5200;
        stimFire(sess, stimuli) = windowedData(des);
        plot(time, windowedData)
        hold on
    end
    title(['Firing Rate for Session Number ', num2str(sess)])
    xlabel('time (ms)')
    ylabel('Rate (Hz)')
    legend('Deg1 (-135)', 'Deg1 (-90)', 'Deg1 (-45)', 'Deg1 (0)', ...
        'Deg1 (45)', 'Deg1 (90)', 'Deg1 (135)', 'Deg1 (180)')
end
end