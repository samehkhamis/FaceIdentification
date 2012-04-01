% gabor function
% example: gabor(4, 45, 0, 1, 1)
function gb = gabor(wavelength, angle, phase, aspect, bandwidth)
b2 = 2.^bandwidth;
sigma = 1 / pi * sqrt(log(2) / 2) * (b2 + 1) / (b2 - 1) * wavelength;
sz = fix(6 * wavelength);

[x y] = meshgrid(-fix(sz / 2):fix(sz / 2), fix(-sz / 2):fix(sz / 2));
gb = exp(-(x.^2 + y.^2 .* aspect.^2) / (2 .* sigma.^2)) .* cos(2 * pi / wavelength * x + phase);
gb = imrotate(gb, angle, 'bilinear');
