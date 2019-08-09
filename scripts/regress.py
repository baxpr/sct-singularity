#!/opt/sct/python/envs/venv_sct/bin/python
#
# Generate confound regressors and remove, slice by slice

import pandas
import nibabel

ricor_file = 'ricor.slibase.1D'
fmri_file = 'fmri_moco.nii.gz'
csf_file = 'fmri_moco_CSF.nii.gz'
notspine_file = 'fmri_moco_NOTSPINE.nii.gz'

# Cardiac/respiratory. We apply the same ones to all slices, assuming
# 3D fmri acquisition sequence. ricor_file is the appropriate output
# from RetroTS.py
ricor_reg = pandas.read_csv(ricor_file,delim_whitespace=True,skiprows=5,header=None)

# CSF and NOTSPINE masks in fmri space
csf_img = nibabel.load(csf_file)
notspine_img = nibabel.load(notspine_file)

# fmri time series data
fmri_img = nibabel.load(fmri_file)

# Verify that all images have the same geometry
# Skipping this for now because CSF is just a tiny bit off:
#     CSF/WM/GM/LABEL all match
#     moco, moco_mean, moco_mean_seg, NOT_SPINE all match
#     That means sct_apply_transfo behaves slightly different from sct_maths
#     https://github.com/neuropoly/spinalcordtoolbox/issues/2398
#print(csf_img.affine)
#print(notspine_img.affine)
#print(fmri_img.affine)
#if not ( (csf_img.affine==notspine_img.affine).all() and
#         (csf_img.affine==fmri_img.affine).all() ):
#    raise Exception('affine mismatch in image files')


