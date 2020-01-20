%%
q = dicominfo('fmri.dcm');


%%
clear FrameAcquisitionDatetime dt
fs = fields(q.PerFrameFunctionalGroupsSequence);
for f = 1:numel(fs)
	FrameAcquisitionDatetime{f} = q.PerFrameFunctionalGroupsSequence.(fs{f}).FrameContentSequence.Item_1.FrameAcquisitionDatetime;
	DimensionIndexValues(:,f) = q.PerFrameFunctionalGroupsSequence.(fs{f}).FrameContentSequence.Item_1.DimensionIndexValues;

	dt(f) = datetime(FrameAcquisitionDatetime{f},'InputFormat','yyyyMMddHHmmss.SS');

end

%% Mean of each vol time
clear dif
for d = 1:max(DimensionIndexValues(3,:))-1
	k1 = find(DimensionIndexValues(3,:)==d);
	k2 = find(DimensionIndexValues(3,:)==d+1);
	dif(d) = milliseconds(dt(k2(1)) - dt(k1(1)));
end


%% Total time from beginning of first vol to beginning of last
clear dif
k1 = find(DimensionIndexValues(3,:)==min(DimensionIndexValues(3,:)));
k2 = find(DimensionIndexValues(3,:)==max(DimensionIndexValues(3,:)));
dif = milliseconds(dt(k2(1)) - dt(k1(1))) / ...
	(max(DimensionIndexValues(3,:)) - min(DimensionIndexValues(3,:)))

