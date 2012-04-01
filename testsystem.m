% testsystem function
function [results] = testsystem(sys)
global params

% Read test image names
testdir = fullfile(fileparts(mfilename('fullpath')), params.testdir);
data = dir(testdir);
images = repmat(struct('original', [], 'data', [], 'sobelh', [], 'sobelv', [], 'log', [], 'canny', [], 'gabor', []), ...
    params.samecount, 1);
x = 1; y = 1;

disp('Caching images from the test dataset ...');
for i = 1:length(data)
    if data(i).isdir == 0
        images(x, y) = readimage(fullfile(testdir, data(i).name));
        x = x + 1;
        if x > params.samecount
            x = 1;
            y = y + 1;
        end
    end
end

% Set up variables
disp('Computing scores for same and different images ...');
n = size(images, 2);
m = size(images, 1);
sstep = m - 1;
dstep = m * (n - 1);
sid = 1;
did = 1;
results = struct('same', [], 'diff', []);

for j = 1:n
    for i = 1:m
        classifier = generateclassifier(sys, images(i, j));
        results.same(sid:sid + sstep - 1) = scoreimages(classifier, [images(1:i - 1, j); images(i + 1:m, j)]) > sys.threshold;
        results.diff(did:did + dstep - 1) = scoreimages(classifier, [images(:, 1:j - 1) images(:, j + 1:n)]) > sys.threshold;
        
        sid = sid + sstep;
        did = did + dstep;
    end
end

disp('Testing done!');
