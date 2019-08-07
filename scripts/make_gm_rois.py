#!/opt/sct/python/envs/venv_sct/bin/python
#
# Load fmri space masks and create dorsal and ventral ROIs

import nibabel
import numpy
import scipy.ndimage

gm_file = 'fmri_moco_GM.nii.gz'
label_file = 'fmri_moco_LABEL.nii.gz'

# Load images
gm = nibabel.load(gm_file)
label = nibabel.load(label_file)

# Verify that geometry matches
if not (label.get_qform() == gm.get_qform()).all():
    raise Exception('GM/LABEL mismatch in qform')
if not (label.get_sform() == gm.get_sform()).all():
    raise Exception('GM/LABEL mismatch in sform')
if not (label.affine == gm.affine).all():
    raise Exception('GM/LABEL mismatch in affine')
if not label.header.get_data_shape() == gm.header.get_data_shape():
    raise Exception('GM/LABEL mismatch in data shape')    

# Split GM into horns, slice by slice at center of mass
gm_data = gm.get_data()
dims = gm.header.get_data_shape()
if not (dims[2]<dims[0] and dims[2]<dims[1]):
    raise Exception('Third dimension is not slice dimension?')
nslices = dims[2]
horn_data = numpy.zeros(dims)
for s in range(nslices):
    slicedata = numpy.copy(gm_data[:,:,s])
    com = [int(round(x)) for x in scipy.ndimage.center_of_mass(slicedata)]
    slicedata[com[0]:com[0]+1,:] = 0
    slicedata[:,com[1]:com[1]+1] = 0
    horn_data[:,:,s] = slicedata

horn = nibabel.Nifti1Image(horn_data,gm.affine,gm.header)
nibabel.save(horn,'fmri_moco_GMcut.nii.gz')

# Mask labels by gray matter and write to file
label_data = label.get_data()
gm_inds = gm_data>0
gm_data[gm_inds] = label_data[gm_inds]
gmmasked = nibabel.Nifti1Image(gm_data,gm.affine,gm.header)
nibabel.save(gmmasked,'fmri_moco_GMlabeled.nii.gz')
