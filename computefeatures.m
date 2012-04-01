% computefeatures function
function [patch, features] = computefeatures(image, x, y, sx, sy)
xf = x + sx - 1;
yf = y + sy - 1;

patch.x = x;
patch.y = y;
patch.sx = sx;
patch.sy = sy;
patch.data = image.data(y:yf, x:xf);

psobelh = image.sobelh(y:yf, x:xf);
psobelv = image.sobelv(y:yf, x:xf);
plog = image.log(y:yf, x:xf);
pcanny = image.canny(y:yf, x:xf);
pgabor = image.gabor(y:yf, x:xf);

features = [x y sx sy min(patch.data(:)) max(patch.data(:)) ...
    mean(patch.data(:)) median(patch.data(:)) var(patch.data(:)) ...
    mean(patch.data(:) > 0.95) mean(patch.data(:) < 0.05) ...
    (sum(sum(patch.data(:, 1:round(end / 2)))) - sum(sum(patch.data(:, round(end / 2) + 1:end)))) ...
    (sum(sum(patch.data(1:round(end / 2), :))) - sum(sum(patch.data(round(end / 2) + 1:end, :)))) ...
    mean(psobelh(:)) mean(psobelv(:)) mean(plog(:)) mean(pcanny(:)) mean(pgabor(:))];

features = [features features.^2 features.^3];
