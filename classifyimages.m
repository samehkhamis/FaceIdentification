% classifyimages function
function [matches] = classifyimages(classifier, images, matchcount)
disp('Computing score for each image ...');
allimages = images(:);
scores = scoreimages(classifier, allimages);

disp('Picking best matching images ...');
matches = repmat(struct('image', [], 'score', 0),  matchcount, 1);

for i = 1:matchcount
    [score, index] = max(scores);
    matches(i).image = allimages(index).original;
    matches(i).score = score;
    scores(index) = -1e8;
end

disp('Matching done!');
