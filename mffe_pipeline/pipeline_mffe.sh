#!/bin/bash

# Segment cord and gray matter on mffe
sct_deepseg_sc -i mffe_mffe.nii.gz -c t2
mv mffe_mffe_seg.nii.gz mffe_cord.nii.gz

sct_deepseg_gm -i mffe_mffe.nii.gz
mv mffe_mffe_gmseg.nii.gz mffe_gm.nii.gz

# Create white matter roi as the difference
sct_maths -i mffe_cord.nii.gz -sub mffe_gm.nii.gz -o tmp.nii.gz
sct_maths -i tmp.nii.gz -thr 0 -o mffe_wm.nii.gz
rm tmp.nii.gz

# Create synthetic T2 for registration to template
sct_maths -i mffe_gm.nii.gz -add mffe_cord.nii.gz -o mffe_synt2.nii.gz

# Create mask for t2sag/mffe registration
sct_create_mask -i mffe_mffe.nii.gz -p centerline,mffe_cord.nii.gz -size ${MASKSIZE}mm \
	-o mffe_mask${MASKSIZE}.nii.gz

# Pad and resample mffe to iso voxel for better label placement. Padding includes
# enough room to fully capture the levels at top and bottom that probably extend
# past the mffe FOV but are captured in the t2sag
sct_image -i mffe_mffe.nii.gz -pad 0,0,5 -o pmffe_mffe.nii.gz
voxdim=$(get_ijk.py m mffe_mffe.nii.gz)
sct_resample -i pmffe_mffe.nii.gz -mm ${voxdim} -x nn -o ipmffe_mffe.nii.gz

# Bring along other images to ipmffe geometry
sct_resample -i mffe_cord.nii.gz -ref ipmffe_mffe.nii.gz -x nn -o ipmffe_cord.nii.gz
sct_resample -i mffe_synt2.nii.gz -ref ipmffe_mffe.nii.gz -x nn -o ipmffe_synt2.nii.gz
sct_resample -i mffe_gm.nii.gz -ref ipmffe_mffe.nii.gz -x nn -o ipmffe_gm.nii.gz
sct_resample -i mffe_wm.nii.gz -ref ipmffe_mffe.nii.gz -x nn -o ipmffe_wm.nii.gz
