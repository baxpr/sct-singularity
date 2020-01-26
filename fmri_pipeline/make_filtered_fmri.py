moco_mean_file = 'fmri_moco_mean.nii.gz'
filtbp_file = 'fmri_filtbp.nii.gz'


# Created fully filtered data set (regress + bandpass). Add back the mean
# so images make sense visually
img_filtbp = nilearn.image.clean_img(filt_file,standardize=False,detrend=False,
                                     high_pass=0.01,low_pass=0.10,t_r=t_r)
#img_filtbp.to_filename(filtbp_file)

# How do we make a new image with float datatype for this but correct affine?
img_mean = nibabel.load(moco_mean_file)
data_mean = img_mean.get_fdata()
data_filtbp = img_filtbp.get_fdata()
for v in range(data_filtbp.shape[3]):
    data_filtbp[:,:,:,v] = data_filtbp[:,:,:,v] + data_mean
outimg = nibabel.Nifti1Image(data_filtbp,img_filtbp.affine)
outimg.to_filename(filtbp_file)
