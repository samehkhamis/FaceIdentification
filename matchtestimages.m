% matchimages function
function [match, score] = matchtestimages(sys, leftfilename, rightfilename)
disp('Generating a classifier for the left image ...');
classifier = generateclassifier(sys, readtestimage(leftfilename));

disp('Matching the right image using the classifier ...');
imright = readtestimage(rightfilename);
score = scoreimages(classifier, imright);

disp('Matching done!');
match = score > sys.threshold;
