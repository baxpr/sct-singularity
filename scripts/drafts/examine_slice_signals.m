% How different are the confounds signals from slice to slice? Do we need
% a 2D filtering or is a generic 3D ok?

csf = spm_read_vols(spm_vol('../OUTPUTS/fmri_moco_CSF.nii.gz'));
notspine = spm_read_vols(spm_vol('../OUTPUTS/fmri_moco_NOTSPINE.nii.gz'));
fmri = spm_read_vols(spm_vol('../OUTPUTS/fmri_moco.nii.gz'));

%% Whole fov NOTSPINE
[nx,ny,ns,nt] = size(fmri);
rfmri = reshape(fmri,[],nt)';
rnotspine = reshape(notspine,[],1)';
notspine_data = rfmri(:,rnotspine==1);
[~,notspine_pca] = pca(detrend(zscore(notspine_data)));

%% Slicewise NOTSPINE
clear notspine_pca_slice
for s = 1:ns
	rfmri = reshape(fmri(:,:,s,:),[],nt)';
	rnotspine = reshape(notspine(:,:,s),[],1)';
	notspine_data = rfmri(:,rnotspine==1);
	[~,p] = pca(detrend(zscore(notspine_data)));
	notspine_pca_slice(:,:,s) = p;
end

%%
imagesc(abs(corr(squeeze(notspine_pca_slice(:,1,:)))),[0 1])
colorbar

corr(notspine_pca(:,1),squeeze(notspine_pca_slice(:,1,:)));
corr(notspine_pca(:,1),squeeze(notspine_pca_slice(:,3,:)));

[~,~,R,~,~,stats] = canoncorr(notspine_pca(:,1:10),notspine_pca_slice(:,1:5,1))
