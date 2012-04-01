% scoreimage function
function [scores] = scoreimages(classifier, images)
global params

% Prepare scores array
allimages = images(:);
scores = zeros(length(allimages), 1);

for i = 1:length(allimages)
    for pid = 1:length(classifier.patches)
        d = matchpatch(classifier.patches(pid), params.searchwindow, allimages(i));
        samep = max(1e-4, gampdf(d, classifier.dist(pid).same(2), classifier.dist(pid).same(1) / classifier.dist(pid).same(2)));
        diffp = max(1e-4, gampdf(d, classifier.dist(pid).diff(2), classifier.dist(pid).diff(1) / classifier.dist(pid).diff(2)));
        scores(i) = scores(i) + log2(samep / diffp);
    end
end
