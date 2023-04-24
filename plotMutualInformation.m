function fig = plotMutualInformation(allSessions, condMap)
timeWindow    = 150;
windowStride  = 25;
initTime      = 0;
endTime       = 8;
numSess       = size(allSessions, 1);
miTime        = initTime:windowStride:(endTime * 1000-timeWindow);
miInformation = nan(size(miTime));
for sess = 1:numSess
    for t = 1:length(miTime)
        windowedData     = allSessions(sess, :, (miTime(t)+1):(miTime(t) + 150));
        stimSignal       = sum(windowedData, 3);
        z = size(stimSignal);
        stimSignal = reshape(stimSignal,[z(2:end) 1]);
        miInformation(t) = minf(stimSignal, condMap, 10, 10);
    end
    figure
    plot(miTime, miInformation)
    xlabel('time (ms)')
    ylabel('mutual information (bit)')
    title(['Mutual Information for Session Number ', num2str(sess)])
end
end