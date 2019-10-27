#!/bin/bash
#
# Inputs
#   mffe_mffe.nii.gz     MFFE first echo
#
# Outputs in original mffe space
#   mffe_cord.nii.gz     Spinal cord mask ("seg")
#   mffe_gm.nii.gz       Gray matter mask
#   mffe_wm.nii.gz       White matter mask
#   mffe_synt2.nii.gz    Synthetic T2 (white=1, gray=2)
#   mffe_mask??.nii.gz   Generous mask for registration
#
# Outputs in imffe space (resampled to approx. isotropic voxel assuming axial)
#   imffe_mffe.nii.gz
#   imffe_cord.nii.gz
#   imffe_synt2.nii.gz

# Outputs in padded (pimffe) space for correct handling of body markers
#   pimffe_mffe.nii.gz

# Segment GM and WM on mffe
sct_deepseg_sc -i mffe_mffe.nii.gz -c t2
mv mffe_mffe_seg.nii.gz mffe_cord.nii.gz
sct_deepseg_gm -i mffe_mffe.nii.gz
mv mffe_mffe_gmseg.nii.gz mffe_gm.nii.gz
sct_maths -i mffe_cord.nii.gz -sub mffe_gm.nii.gz -o tmp.nii.gz
sct_maths -i tmp.nii.gz -thr 0 -o mffe_wm.nii.gz
rm tmp.nii.gz
sct_maths -i mffe_gm.nii.gz -add mffe_cord.nii.gz -o mffe_synt2.nii.gz

# Create mask for t2sag/mffe registration
sct_create_mask -i mffe_mffe.nii.gz -p centerline,mffe_cord.nii.gz -size ${MASKSIZE}mm \
	-o mffe_mask${MASKSIZE}.nii.gz

# Resample mffe to iso voxel for better label placement
FAC=$(get_ijk.py f mffe_mffe.nii.gz)
sct_resample -i mffe_mffe.nii.gz -f 1x1x${FAC} -x nn -o imffe_mffe.nii.gz
sct_resample -i mffe_cord.nii.gz -ref imffe_mffe.nii.gz -x nn -o imffe_cord.nii.gz
sct_resample -i mffe_synt2.nii.gz -ref imffe_mffe.nii.gz -x nn -o imffe_synt2.nii.gz

# Make a padded imffe to put body markers in
sct_image -i imffe_mffe.nii.gz -pad 0,0,40 -o pimffe_mffe.nii.gz

