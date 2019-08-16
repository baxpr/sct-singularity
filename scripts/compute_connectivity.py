#!/opt/sct/python/envs/venv_sct/bin/python
#
# On pre-processed data, compute functional connectivity

import nibabel
import numpy
from nilearn.input_data import NiftiMasker,NiftiLabelsMasker

fmri_file = 'ffmri_moco.nii.gz'
roi_file = 'fmri_moco_GMcutlabel.nii.gz'
vat_file = 'vat.txt'

# Get TR (volume acquisition time, NOT actual scan TR for 3D fmris)
with open(vat_file,'r') as f:
    t_r = float(f.read())
    print('Found vol time of %f sec' % t_r)

# Load seed ROI image
roi_img = nibabel.load(roi_file)
roi_data = roi_img.get_data()

# Load preprocessed fmri
fmri_img = nibabel.load(fmri_file)
fmri_data = fmri_img.get_data()
dims = fmri_img.header.get_data_shape()

# Verify matching geometry
# Verify that all images have the same geometry
if not ( (roi_img.affine==fmri_img.affine).all() and
         (roi_img.header.get_data_shape()==dims[0:3]) ):
    raise Exception('Geometry mismatch in image files')

# ROI seed time series, filtered
seed_masker = NiftiLabelsMasker(seed_file,standardize=True,detrend=True,
                high_pass=0.01,low_pass=0.10,t_r=t_r)
seed_data = seed_masker.fit_transform(fmri_file)
print('Seed data size %d,%d' % seed_data.shape)

