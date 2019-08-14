#!/opt/sct/python/envs/venv_sct/bin/python
#
# Functional connectivity maps

import numpy
import nibabel
from nilearn.input_data import NiftiMasker,NiftiLabelsMasker
from nilearn.signal import high_variance_confounds

ricor_file = 'ricor.csv'
csf_file = 'fmri_moco_CSF.nii.gz'
ns_file = 'fmri_moco_NOTSPINE.nii.gz'
mocoX_file = 'fmri_moco_params_X.nii.gz'
mocoY_file = 'fmri_moco_params_Y.nii.gz'

fmri_file = 'ffmri_moco.nii.gz'
seed_file = 'fmri_moco_GMcutlabel.nii.gz'
vat_file = 'vat.txt'

# Get moco params and reshape/combine to time x param x slice
mocoX_data = nibabel.load(mocoX_file).get_data()
mocoY_data = nibabel.load(mocoY_file).get_data()
print('mocoX size %d,%d,%d,%d' % mocoX_data.shape)
mocoX_data = numpy.transpose(mocoX_data,(3,0,2,1))
mocoY_data = numpy.transpose(mocoY_data,(3,0,2,1))
print('mocoX new size %d,%d,%d,%d' % mocoX_data.shape)
moco_data = numpy.squeeze( numpy.concatenate((mocoX_data,mocoY_data),1) )
print('moco size %d,%d,%d' % moco_data.shape)

# Make a slice-label ROI file from the seed file so we can easily do slice-wise masking
slicelabel_file = 'slicelabel.nii.gz'
img = nibabel.load(seed_file)
slice_data = numpy.zeros(img.get_data().shape)
for s in range(slice_data.shape[2]):
    slice_data[:,:,s] = s+1
slice_img = nibabel.Nifti1Image(slice_data,img.affine,img.header)
nibabel.save(slice_img,slicelabel_file)


# FIXME
# Update ricor .py to provide a nice csv instead of blargy text format

# Get TR (volume acquisition time, NOT actual scan TR for 3D fmris)
with open(vat_file,'r') as f:
    t_r = float(f.read())
    print('Found vol time of %f sec' % t_r)

# Get cardiac/respiratory time series from RetroTS
ricor_data = numpy.genfromtxt(ricor_file,delimiter=',')
print('Found phys data size %d,%d' % ricor_data.shape)

# CSF and not-spine signals (entire 3D FOV)
csf_masker = NiftiMasker(csf_file,detrend=True)
csf_data = csf_masker.fit_transform(fmri_file)
csf_confounds_data = high_variance_confounds(csf_data,percentile=50)
print('CSF data size %d,%d' % csf_confounds_data.shape)

ns_masker = NiftiMasker(ns_file,detrend=True)
ns_data = csf_masker.fit_transform(fmri_file)
ns_confounds_data = high_variance_confounds(ns_data,percentile=50)
print('NOTSPINE data size %d,%d' % ns_confounds_data.shape)

# Combine confound time series
confounds_data = numpy.hstack((ricor_data,csf_confounds_data,ns_confounds_data))
print('Confounds data size %d,%d' % confounds_data.shape)

# ROI seed time series, filtered
seed_masker = NiftiLabelsMasker(seed_file,standardize=True,detrend=True,
                high_pass=0.01,low_pass=0.10,t_r=t_r)
seed_data = seed_masker.fit_transform(fmri_file,confounds=confounds_data)
print('Seed data size %d,%d' % seed_data.shape)

