#!/opt/sct/python/envs/venv_sct/bin/python
#
# Generate confound regressors and remove, slice by slice

import pandas
import nibabel
import numpy

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
nvols = fmri_img.header.get_data_shape()[3]

# Verify that all images have the same geometry
# Using allclose for now because CSF is just a tiny bit off:
#     CSF/WM/GM/LABEL all match
#     moco, moco_mean, moco_mean_seg, NOT_SPINE all match
#     That means sct_apply_transfo behaves slightly different from sct_maths
#     https://github.com/neuropoly/spinalcordtoolbox/issues/2398
#if not ( (csf_img.affine==notspine_img.affine).all() and
#         (csf_img.affine==fmri_img.affine).all() ):
#    raise Exception('affine mismatch in image files')
if not ( numpy.allclose(csf_img.affine,notspine_img.affine,1e-3) and
         numpy.allclose(csf_img.affine,fmri_img.affine,1e-3) )
    raise Exception('affine mismatch in image files')

# Check that slice axis is third and get number of slices
dims = csf_img.header.get_data_shape()
if not (dims[2]<dims[0] and dims[2]<dims[1]):
    raise Exception('Third dimension is not slice dimension?')
nslices = dims[2]

# Combine CSF and NOTSPINE masks
noise_mask = numpy.greater(csf_img.get_data(),0) | numpy.greater(notspine_img.get_data(),0)
rnoise_mask = numpy.reshape(noise_mask,(dims[0]*dims[1],nslices),order='F')

# Get fmri data and reshape to inslice x thruslice x time
fmri_data = fmri_img.get_data();
rfmri_data = numpy.reshape(fmri_data,(dims[0]*dims[1],nslices,nvols),order='F')

s = 0
noisedata = numpy.copy(rfmri_data[rnoise_mask[:,s],s,:])

