#!/opt/sct/python/envs/venv_sct/bin/python
#
# Apply bandpass filter to regression-cleaned fmri time series

import nibabel
import nilearn

# Inputs
moco_mean_file = 'fmri_moco_mean.nii.gz'
filt_file = 'fmri_filt.nii.gz'
vat_file = 'volume_acquisition_time.txt'

# Output
#filtbp_file = 'fmri_filtbp.nii.gz'  # For computation only, mean 0
regbp_file = 'fmri_regbp.nii.gz'    # To save, mean image added back

# Get TR (volume acquisition time, NOT actual scan TR for 3D fmris)
with open(vat_file,'r') as f:
    t_r = float(f.read().strip())
    print('Found vol time of %f sec' % t_r)

# Load the mean image
img_mean = nibabel.load(moco_mean_file)

# Created fully filtered data set (regress + bandpass), mean 0 SD 1
# Save to intermediate file for computation. Need to update data type.
#img_filtbp = nilearn.image.clean_img(filt_file,standardize=True,detrend=True,
#                                     high_pass=0.01,low_pass=0.10,t_r=t_r)
#img_filtbp.set_data_dtype('float32')
#img_filtbp.to_filename(filtbp_file)

# Create a non-standarized version without detrend for better viewing. Add back
# the mean after filtering
img_regbp = nilearn.image.clean_img(filt_file,standardize=False,detrend=False,
                                     high_pass=0.01,low_pass=0.10,t_r=t_r)
data_mean = img_mean.get_fdata()
data_regbp = img_regbp.get_fdata()
for v in range(data_regbp.shape[3]):
    data_regbp[:,:,:,v] = data_regbp[:,:,:,v] + data_mean

img_regbp.set_data_dtype('float32')
img_regbp.to_filename(regbp_file)

