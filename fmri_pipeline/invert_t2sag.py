#!/opt/sct/python/envs/venv_sct/bin/python
#
# Invert a T2W image to make an approximate T1W image for better performance
# from sct_label_vertebrae

import sys
import nibabel
import numpy

t2_niigz = sys.argv[1]
t1_niigz = sys.argv[2]

t2_img = nibabel.load(t2_niigz)
img_data = t2_img.get_fdata()

img_max = numpy.amax(img_data)
img_data = img_max + 1 - img_data

t1_img = nibabel.Nifti1Image(img_data,t2_img.affine,t2_img.header)
nibabel.save(t1_img,t1_niigz)
