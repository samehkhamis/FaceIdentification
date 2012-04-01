% fitglm function
% modified from the published glmfit function of Ferencz et al.
function [b] = fitglm(x, y, nllfunc, linkfun, b0)
b = b0;
[nll] = feval(nllfunc, b, x, y, linkfun);

params = readparams();
niter = max(params.glmminitercount, ceil(length(y) / params.glmsetsize));

for i = 1:niter
    opt = optimset('Display', 'off', 'TolX', 0.05, 'MaxIter', 1000, ...
        'TolFun', max(5e4, abs(nll)) / (5e4 * 4));
    
    a = 1 + min((i - 1) * params.glmsetsize, max(0, length(y) - params.glmstepsize * params.glmsetsize));
    subsample = a:params.glmstepsize:min(a + params.glmstepsize * params.glmsetsize - 1, length(y));
    
    b = fminsearch(nllfunc, b, opt, x(subsample, :), y(subsample), linkfun);
    [nll] = feval(nllfunc, b, x, y, linkfun);
end
