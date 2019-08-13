#!/opt/sct/python/envs/venv_sct/bin/python
#
# On pre-processed data, compute functional connectivity

import nibabel
import numpy

fmri_file = 'ffmri_moco.nii.gz'
roi_file = 'fmri_moco_GMcutlabel.nii.gz'


# Load seed ROI image
roi_img = nibabel.load(roi_file)
roi_data = roi_img.get_data()


# Load preprocessed fmri
fmri_img = nibabel.load(fmri_file)
fmri_data = fmri_img.get_data()
dims = fmri_img.header.get_data_shape()

# Verify matching geometry
# Verify that all images have the same geometry
if not ( (roi_img.affine==fmri_img.affine).all() and
         (roi_img.header.get_data_shape()==dims[0:3]) ):
    raise Exception('Geometry mismatch in image files')

# Reshape to time x voxel
roi_data = numpy.squeeze(numpy.reshape(roi_data,(dims[0]*dims[1]*dims[2],1),order='F').T)
fmri_data = numpy.reshape(fmri_data,(dims[0]*dims[1]*dims[2],dims[3]),order='F').T
print(roi_data.shape)
print(fmri_data.shape)

# Get mean time series for each ROI
roi_vals = numpy.unique(roi_data)
roi_vals = roi_vals[numpy.nonzero(roi_vals)]
print('Found %d ROIs' % roi_vals.size)
for roi_val in enumerate(roi_vals):
    roi_ts = numpy.mean(fmri_data[:,roi_data==roi_val],1)
    r = numpy.corrcoef(roi_ts,fmri_data)
    print(r.shape)

# Compute correlation image, Z transform, and save to file
