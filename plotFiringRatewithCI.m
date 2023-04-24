function fig = plotFiringRatewithCI(allSessions, condMap, time, mostIdx, leastIdx)
gaussianWindow = gausswin(50);
numSess = size(allSessions, 1); 
stimArr = [leastIdx, mostIdx];
options.alpha = 0.2;
options.line_width = 2;
options.color_area = {'red', 'blue'}; 
options.color_line = {'red', 'blue'};

for stimuli = 1:length(stimArr)
    stimulidata = [];
    for sess = 1:numSess
        stimuliIdx = find(condMap == stimArr(stimuli));
        stimuliSessData = sum(allSessions(sess, stimuliIdx, :), 2);
        z = size(stimuliSessData);
        stimuliSessData = reshape(stimuliSessData,[z(2:end) 1]);
        windowedData = filter(gaussianWindow, 1, stimuliSessData);
        stimulidata = [stimulidata; windowedData];
    end
    mymean          = mean(stimulidata, 1);
    mySE            = std(stimulidata, 1) / sqrt(numSess);
    SE1 = mymean + mySE;
    SE2 = mymean - mySE;
    time2 = [time, fliplr(time)];
    inBetween = [SE1, fliplr(SE2)];
    patch = fill(time2, inBetween, options.color_area{1, stimuli}, 'HandleVisibility','off');
    set(patch, 'edgecolor', 'none');
    set(patch, 'FaceAlpha', options.alpha);
    hold on
    plot(mymean, 'color', options.color_line{1, stimuli}, 'LineWidth',options.line_width)
    hold on
end
title(['Firing Rate for max & min stimuli'])
xlabel('time (ms)')
ylabel('Rate (Hz)')
legend('Least', 'Most')
end