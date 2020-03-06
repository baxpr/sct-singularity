#!/bin/bash
#
# Get CSF ROI

# Transform template CSF to mffe space
sct_apply_transfo -i ${TDIR}/PAM50_csf.nii.gz -x nn \
-w warp_PAM502mffe.nii.gz \
-d mffe_mffe.nii.gz -o mffe_template_csf.nii.gz


# Two methods to get subject CSF
if [ "${CSF_METHOD}" = "template" ] ; then

  # Just copy the template csf to the subject name
  cp mffe_template_csf.nii.gz mffe_csf.nii.gz

elif [ "${CSF_METHOD}" = "propseg" ] ; then

  # Use propseg to get subject csf, removing any voxels that were labeled as cord
  sct_propseg -i mffe_mffe.nii.gz -c t2 -CSF
  sct_maths -i mffe_cord.nii.gz -mul -1 -o tmp.nii.gz
  sct_maths -i tmp.nii.gz -add 1 -o tmp.nii.gz
  sct_maths -i tmp.nii.gz -mul mffe_mffe_CSF_seg.nii.gz -o mffe_csf.nii.gz
    
else

  echo "Unknown CSF method ${CSF_METHOD}"
  exit 1

fi
