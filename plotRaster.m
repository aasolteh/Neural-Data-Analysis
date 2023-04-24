function fig = plotRaster(allSessions,condMap,time)
[sortedCond, sortIdx] = sort(condMap,'ascend');
numSess = size(allSessions, 1); 
for sess = 1:numSess
    figure
    for t = 1:length(time)
        tmpData = allSessions(sess, :, t);
        tmpData = tmpData(sortIdx);
        numSpikesInTime = find(tmpData == 1);
        timeInTime      = time(t) * ones(size(numSpikesInTime));
        plot(timeInTime, numSpikesInTime, 'k.')
        hold on
    end
    xlabel('time (ms)')
    ylabel('trial number')
    title(['Raster Plot for Location Number ', num2str(sess)])
end
end