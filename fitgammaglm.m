% fitglm function
function [b] = fitgammaglm(x, y)
% Linear model estimation of initial b
x = [ones(length(x), 1) x];
bmu = x \ y;
mu = x * bmu;

bs = x \ abs(y - mu);
s = x * bs;
v = mu.^2 ./ s.^2;
bv = x \ v;

b = fitglm(x, y, @nllgamma, @linkrecip, [bmu bv]);

function [nll] = nllgamma(b, x, y, linkfun)
params = feval(linkfun, b, x);
mu = params(:, 1);
v = params(:, 2);
nll = -sum(v .* (-y ./ mu - log(mu)) + v .* log(y) + v .* log(v) - gammaln(v));

function [params] = linkrecip(b, x)
params = 1 ./ max(1e-4, x * b);
