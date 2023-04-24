function [n, newEdges] = ahistc(R, binNo, minSample)
%AHISTCOUNTS Adaptive HISTogram bin Counts
%   Calls to histcounts but with bins with at least `minSample` data points
%   in each of them.
edges = linspace(min(R),max(R),binNo+1);
edges(end) = edges(end) + 1;
newEdges(1) = edges(1);
for i=2:length(edges)
    if sum(R >= newEdges(end) & R < edges(i)) > minSample
        newEdges = [newEdges edges(i)];
    end
end
newEdges(end) = edges(end);
[n, ~] = histcounts(R, newEdges);

if(n(end) < minSample)
    n(end-1) = n(end-1) + n(end);
    newEdges(end-1) = [];
end

if(isempty(n))
    n = 0;
    newEdges = [min(R), max(R)];
end
end