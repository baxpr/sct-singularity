#!/opt/sct/python/envs/venv_sct/bin/python
# 
# Get voxel dimensions of a nifti image

import sys
import nibabel

axis = sys.argv[1]
nii_file = sys.argv[2]
nii_img = nibabel.load(nii_file)

if axis is 'i':
    print('%d' % nii_img.header.get_data_shape()[0])

if axis is 'j':
    print('%d' % nii_img.header.get_data_shape()[1])

if axis is 'k':
    print('%d' % nii_img.header.get_data_shape()[2])

