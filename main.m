%% Q1 Getting Started - a & b
data = load('extracellular.mat');
data = data.all_data_with_noise_and_line;
SR   = 2400;
time = linspace(0, size(data, 2)/SR, size(data, 2));

figure
plot(time, data)
xlabel('time (s)')
ylabel('amplitude')
title('Raw data voltage amplitude against time')

figure
histogram(data, 'Normalization','probability')
title('Histogram of Recorded Voltage Amplitude')

%% Q1 Applying Filter on Data
ftype        = 'high';
order        = 7;
fc           = 300;
[b, a]       = butter(order, fc/(SR / 2), ftype);
filteredData = filtfilt(b, a, data);

freqz(b, a)

figure
plot(time, data, time, filteredData)
xlabel('time (s)')
ylabel('amplitude')
title('Comparison of Raw & Filtered Data in Time Series')
legend('Raw data', 'Filtered data')

T = 1/SR;             % Sampling period       
L = size(data, 2);             % Length of signal

y1 = fft(data);
y2 = fft(filteredData);
P21 = abs(y1/L);
P11 = P21(1:L/2+1);
P11(2:end-1) = 2*P11(2:end-1);

P22 = abs(y2/L);
P12 = P22(1:L/2+1);
P12(2:end-1) = 2*P12(2:end-1);
f = SR*(0:(L/2))/L;

figure 
plot(f, P12) 
title('Single-Sided Amplitude Spectrum of Filtered Data')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%% Q1 Spike Detection
sigma_n = median(abs(filteredData) / 0.6745);
theta   = 5 * sigma_n;
peakIdx = find_peaks(filteredData);
% Part g
tmpIdx = find(abs(filteredData(peakIdx)) > theta);
spikeIdx = peakIdx(tmpIdx);
timeSerieLength = ceil(0.002 * SR * 2);
spikeTime = linspace(0, (timeSerieLength)/SR, timeSerieLength + 1);
spikeMatrix = nan(length(spikeIdx), timeSerieLength + 1);

for i = 1:length(spikeIdx)
    spikeMatrix(i, :) = filteredData(spikeIdx(i) - 5:spikeIdx(i) + 5);
end

% Part h
smoothTime = linspace(0, (timeSerieLength)/SR, 1000 * (timeSerieLength + 1));
figure
for i = 1:size(spikeMatrix, 1)
    yi = interp1(spikeTime, spikeMatrix(i, :), smoothTime, 'cubic');
    plot(smoothTime, yi)
    hold on
end

%% Q1 Extracting Features
[coeff,score,latent] = pca(spikeMatrix);
reducedData          = score(:, 1:3);
PC1                  = coeff(1, :);
PC2                  = coeff(2, :);
PC3                  = coeff(3, :);

%% Clustering the Spikes
% Part k & l
plotClusters(reducedData, 3)

% Part m
plotClusters(reducedData, 2)
plotClusters(reducedData, 4)
plotClusters(reducedData, 5)

%% Part n
givenSpikes    = load('spikes.mat').SpikeInds;
neighborhood   = 0;
numNeighbors   = 0;
for neighbor = 1:length(neighborhood)
    numNeighbors = numNeighbors + sum(ismember(spikeIdx, givenSpikes + neighborhood(neighbor)));
end

%% Part o
new_theta = 0.9 * max(abs(filteredData));
newtmpIdx = find(abs(filteredData(peakIdx)) > new_theta);
newspikeIdx = peakIdx(newtmpIdx);
newspikeMatrix = nan(length(newspikeIdx), timeSerieLength + 1);

for i = 1:length(spikeIdx)
    newspikeMatrix(i, :) = filteredData(newspikeIdx(i) - 5:newspikeIdx(i) + 5);
end

%% Part p
tsneSpikes = tsne(spikeMatrix, 'NumDimensions', 3);
% Part k & l
plotClusters(tsneSpikes, 3)

% Part m
plotClusters(tsneSpikes, 2)
plotClusters(tsneSpikes, 4)
plotClusters(tsneSpikes, 5)

%% Q2
%% Load Data
parentFold = 'abolqasemi dataset/';
condFile   = 'cond.mat';
condMap    = load(strcat(parentFold, condFile)).Cond;
SR         = 1000;
initTime   = 0;
endTime    = 8;
time       = linspace(initTime, endTime * 1000, SR * (endTime - initTime));

%% Load Data
allSessions = nan(9, length(condMap), length(time));
dirFiles = {dir(parentFold).name};
numFiles = length(dirFiles);
accFiles = 1;
for i = 1:numFiles
    file = dirFiles(i);
    sess = 0;
    if length(file{1,1}) > 3
        if strcmp(file{1,1}(1:5), 'Spike')
            spikeCell = load(strcat(parentFold, file{1, 1})).su;
            if size(spikeCell, 2) > 0
                while sess < size(spikeCell, 2)
                    spikeData = double(spikeCell{1, sess + 1});
                    allSessions(accFiles, :, :) = spikeData;
                    accFiles = accFiles + 1;
                    sess = sess + 1;
                end
            else
                continue
            end
        end
    end
end

%% Raster Plot
plotRaster(allSessions,condMap,time)

%% PSTH 
plotPSTH(allSessions,condMap,time)

%% Firing Rate - a
frate = plotFiringRate(allSessions,condMap,time);
[most, mostIdx]   = max(sum(frate, 1));
[least, leastIdx] = min(sum(frate, 1));

%% Firing Rate - b
plotFiringRatewithCI(allSessions, condMap, time, mostIdx, leastIdx)

%% Q3 - c
plotMutualInformation(allSessions, condMap)

%% Q3 - d
plotMutualScatter(allSessions, condMap)
%% Q4 - Split Data
allSessions = permute(allSessions, [2 1 3]);
cv          = cvpartition(size(allSessions, 1),'HoldOut',0.3);
testIdx     = cv.test;
% Separate to training and test data
dataTrain   = allSessions(~testIdx, :, :);
dataTest    = allSessions(testIdx, :, :);
condMap(condMap > 8) = condMap(condMap > 8) - 8;
condTrain   = condMap(~testIdx);
condTest    = condMap(testIdx);

%% SVM Classifier
timeWindow    = 150;
windowStride  = 25;
initTime      = 0;
endTime       = 8;
numSess       = size(allSessions, 1);
miTime        = initTime:windowStride:(endTime * 1000-timeWindow);
windowedData  = nan(size(allSessions, 1), size(allSessions, 2), size(miTime, 2));
for t = 1:length(miTime)
    windowedData(:, :, t) = mean(allSessions(:, :, (miTime(t)+1):(miTime(t) + timeWindow)), 3);
end

%% Plotting Recall for degree
recall = load('recall_degree.mat').a;
recall = permute(recall, [1, 3, 2]);
timeWindow    = 150;
windowStride  = 25;
initTime      = 0;
endTime       = 8;
x1 = -2000:windowStride:0;
x2 = 0:windowStride:2000;
y = 180:-45:-135;
C = squeeze(mean(recall, 1));
C = flip(C);
clims = [0 0.4];
imagesc(x1, y, C(:, 121:211), clims)
n = 10000000;
colourmap = [1 1 1; parula( n )];
colormap(colourmap)
colorbar
ylabel('Preferred location (deg)')
figure
imagesc(x2, y, C(:, 221:311), clims)
n = 10000000;
colourmap = [1 1 1; parula( n )];
colormap(colourmap)
colorbar
ylabel('Preferred location (deg)')

%% Plotting Recall for radius
recall = load('recall_radius.mat').a;
recall = permute(recall, [1, 3, 2]);
timeWindow    = 150;
windowStride  = 25;
initTime      = 0;
endTime       = 8;
x1 = -2000:windowStride:0;
x2 = 0:windowStride:2000;
y = 1:1:2;
C = squeeze(mean(recall, 1));
C = flip(C);
clims = [0 1];
imagesc(x1, y, C(:, 121:211), clims)
n = 10000000;
colourmap = [1 1 1; parula( n )];
colormap(colourmap)
colorbar
ylabel('Preferred radius')
figure
imagesc(x2, y, C(:, 221:311), clims)
n = 10000000;
colourmap = [1 1 1; parula( n )];
colormap(colourmap)
colorbar
ylabel('Preferred radius')