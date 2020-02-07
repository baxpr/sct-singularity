#!/bin/bash

# Crop template to relevant levels. sct_register_multimodal is not smart enough to 
# handle non-identical label sets.
sct_label_utils -i ${TDIR}/PAM50_label_body.nii.gz \
  -remove-reference ipmffe_cord_labeled_body.nii.gz \
  -o PAM50_template_cord_labeled_body.nii.gz

# Create synthetic T2 from template
sct_maths -i ${TDIR}/PAM50_gm.nii.gz -add ${TDIR}/PAM50_cord.nii.gz -o PAM50_template_synt2.nii.gz

# Registering template to mffe, with mask
sct_register_multimodal -v 0 \
-d mffe_synt2.nii.gz -dseg mffe_cord.nii.gz \
-dlabel ipmffe_cord_labeled_body.nii.gz \
-i PAM50_template_synt2.nii.gz -iseg ${TDIR}/PAM50_cord.nii.gz \
-ilabel PAM50_template_cord_labeled_body.nii.gz \
-m mffe_mask${MASKSIZE}.nii.gz \
-o mffe_template_synt2.nii.gz \
-param "${TEMPLATE_REG_PARAM}"

mv warp_PAM50_template_synt22mffe_synt2.nii.gz warp_PAM502mffe.nii.gz
mv warp_mffe_synt22PAM50_template_synt2.nii.gz warp_mffe2PAM50.nii.gz 
mv mffe_template_synt2_inv.nii.gz PAM50_synt2.nii.gz

# Warp level labels to template
sct_apply_transfo -i t2sag_cord_labeled.nii.gz -d PAM50_synt2.nii.gz \
  -w warp_t2sag2mffe.nii.gz warp_mffe2PAM50.nii.gz \
  -x nn -o PAM50_cord_labeled.nii.gz
