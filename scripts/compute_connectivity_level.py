#!/opt/sct/python/envs/venv_sct/bin/python
#
# On pre-processed data, compute functional connectivity. Use through-slice 3D ROIs

import nibabel
import numpy
from nilearn.input_data import NiftiMasker,NiftiLabelsMasker

fmri_file = 'ffmri_moco.nii.gz'
roi_file = 'fmri_moco_GMcutlabel.nii.gz'
vat_file = 'volume_acquisition_time.txt'
msize_file = 'masksize.txt'
with open(msize_file,'r') as f:
    msize = f.read()
mask_file = 'fmri_mask' + msize + '.nii.gz'

# Get TR (volume acquisition time, NOT actual scan TR for 3D fmris)
with open(vat_file,'r') as f:
    t_r = float(f.read())
    print('Found vol time of %f sec' % t_r)

# Seed ROI image
roi_img = nibabel.load(roi_file)

# Preprocessed fmri image
fmri_img = nibabel.load(fmri_file)
dims = fmri_img.header.get_data_shape()

# Verify that all images have the same geometry
if not ( (roi_img.affine==fmri_img.affine).all() and
         (roi_img.header.get_data_shape()==dims[0:3]) ):
    raise Exception('Geometry mismatch in image files')

# ROI seed time series, filtered
seed_masker = NiftiLabelsMasker(roi_file,standardize=True,detrend=True,
                high_pass=0.01,low_pass=0.10,t_r=t_r)
seed_data = seed_masker.fit_transform(fmri_file)
print('Seed data size %d,%d' % seed_data.shape)

# All time series
spine_masker = NiftiMasker(mask_file,standardize=True,detrend=True,
                high_pass=0.01,low_pass=0.10,t_r=t_r)
spine_data = spine_masker.fit_transform(fmri_file)
print('Spine data size %d,%d' % spine_data.shape)

# Connectivity computation
# Relies on standardization to mean 0, sd 1 above
r_data = numpy.dot(spine_data.T, seed_data) / seed_data.shape[0]
z_data = numpy.arctanh(r_data) * numpy.sqrt(seed_data.shape[0]-3)
print( 'R %d,%d ranges %f %f' % (r_data.shape[0],r_data.shape[1],r_data.min(),r_data.max()) )
print( 'Z ranges %f %f' % (z_data.min(),z_data.max()) )

# Save connectivity images
r_img = spine_masker.inverse_transform(r_data.T)
r_img.to_filename('connectivity_level_r.nii.gz')
z_img = spine_masker.inverse_transform(z_data.T)
z_img.to_filename('connectivity_level_z.nii.gz')

