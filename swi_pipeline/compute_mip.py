#!/opt/sct/python/envs/venv_sct/bin/python
#
# Minimum intensity projection of SWI images in template space

import nibabel
import numpy

for tag in ['filtswi','maskph','invmaskph','filtmffe']:

    img = nibabel.load('PAM50_' + tag + '.nii.gz')
    data = img.get_fdata()
    data[data==0] = numpy.NaN

    mip_data = numpy.zeros(data.shape)

    for halfwidth in (5,10):
        for s in range(data.shape[2]):
            chunk = data[:,:,max(s-halfwidth,0):min(s+halfwidth,data.shape[2])]
            mip_data[:,:,s] = numpy.nanmin(chunk,2)
        mip_img = nibabel.Nifti1Image(mip_data,img.affine)
        mip_img.to_filename('PAM50_mip%d_%s.nii.gz' % (halfwidth*2+1,tag))

