% lars function
% Copyright of Hao Zhang and is based on the method proposed by Efron et al.
function [beta] = lars(x, y, count)
[n, m] = size(x);
mu_hat = zeros(n, 1);
beta = zeros(m, 1);

if (cond(x) > 1e8) % sensitivity to noise in data
    x = x .* (1 + rand(size(x)) * 0.001);
end
  
for k = 1:count
    c = x' * (y - mu_hat);
    c_max = max(abs(c));
    c_idx = find(abs(abs(c) - c_max) < 1e-4); % current covariates

    if (length(c_idx) ~= k) % more than one covariate was added this step
        return;
    end
    
    s = sign(c(c_idx));
    xa = x(:, c_idx) .* repmat(s', n, 1);
    beta_inc = (xa' * xa)^(-1) * ones(k, 1);
    
    u = pinv(xa') * ones(k, 1);
    a = x' * u;
    
    if (k == m) % the last step
        y_proj = x * (x \ y);
        finalgamma = (y_proj - mu_hat) ./ u;
        gamma = mean(finalgamma);
    else
        c_rest = setdiff(1:m, c_idx); % the rest of the covariates
        c = c(c_rest);
        a = a(c_rest);

        gammas = [(c_max - c) ./ (1 - a); (c_max + c) ./ (1 + a)];
        gamma = min(gammas(gammas > 1e-4)); % min positive gamma
    end

    mu_hat = mu_hat + gamma * u;
    beta(c_idx) = beta(c_idx) + gamma .* s .* beta_inc;
end
