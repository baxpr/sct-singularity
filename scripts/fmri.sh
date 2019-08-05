#!/bin/bash
#
# Process fMRI:
#    Motion correction
#    Registration to mFFE
#    Warp to atlas space
#    ROI time series extraction

cd ../OUTPUTS
cp ../INPUTS/fmri.nii.gz .
cp ../INPUTS/mffe_e1.nii.gz .

# Which images will we work on?
MFFE=mffe_e1
FMRI=fmri

# How big of a mask to use for registrations?
MSIZE=30

# Extract first fmri volume, find centerline, make mask
sct_image -keep-vol 0 -i ${FMRI}.nii.gz -o ${FMRI}_0.nii.gz
sct_get_centerline -c t2s -i ${FMRI}_0.nii.gz
sct_create_mask -i ${FMRI}_0.nii.gz -p centerline,${FMRI}_0_centerline.nii.gz -size ${MSIZE}mm \
-o ${FMRI}_mask${MSIZE}.nii.gz

# fMRI motion correction
sct_fmri_moco -m ${FMRI}_mask${MSIZE}.nii.gz -i ${FMRI}.nii.gz 

# Find cord on mean fMRI to improve registration
sct_deepseg_sc -i ${FMRI}_moco_mean.nii.gz -c t2s

# Find cord on mffe
sct_deepseg_sc -i ${MFFE}.nii.gz -c t2

# Create mask for registration
sct_create_mask -i ${MFFE}.nii.gz -p centerline,${MFFE}_seg.nii.gz -size ${MSIZE}mm \
-o ${MFFE}_mask${MSIZE}.nii.gz

# Register mean fMRI to mFFE
sct_register_multimodal \
-i ${FMRI}_moco_mean.nii.gz -iseg ${FMRI}_moco_mean_seg.nii.gz \
-d ${MFFE}.nii.gz -dseg ${MFFE}_seg.nii.gz \
-m ${MFFE}_mask${MSIZE}.nii.gz \
-param step=1,type=seg,algo=centermass,metric=MeanSquares,smooth=2:\
step=2,type=im,algo=slicereg,metric=MI


# RETROICOR
# First split physlog into card and resp, and trim to match length of scan.
# python is /opt/sct/python/envs/venv_sct/bin/python
# Get scan length with nibabel (sct python has it) and fmri_moco.nii.gz?
#    img.header.dim[4] and img.header.pixdim[4]
#    pixdim[4] for 3D fmri is per shot not per volume
3dretroicor -prefix pfx -card crd -resp resp -order 2 -cardphase cphase -respphase rphase ${FMRI}_moco.nii.gz

# Next:
#
# gwreg.sh to get mffe aligned to template
# resample template CSF to mffe, then moco space
#
# Slicewise on fMRI in moco space:
#   Use retroicor to get slicewise regressors
#   Use PCA to get CSF regressors
#   Use ?? and PCA to get ex-spine regressors

# We could handle the GM/WM/CSF volume fractions better if we resample
# the fmri to mffe space. However, then we lose the slicewise information
# that we need for slicewise correction. Any tricks to get accurate fractional
# volumes or otherwise handle partial volume effects? Main concerns are
# (1) Don't contaminate extracted CSF signals with GM/WM
# (2) Get most accurate GM ROIs for ROI analysis

# To compute approximate volume fraction: resample fMRI to mffe space,
# nearest neighbor, with the voxel values being a voxel index. In
# mffe space, count the GM/WM/CSF voxels at each voxel index and generate
# corresponding maps in the original fmri space.


