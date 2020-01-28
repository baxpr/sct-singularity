#!/bin/bash

# Crop template to relevant levels. sct_register_multimodal is not smart enough to 
# handle non-identical label sets.
sct_label_utils -i ${TDIR}/PAM50_label_body.nii.gz \
  -remove-reference ipmffe_cord_labeled_body.nii.gz \
  -o PAM50_template_cord_labeled_body.nii.gz

# Create synthetic T2 from template
sct_maths -i ${TDIR}/PAM50_gm.nii.gz -add ${TDIR}/PAM50_cord.nii.gz -o PAM50_template_synt2.nii.gz

# Register mffe to template via synthetic T2
sct_register_multimodal \
-i mffe_synt2.nii.gz -iseg mffe_cord.nii.gz \
-ilabel ipmffe_cord_labeled_body.nii.gz \
-d PAM50_template_synt2.nii.gz -dseg ${TDIR}/PAM50_cord.nii.gz \
-dlabel PAM50_template_cord_labeled_body.nii.gz \
-o PAM50_synt2.nii.gz \
-param step=0,type=label,dof=Tx_Ty_Tz_Sz:\
step=1,type=seg,algo=slicereg,poly=5:\
step=2,type=im,algo=syn

mv warp_mffe_synt22PAM50_template_synt2.nii.gz warp_mffe2PAM50.nii.gz
mv warp_PAM50_template_synt22mffe_synt2.nii.gz warp_PAM502mffe.nii.gz 
mv PAM50_synt2_inv.nii.gz mffe_PAM50_template_synt2.nii.gz

# Warp level labels to template
sct_apply_transfo -i t2sag_cord_labeled.nii.gz -d PAM50_synt2.nii.gz \
  -w warp_t2sag2mffe.nii.gz warp_mffe2PAM50.nii.gz \
  -x nn -o PAM50_cord_labeled.nii.gz
