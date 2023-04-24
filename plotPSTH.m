function fig = plotPSTH(allSessions,condMap,time)
numStimuli = max(condMap) - min(condMap) + 1;
allStimuli = zeros(numStimuli, length(time));
numSess = size(allSessions, 1); 
gaussianWindow = gausswin(200);
for stimuli = 1:numStimuli
    stimuliIdx = find(condMap == stimuli);
    for sess = 1:numSess
        stimuliSessData = sum(allSessions(sess, stimuliIdx, :), 2);
        z = size(stimuliSessData);
        stimuliSessData = reshape(stimuliSessData,[z(2:end) 1]);
        allStimuli(stimuli, :) = stimuliSessData + allStimuli(stimuli, :);
    end
    windowedData = filter(gaussianWindow, 1, allStimuli(stimuli, :));
    figure
    bar(time, windowedData, 'histc')
    title(['PSTH for Stimuli Number ', num2str(stimuli)])
end
end