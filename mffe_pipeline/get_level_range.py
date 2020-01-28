#!/opt/sct/python/envs/venv_sct/bin/python
# 
# Get range of vert levels from a nifti image

import sys
import nibabel
import numpy

nii_file = sys.argv[1]
nii_img = nibabel.load(nii_file)
nii_data = nii_img.get_fdata()
uvals = numpy.unique(nii_data)
uvals = uvals[uvals!=0]
ruvals = numpy.round(uvals)
if not numpy.all(ruvals==uvals):
    raise Exception("Non-integer value found in ROI image " + nii_file)

outstr = "%d:%d" % (min(ruvals),max(ruvals))

print(outstr)
