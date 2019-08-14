#!/opt/sct/python/envs/venv_sct/bin/python
#
# Functional connectivity maps

import numpy
from nilearn.input_data import NiftiMasker,NiftiLabelsMasker
from nilearn.signal import high_variance_confounds

ricor_file = 'ricor.slibase.1D'
csf_file = 'fmri_moco_CSF.nii.gz'
notspine_file = 'fmri_moco_NOTSPINE.nii.gz'

fmri_file = 'ffmri_moco.nii.gz'
seed_file = 'fmri_moco_GMcutlabel.nii.gz'
vat_file = 'vat.txt'

# Get TR (volume acquisition time, NOT actual scan TR for 3D fmris)
with open(vat_file,'r') as f:
    t_r = float(f.read())
    print('Found vol time of %f sec' % t_r)

# Get cardiac/respiratory time series from RetroTS
ricor_data = numpy.genfromtxt(ricor_file,skip_header=5,skip_footer=0)
print('Found phys data size %d,%d' % ricor_data.shape)

# CSF and not-spine signals (whole brain)
csf_masker = NiftiMasker(csf_file)
csf_data = csf_masker.fit_transform(fmri_file)
csf_confound_data = high_variance_confounds(csf_data,percentile=50)
print('CSF data size %d,%d' % csf_confound_data.shape)

# ROI seed time series, filtered
seed_masker = NiftiLabelsMasker(seed_file,standardize=True,detrend=True,
                high_pass=0.01,low_pass=0.10,t_r=t_r)
seed_data = seed_masker.fit_transform(fmri_file,confounds=confounds_data)
print('Seed data size %d,%d' % seed_data.shape)

