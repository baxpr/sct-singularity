#!/opt/sct/python/envs/venv_sct/bin/python
#
# Apply Haacke "mask" to mffe in swi geometry

import nibabel
import numpy

mffe_img = nibabel.load('swi_mffe.nii.gz')
mffe_data = mffe_img.get_fdata()

maskph_img = nibabel.load('swi_maskph.nii.gz')
maskph_data = maskph_img.get_fdata()

filtmffe_data = numpy.multiply(mffe_data,maskph_data)
filtmffe_img = nibabel.Nifti1Image(filtmffe_data,mffe_img.affine)
filtmffe_img.to_filename('swi_filtmffe.nii.gz')


