#!/opt/sct/python/envs/venv_sct/bin/python
# 
# Get unique values of a nifti image

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

outstr=""
for ruval in ruvals[0:-1]:
    outstr = outstr + "%d," % ruval
outstr = outstr + "%d" % ruvals[-1]

print(outstr)
