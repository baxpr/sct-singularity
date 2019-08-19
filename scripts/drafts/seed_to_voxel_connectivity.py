#!/opt/sct/python/envs/venv_sct/bin/python
#
# Functional connectivity maps

import numpy
import nibabel
from nilearn.input_data import NiftiMasker,NiftiLabelsMasker
from nilearn.signal import high_variance_confounds
from nilearn.masking import intersect_masks,unmask

ricor_file = 'ricor.csv'
csf_file = 'fmri_moco_CSF.nii.gz'
ns_file = 'fmri_moco_NOTSPINE.nii.gz'
mocoX_file = 'fmri_moco_params_X.nii.gz'
mocoY_file = 'fmri_moco_params_Y.nii.gz'

fmri_file = 'fmri_moco.nii.gz'
seed_file = 'fmri_moco_GMcutlabel.nii.gz'
vat_file = 'vat.txt'

filtered_file = 'filtered_fmri.nii.gz'


# Get moco params and reshape/combine to time x param x slice
mocoX_data = nibabel.load(mocoX_file).get_data()
mocoY_data = nibabel.load(mocoY_file).get_data()
print('mocoX size %d,%d,%d,%d' % mocoX_data.shape)
mocoX_data = numpy.transpose(mocoX_data,(3,0,2,1))
mocoY_data = numpy.transpose(mocoY_data,(3,0,2,1))
print('mocoX new size %d,%d,%d,%d' % mocoX_data.shape)
moco_data = numpy.squeeze( numpy.concatenate((mocoX_data,mocoY_data),1) )
moco_derivs = numpy.diff(moco_data,n=1,axis=0,prepend=0)
moco_data = numpy.concatenate((moco_data,moco_derivs),1)
print('moco size %d,%d,%d' % moco_data.shape)

# Make slice-label ROI files from the seed file so we can easily do slice-wise masking
img = nibabel.load(seed_file)
nslices = img.shape[2]
slice_img = list()
for s in range(nslices):
    slice_data = numpy.zeros(img.get_data().shape)
    slice_data[:,:,s] = 1
    slice_img.append( nibabel.Nifti1Image(slice_data,img.affine,img.header) )
    #nibabel.save(slice_img[-1],'slicelabel_%02d.nii.gz' % s)

# Get TR (volume acquisition time, NOT actual scan TR for 3D fmris)
with open(vat_file,'r') as f:
    t_r = float(f.read())
    print('Found vol time of %f sec' % t_r)

# Get cardiac/respiratory time series from RetroTS
ricor_data = numpy.genfromtxt(ricor_file,delimiter=',')
print('Found phys data size %d,%d' % ricor_data.shape)

# Make our output/filtered image
fmri_img = nibabel.load(fmri_file)
filtered_data = numpy.zeros(fmri_img.get_data().shape)
filtered_img = nibabel.Nifti1Image(filtered_data,fmri_img.affine,fmri_img.header)


for s in range(nslices):

    # CSF and not-spine signals (single slice)
    csf_mask = intersect_masks((csf_file,slice_img[s]),threshold=1,connected=False)
    csf_masker = NiftiMasker(csf_mask,detrend=True)
    csf_data = csf_masker.fit_transform(fmri_file)
    print('CSF initial data size %d,%d' % csf_data.shape)
    csf_confounds_data = high_variance_confounds(csf_data,percentile=50)

    ns_mask = intersect_masks((ns_file,slice_img[s]),threshold=1,connected=False)
    ns_masker = NiftiMasker(ns_mask,detrend=True)
    ns_data = ns_masker.fit_transform(fmri_file)
    print('NOTSPINE initial data size %d,%d' % ns_data.shape)
    ns_confounds_data = high_variance_confounds(ns_data,percentile=50)

    # Combine and normalize slice-specific confound time series
    confounds_data = numpy.hstack((ricor_data,csf_confounds_data,
        ns_confounds_data,moco_data[:,:,s]))
    confounds_data -= numpy.mean(confounds_data,0)
    confounds_data /= numpy.std(confounds_data,0)
    print('Confounds data size %d,%d' % confounds_data.shape)

    # Get filtered fmri data for this slice
    slice_mask = NiftiMasker(slice_img[s],standardize=True,detrend=True,
                    high_pass=0.01,low_pass=0.10,t_r=t_r)
    filtered_slice_data = slice_mask.fit_transform(fmri_file,confounds=confounds_data)
    tmp_img = unmask(filtered_slice_data,slice_img[s])
    filtered_data[:,:,s,:] = tmp_img.get_data()[:,:,s,:]


# Save filtered data to file
filtered_img = nibabel.Nifti1Image(filtered_data,fmri_img.affine,fmri_img.header)
nibabel.save(filtered_img,filtered_file)


# ROI seed time series, filtered
seed_masker = NiftiLabelsMasker(seed_file,standardize=True,detrend=True,
                high_pass=0.01,low_pass=0.10,t_r=t_r)
seed_data = seed_masker.fit_transform(fmri_file,confounds=confounds_data)
print('Seed data size %d,%d' % seed_data.shape)

