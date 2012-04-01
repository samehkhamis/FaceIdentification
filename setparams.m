% readparams function
function setparams()
global params
params.traindir = 'train';
params.testdir = 'test';
params.samecount = 5;
params.patchsize = [25 25; 50 50; 25 50; 50 25];
params.patchspacing = [12 12; 25 25; 25 12; 12 25];
params.searchwindow = [12 12];
params.featcount = 54;
params.selfeatcount = 16;
params.glmsetsize = 40000;
params.glmminitercount = 6;
params.glmstepsize = 3;
params.patchcount = 10;
