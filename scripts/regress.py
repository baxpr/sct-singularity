#!/opt/sct/python/envs/venv_sct/bin/python
#
# Generate confound regressors and remove, slice by slice

import nibabel
import numpy

ricor_file = 'ricor.slibase.1D'
fmri_file = 'fmri_moco.nii.gz'
csf_file = 'fmri_moco_CSF.nii.gz'
notspine_file = 'fmri_moco_NOTSPINE.nii.gz'

# Cardiac/respiratory. We apply the same ones to all slices, assuming
# 3D fmri acquisition sequence. ricor_file is the appropriate output
# from RetroTS.py
#ricor_reg = pandas.read_csv(ricor_file,delim_whitespace=True,skiprows=5,skipfooter=1,header=None)
ricor_data = numpy.genfromtxt(ricor_file,skip_header=5,skip_footer=0)
ricor_data -= numpy.mean(ricor_data,0)
ricor_data /= numpy.std(ricor_data,0)

# fmri time series data
fmri_img = nibabel.load(fmri_file)
nvols = fmri_img.header.get_data_shape()[3]

# CSF and NOTSPINE mask images in fmri space
csf_img = nibabel.load(csf_file)
notspine_img = nibabel.load(notspine_file)

# Verify that all images have the same geometry
#if not ( (csf_img.affine==notspine_img.affine).all() and
#         (csf_img.affine==fmri_img.affine).all() ):
#    raise Exception('affine mismatch in image files')

# Check that slice axis is third and get number of slices
dims = csf_img.header.get_data_shape()
#if not (dims[2]<dims[0] and dims[2]<dims[1]):
#    raise Exception('Third dimension is not slice dimension?')
nslices = dims[2]

# Get fmri data and reshape to inslice x thruslice x time. Reslice
# appears to copy
fmri_data = fmri_img.get_data();
rfmri_data = numpy.reshape(fmri_data,(dims[0]*dims[1],nslices,nvols),order='F')

# Binarize and reshape CSF and NOTSPINE masks
csf_mask = numpy.greater(csf_img.get_data(),0)
rcsf_mask = numpy.reshape(csf_mask,(dims[0]*dims[1],nslices),order='F')
ns_mask = numpy.greater(notspine_img.get_data(),0)
rns_mask = numpy.reshape(ns_mask,(dims[0]*dims[1],nslices),order='F')


s = 0

# This slice fmri data
sfmri_data = rfmri_data[:,s,:].T

# Noise data, time x voxel
csf_data = numpy.copy(rfmri_data[rcsf_mask[:,s],s,:]).T
ns_data = numpy.copy(rfmri_data[rns_mask[:,s],s,:]).T

# Normalize - subtract time mean, time sd = 1. Drop constant-valued voxels
csf_data -= numpy.mean(csf_data,0)
csf_data /= numpy.std(csf_data,0)
csf_data = csf_data[:,numpy.logical_not(numpy.isnan(numpy.std(csf_data,0)))]
ns_data -= numpy.mean(ns_data,0)
ns_data /= numpy.std(ns_data,0)
ns_data = ns_data[:,numpy.logical_not(numpy.isnan(numpy.std(ns_data,0)))]

# Get largest eigenvalue components and pct variance explained
csf_PCs,csf_S,V = numpy.linalg.svd(csf_data, full_matrices=False)
csf_var = numpy.square(csf_S)
csf_var = csf_var / sum(csf_var)
ns_PCs,ns_S,V = numpy.linalg.svd(ns_data, full_matrices=False)
ns_var = numpy.square(ns_S)
ns_var = ns_var / sum(ns_var)

numPCs = 5
numpy.savetxt('ricor.txt',ricor_data)
numpy.savetxt('csf.txt',csf_PCs[:,0:numPCs])
numpy.savetxt('ns.txt',ns_PCs[:,0:numPCs])

# Combine and rescale the desired confound regressors
confounds = numpy.hstack((ricor_data,csf_PCs[:,0:numPCs],ns_PCs[:,0:numPCs]))
confounds -= numpy.mean(confounds,0)
confounds /= numpy.std(confounds,0)
confounds = numpy.hstack((confounds,numpy.ones((nvols,1))))
numpy.savetxt('confounds.csv',confounds,delimiter=',')

# Remove confounds from this slice
print(confounds.shape)
print(sfmri_data.shape)
beta,resid,rank,svals = numpy.linalg.lstsq(confounds,sfmri_data)



import matplotlib.pyplot
matplotlib.pyplot.plot(csf_PCs[:,0:5])
matplotlib.pyplot.show()
