function fig = plotMutualScatter(allSessions, condMap)
timeWindow    = 150;
windowStride  = 25;
initTime      = 0;
endTime       = 8;
numSess       = size(allSessions, 1);
miTime        = initTime:windowStride:(endTime * 1000-timeWindow);
miInformation = nan(size(miTime));
scatdata      = [];
for sess = 1:numSess
    for t = 1:length(miTime)
        windowedData     = allSessions(sess, :, (miTime(t)+1):(miTime(t) + 150));
        stimSignal       = sum(windowedData, 3);
        z = size(stimSignal);
        stimSignal = reshape(stimSignal,[z(2:end) 1]);
        miInformation(t) = minf(stimSignal, condMap, 10, 10);
    end
    encode = mean(miInformation(121:137));
    saccade = mean(miInformation(201:217));
    scatdata = [scatdata; [encode saccade]];
end
[h,p,ci,stats] = ttest(scatdata(:, 1), scatdata(:, 2));
disp(p)
x = 0:0.01:1;
y = x;
plot(x, y, 'b--')
hold on
scatter(scatdata(:, 1), scatdata(:, 2), 'filled')
xlabel('Spatial discriminability (bit) [Enc]')
ylabel(('Spatial discriminability (bit) [Sac]'))
title('Scatter plot for Saccade and Encoding')
end