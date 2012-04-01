% System functions

% To train a system (make sure to edit setparams.m first)
setparams;
sys = trainsystem;

% To generate a classifier
c = generateclassifier(sys, readtestimage('image.jpg'));

% To match to all images in the training set and pick the top ten
results = classifyimages(c, sys.images, 10);

% To match two images from the test set
result = matchtestimages(sys, 'image1.jpg', 'image2.jpg');

% To test the system on the test set
results = testsystem(sys);

% To draw the distribution of patch 1 of a classifier
visualizepatch(c.dist(1));

% To draw the classifier image with the patches visible
visualizematch(c.image, c.patches);
