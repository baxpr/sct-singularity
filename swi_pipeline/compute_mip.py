#!/opt/sct/python/envs/venv_sct/bin/python
#
# Minimum intensity projection of SWI images in template space

import nibabel
import numpy


swi_img = nibabel.load('PAM50_filtswi.nii.gz')
swi_data = swi_img.get_fdata()
swi_data[swi_data==0] = numpy.NaN

mip_data = numpy.zeros(swi_data.shape)

for halfwidth in (2,4):
    for s in range(swi_data.shape[2]):
        chunk = swi_data[:,:,max(s-halfwidth,0):min(s+halfwidth,swi_data.shape[2])]
        mip_data[:,:,s] = numpy.nanmin(chunk,2)
    mip_img = nibabel.Nifti1Image(mip_data,swi_img.affine)
    mip_img.to_filename('PAM50_mip%d_filtswi.nii.gz' % (halfwidth*2+1))

