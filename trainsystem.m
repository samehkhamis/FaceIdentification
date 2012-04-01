% trainsystem function
% Read images, find patches, collect features from patches
% Match to same and different images and fit data to a glm
% Note: no scale-space
function [sys] = trainsystem()
global params

% Read the images from the data directory
traindir = fullfile(fileparts(mfilename('fullpath')), params.traindir);
data = dir(traindir);
images = repmat(struct('original', [], 'data', [], 'sobelh', [], 'sobelv', [], 'log', [], 'canny', [], 'gabor', []), ...
    params.samecount, 1);
x = 1; y = 1;

disp('Caching images from the training dataset ...');
for i = 1:length(data)
    if data(i).isdir == 0
        images(x, y) = readimage(fullfile(traindir, data(i).name));
        x = x + 1;
        if x > params.samecount
            x = 1;
            y = y + 1;
        end
    end
end

% Set up the patch and feature variables (y, x)
n = size(images, 2);
m = size(images, 1);
sstep = m - 1;
dstep = 2 * (n - 1);

patches.features = zeros(1, params.featcount);
patches.samed = zeros(sstep, 1);
patches.diffd = zeros(dstep, 1);
spid = 1;
dpid = 1;
pid = 1;

% Match each image to same and different images
disp('Matching each image to same and different images ...');

for j = 1:n
    for i = 1:m
        % Find all patches of a given size
        imsy = size(images(i, j).data, 1);
        imsx = size(images(i, j).data, 2);
        
        for p = 1:length(params.patchsize)
            sy = params.patchsize(p, 1);
            sx = params.patchsize(p, 2);
            
            for y = 1:params.patchspacing(p, 2):imsy
                for x = 1:params.patchspacing(p, 1):imsx
                    xf = x + sx - 1;
                    yf = y + sy - 1;
                    
                    if yf <= imsy && xf <= imsx
                        % Compute features for each patch
                        [patch, feat] = computefeatures(images(i, j), x, y, sx, sy);
                        patches.features(pid, :) = feat;
                        
                        % The patch must not have a constant value for normxcorr2 to work
                        if mean(patch.data == patch.data(1,1)) == 1
                            patch.data(1, 1) = min(1, max(0, patch.data(1, 1) - 0.0002) + 0.0001);
                        end
                        
                        % Match patches to same and different images
                        diffi = randperm(m);
                        diffi = diffi(1:2);
                        
                        patches.samed(spid:spid + sstep - 1) = matchpatch(patch, params.searchwindow, ...
                            [images(1:i - 1, j); images(i + 1:m, j)]);
                        patches.diffd(dpid:dpid + dstep - 1) = matchpatch(patch, params.searchwindow, ...
                            [images(diffi, 1:j - 1) images(diffi, j + 1:n)]);
                        
                        spid = spid + sstep;
                        dpid = dpid + dstep;
                        pid = pid + 1;
                    end
                end
            end
        end
    end
end

% Normalize features to clamp outliers
disp('Normalizing the feature data ...');
normalization.mean = zeros(1, params.featcount);
normalization.std = zeros(1, params.featcount);

for i = 1:params.featcount
    normalization.mean(i) = mean(patches.features(:, i));
    normalization.std(i) = std(patches.features(:, i));
    patches.features(:, i) = normalizefeatures(patches.features(:, i), normalization.mean(i), normalization.std(i));
end

% GLM fitting for a gamma distribution
disp('Fitting the data to a GLM ...');
samefilter = ceil(1 / sstep:1 / sstep:length(patches.features));
difffilter = ceil(1 / dstep:1 / dstep:length(patches.features));
samefeatfilter = find(lars(patches.features(samefilter, :), patches.samed, params.selfeatcount));
difffeatfilter = find(lars(patches.features(samefilter, :), patches.samed, params.selfeatcount));
sameb = fitgammaglm(patches.features(samefilter, samefeatfilter), patches.samed);
diffb = fitgammaglm(patches.features(difffilter, difffeatfilter), patches.diffd);
clear patches

%sys.patches = patches;
sys.images = struct('original', {images(:).original}, 'data', {images(:).data});
sys.samefeatfilter = samefeatfilter;
sys.difffeatfilter = difffeatfilter;
sys.sameb = sameb;
sys.diffb = diffb;
sys.normalization.mean = normalization.mean;
sys.normalization.std = normalization.std;

% Learning the threshold by fitting 2 gaussian distributions to same and
% different scores and finding their intersection
samescores = zeros(sstep, 1);
diffscores = zeros(dstep, 1);
ssid = 1;
dsid = 1;

disp('Learning a threshold for matching ...');
for j = 1:n
    for i = 1:m
        classifier = generateclassifier(sys, images(i, j));
        
        diffi = randperm(m);
        diffi = diffi(1:2);
        samescores(ssid:ssid + sstep - 1) = scoreimages(classifier, [images(1:i - 1, j); images(i + 1:m, j)]);
        diffscores(dsid:dsid + dstep - 1) = scoreimages(classifier, [images(diffi, 1:j - 1) images(diffi, j + 1:n)]);
        
        ssid = ssid + sstep;
        dsid = dsid + dstep;
    end
end

[mu1, sig1] = normfit(samescores);
[mu2, sig2] = normfit(diffscores);
rng = mu2:0.001:mu1;
normdiff = abs(normpdf(rng, mu1, sig1) - normpdf(rng, mu2, sig2));
normmin = find(normdiff - min(normdiff) == 0);
sys.threshold = rng(normmin(1));

disp('Training completed!');
