% matchpatch function
function [da] = matchpatch(patch, searchwindow, matchimages)
allimages = matchimages(:);
da = zeros(1, length(allimages));

for i = 1:length(allimages)
    imrsy = size(allimages(i).data, 1);
    imrsx = size(allimages(i).data, 2);

    % Find best matching patch in a search window
    xr = max(1, patch.x - searchwindow(1));
    yr = max(1, patch.y - searchwindow(2));
    xrf = min(imrsx, patch.x + patch.sx - 1 + searchwindow(1));
    yrf = min(imrsy, patch.y + patch.sy - 1 + searchwindow(2));
    
    % Compute normxcorr2
    if xrf - xr + 1 < patch.sx
        xr = max(1, xrf - patch.sx + 1);
        xrf = min(imrsx, xr + patch.sx - 1);
    end
    
    if yrf - yr + 1 < patch.sy
        yr = max(1, yrf - patch.sy + 1);
        yrf = min(imrsy, yr + patch.sy - 1);
    end
    
    ncc = normxcorr2(patch.data, allimages(i).data(yr:yrf, xr:xrf));
    da(i) = 1 - max(ncc(:));
end
