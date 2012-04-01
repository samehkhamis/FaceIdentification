% readimage function
function [image] = readimage(filename)
im = imread(filename);

image.original = im;

if size(im, 3) == 3
    image.data = im2double(rgb2gray(im));
else
    image.data = im2double(im);
end

image.sobelh = edge(image.data, 'sobel', [], 'horizontal');
image.sobelv = edge(image.data, 'sobel', [], 'vertical');
image.log = edge(image.data, 'log');
image.canny = edge(image.data, 'canny');

image.gabor = zeros(size(image.data));
angles = [0 45 90 135];
phases = [0 90];

for anglei = 1:length(angles)
    for phasei = 1:length(phases)
        angle = angles(anglei);
        phase = phases(phasei);
        
        resp = filter2(gabor(5, angle, phase, 1, 1), image.data);
        
        minresp = min(resp(:));
        maxresp = max(resp(:));
        resp(resp < (minresp + 0.6 * (maxresp - minresp))) = 0;
        image.gabor = image.gabor + resp.^2;
    end
end

image.gabor = sqrt(image.gabor);
