#!/bin/bash
#
# SWI pipeline

# Phase-filtering for SWI
filter_swi.py \
--mag_niigz swi_swimag.nii.gz \
--ph_niigz swi_swiph.nii.gz \
--output_pfx swi \
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


# Apply warp to get outputs in mffe and template space
for tag in filtswi maskph invmaskph ; do
  sct_apply_transfo -x linear -i swi_${tag}.nii.gz \
    -w warp_swi2mffe.nii.gz \
    -d mffe_mffe.nii.gz -o mffe_${tag}.nii.gz
  sct_apply_transfo -x linear -i swi_${tag}.nii.gz \
    -w warp_swi2mffe.nii.gz warp_mffe2PAM50.nii.gz \
    -d PAM50_mffe.nii.gz -o PAM50_${tag}.nii.gz
done

# Apply warp to get swi mag in template space
sct_apply_transfo -x linear -i swi_swimag.nii.gz \
-w warp_swi2mffe.nii.gz warp_mffe2PAM50.nii.gz \
-d PAM50_mffe.nii.gz  -o PAM50_swimag.nii.gz


# Compute minimum intensity projections, 6mm and 12mm ish, or 12-24 vox in PAM50 geom
compute_mip.py


# Warp mips to mffe and swi space
for tag in filtswi maskph invmaskph ; do
  sct_apply_transfo -x linear -i PAM50_mip11_${tag}.nii.gz \
    -w warp_PAM502mffe.nii.gz \
    -d mffe_mffe.nii.gz -o mffe_mip11_${tag}.nii.gz
  sct_apply_transfo -x linear -i PAM50_mip21_${tag}.nii.gz \
    -w warp_PAM502mffe.nii.gz \
    -d mffe_mffe.nii.gz -o mffe_mip21_${tag}.nii.gz
  sct_apply_transfo -x linear -i PAM50_mip11_${tag}.nii.gz \
    -w warp_PAM502mffe.nii.gz warp_mffe2swi.nii.gz \
    -d swi_mffe.nii.gz -o swi_mip11_${tag}.nii.gz
  sct_apply_transfo -x linear -i PAM50_mip21_${tag}.nii.gz \
    -w warp_PAM502mffe.nii.gz warp_mffe2swi.nii.gz \
    -d swi_mffe.nii.gz -o swi_mip21_${tag}.nii.gz
done


# Make PDF
# Redirect stdout/err for make_pdf.sh to hide a bunch of nibabel deprecation
# warnings caused by fsleyes 0.32.0.
make_pdf.sh &> /dev/null
convert_pdf.sh


# Organize outputs
organize_outputs.sh
