% generateclassifier function
% Read new image, find patches, collect features from patches
% Compute same and different dist, compute mutual info, pick top pn patches
function [classifier] = generateclassifier(sys, image)
global params

% Find all patches of a given size
patches = repmat(struct('x', 0, 'y', 0, 'sx', 0, 'sy', 0, 'data', []), 1, 1);
dist = repmat(struct('same', [], 'diff', []), 1, 1);
information = zeros(1, 1);
features = zeros(1, params.featcount);

disp('Collecting features ...');
imsy = size(image.data, 1);
imsx = size(image.data, 2);
pid = 1;
for p = 1:length(params.patchsize)
    sy = params.patchsize(p, 1);
    sx = params.patchsize(p, 2);
    for y = 1:params.patchspacing(p, 2):imsy
        for x = 1:params.patchspacing(p, 1):imsx
            xf = x + sx - 1;
            yf = y + sy - 1;
            if yf <= imsy && xf <= imsx
                % Compute normalized features for each patch
                [patch, feat] = computefeatures(image, x, y, sx, sy);
                features(pid, :) = normalizefeatures(feat, sys.normalization.mean, sys.normalization.std);
                
                % Calculate mutual information for patch
                patches(pid) = patch;
                dist(pid).same = 1 ./ max(1e-4, ([1 features(pid, sys.samefeatfilter)] * sys.sameb));
                dist(pid).diff = 1 ./ max(1e-4, ([1 features(pid, sys.difffeatfilter)] * sys.diffb));
                
                ds = 0.01:0.001:2;
                samep = gampdf(ds, dist(pid).same(2), dist(pid).same(1) / dist(pid).same(2));
                diffp = gampdf(ds, dist(pid).diff(2), dist(pid).diff(1) / dist(pid).diff(2));
                
                % Normalize for the entropy calculation
                samep = samep / max(samep);
                diffp = diffp / max(diffp);
                information(pid) = entropy(samep) + entropy(diffp) - entropy(samep .* diffp);
                
                pid = pid + 1;
            end
        end
    end
end

% Pick top patches to generate the classifier
toppatches = repmat(struct('x', 0, 'y', 0, 'sx', 0, 'sy', 0, 'data', []), 1, 1);
topdist = repmat(struct('same', [], 'diff', []), 1, 1);

disp('Generating classifier from most informative patches ...');
for i = 1:params.patchcount
    [info, index] = max(information);
    toppatches(i) = patches(index);
    topdist(i) = dist(index);
    
    % Decrease the information for dependent patches
    %for j = 1:length(information)
        %mi = 1 / exp(sqrt(sum((features(index, :) - features(j, :)).^2)) / 8);
        %mi = 1 / exp(sqrt((patches(index).x - patches(j).x).^2 + (patches(index).y - patches(j).y).^2) / 50);
        %information(j) = information(j) - mi;
    %end
    information(index) = -1e8;
end

disp('Classifier generated!');

classifier.image = image.original;
classifier.patches = toppatches;
classifier.dist = topdist;
