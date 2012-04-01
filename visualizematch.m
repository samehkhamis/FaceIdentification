% visualizematch function
function visualizematch(image, patches)
figure;
imshow(image);

colorstep = 1 / (length(patches) - 1);
red = 1;
green = 0;

for i = 1:length(patches)
    rectangle('Position', [patches(i).x patches(i).y patches(i).sx patches(i).sy], 'Curvature', [0.3 0.3], 'LineWidth', 2, 'EdgeColor', [red green 0]);
    red = max(0, red - colorstep);
    green = min(1, green + colorstep);
end
