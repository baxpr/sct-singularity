q = dicominfo('../INPUTS/fmri_501.dcm');

%%
% Get volumes times from Philips private field
clear vtimes
for f = 1:nframes
	item = sprintf('Item_%d',f);
	vtimes(f,1) = q.PerFrameFunctionalGroupsSequence.(item).Private_2005_140f.Item_1.Private_2005_10a0;
end
uvtimes = unique(vtimes);
vdelta = diff(uvtimes);
voltime1 = mean(vdelta);

% Get voltime from acq duration field
nvols = q.PerFrameFunctionalGroupsSequence.Item_1.Private_2005_140f.Item_1.NumberOfTemporalPositions;
voltime2 = q.AcquisitionDuration/nvols;

if abs(voltime2-voltime1)>0.01
	error('Volume time error > 10ms');
end


