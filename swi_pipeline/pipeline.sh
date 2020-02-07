#!/bin/bash
#
# SWI pipeline

# Phase-filtering for SWI
filter_swi.py \
--mag_niigz swi_swimag.nii.gz \
--ph_niigz swi_swiph.nii.gz \
--swi_output_niigz swi_filtswi.nii.gz \
--ph_scale ${PH_SCALE} \
--window_alpha ${WINDOW_ALPHA} \
--haacke_factor ${HAACKE_FACTOR}

# Find cord on SWI mag to improve registration
sct_deepseg_sc -i swi_swimag.nii.gz -c t2s
mv swi_swimag_seg.nii.gz swi_cord.nii.gz

# Create registration mask
sct_create_mask -i mffe_mffe.nii.gz -p centerline,mffe_cord.nii.gz -size ${MASKSIZE}mm \
-o mffe_mask${MASKSIZE}.nii.gz

# Register SWI mag image to mFFE
sct_register_multimodal \
-i swi_swimag.nii.gz -iseg swi_cord.nii.gz \
-d mffe_mffe.nii.gz -dseg mffe_cord.nii.gz \
-m mffe_mask${MASKSIZE}.nii.gz \
-param "${SWI_REG_PARAM}"

mv warp_swi_swimag2mffe_mffe.nii.gz warp_swi2mffe.nii.gz
mv warp_mffe_mffe2swi_swimag.nii.gz warp_mffe2swi.nii.gz
mv swi_swimag_reg.nii.gz mffe_swimag.nii.gz
mv mffe_mffe_reg.nii.gz swi_mffe.nii.gz

# Apply warp to get filtswi in mffe space
sct_apply_transfo -i swi_filtswi.nii.gz \
-w warp_swi2mffe.nii.gz \
-d mffe_mffe.nii.gz -o mffe_filtswi.nii.gz

# Apply warp to get SWI in template space
sct_apply_transfo -i swi_filtswi.nii.gz \
-w warp_swi2mffe.nii.gz warp_mffe2PAM50.nii.gz \
-d PAM50_mffe.nii.gz  -o PAM50_filtswi.nii.gz


