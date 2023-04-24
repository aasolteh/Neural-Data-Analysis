function out = plotClusters(data, numClusters)
[idx,C] = kmeans(data, numClusters);
figure
subplot(3, 1, 1)
gscatter(data(:,1),data(:,2),idx)
hold on
plot(C(:,1),C(:,2),'kx')
xlabel('Principle Component I')
ylabel('Principle Component II')
title([num2str(numClusters), '-Clustered Waveforms based on PC1 & PC2'])

subplot(3, 1, 2)
gscatter(data(:,1),data(:,3),idx)
hold on
plot(C(:,1),C(:,2),'kx')
xlabel('Principle Component I')
ylabel('Principle Component III')
title([num2str(numClusters), '-Clustered Waveforms based on PC1 & PC3'])
subplot(3, 1, 3)
gscatter(data(:,2),data(:,3),idx)
hold on
plot(C(:,1),C(:,2),'kx')
xlabel('Principle Component II')
ylabel('Principle Component III')
title([num2str(numClusters), '-Clustered Waveforms based on PC2 & PC3'])
end