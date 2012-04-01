% readtestimage function
function [image] = readtestimage(filename)
global params

% Read image
testdir = fullfile(fileparts(mfilename('fullpath')), params.testdir);
image = readimage(fullfile(testdir, filename));
