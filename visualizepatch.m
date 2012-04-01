% visualizepatch function
function visualizepatch(patchdist)
ds = 0:0.001:2;
samep = gampdf(ds, patchdist.same(2), patchdist.same(1) / patchdist.same(2));
diffp = gampdf(ds, patchdist.diff(2), patchdist.diff(1) / patchdist.diff(2));

figure
plot(ds, samep, '-', ds, diffp, '-');
legend('Same', 'Different');
