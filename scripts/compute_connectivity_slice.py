#!/opt/sct/python/envs/venv_sct/bin/python
#
# Functional connectivity maps

import numpy
import nibabel
import nilearn
from nilearn.input_data import NiftiMasker,NiftiLabelsMasker
from nilearn.masking import intersect_masks,unmask
from nilearn.regions import img_to_signals_labels

fmri_file = 'ffmri_moco.nii.gz'
gm_file = 'fmri_moco_GMcut.nii.gz'
vat_file = 'vat.txt'


# Get TR (volume acquisition time, NOT actual scan TR for 3D fmris)
with open(vat_file,'r') as f:
    t_r = float(f.read())
    print('Found vol time of %f sec' % t_r)


# Make slice-label ROIs from the GM file so we can easily do slice-wise masking
img = nibabel.load(gm_file)
nslices = img.shape[2]
slice_img = list()
for s in range(nslices):
    slice_data = numpy.zeros(img.get_data().shape)
    slice_data[:,:,s] = 1
    slice_img.append( nibabel.Nifti1Image(slice_data,img.affine,img.header) )


# Compute connectivity within each slice, applying bandpass filter
for s in range(nslices):

    # ROI signals
    roi_data,roi_labels = img_to_signals_labels(fmri_file,gm_file,slice_img[s])
    roi_data = nilearn.signal.clean(roi_data,standardize=True,detrend=True,
                                    high_pass=0.01,low_pass=0.10,t_r=t_r)
    print('ROI data size %d,%d' % roi_data.shape)

    # Get filtered fmri data for this slice
    slice_masker = NiftiMasker(slice_img[s],standardize=True,detrend=True,
                    high_pass=0.01,low_pass=0.10,t_r=t_r)
    slice_data = slice_masker.fit_transform(fmri_file)
    print('Slice data size %d,%d' % slice_data.shape)

    # Connectivity computation
    # Relies on standardization to mean 0, sd 1 above
    r_slice_data = numpy.dot(slice_data.T, roi_data) / roi_data.shape[0]
    print( 'R %d,%d ranges %f,%f' % (r_slice_data.shape[0],r_slice_data.shape[1],
                                     r_slice_data.min(),r_slice_data.max()) )
    r_slice_img = slice_masker.inverse_transform(r_slice_data.T)

    # Put R back into image space
    if s==0:
        r_img = r_slice_img  # Initialize
    else:
        r_img = nilearn.image.math_img("a+b",a=r_img,b=r_slice_img)

# Save complete R image to file
r_img.to_filename('connectivity_r.nii.gz')


#z_data = numpy.arctanh(r_data) * numpy.sqrt(roi_data.shape[0]-3)
