% normalizefeatures function
function [normalized] = normalizefeatures(feat, mean, std)
featnorm = (feat - mean) ./ std;
normalized = 2 ./ (1 + exp(-featnorm)) - 1;
