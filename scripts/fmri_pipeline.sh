#!/bin/bash
#
# Process fMRI:
#    Motion correction
#    Registration to mFFE
#    Warp to atlas space
#    ROI time series extraction

# Which images will we work on?
T2SAG=t2sag
MFFE=mffe1
FMRI=fmri

# Vertebral label for center slice of mffe
#INITCENTER=`cat initcenter.txt`

# How big of a mask to use for registrations?
#MSIZE=`cat masksize.txt`

# Location of template
TDIR=${SCTDIR}/data/PAM50/template


# Segment GM and WM on mffe
#    gmseg   :  gray matter
#    wmseg   :  white matter
#    seg     :  cord
#    gw      :  synthetic T2 (GM=2, WM=1)
do_seg () {
	sct_deepseg_sc -i "${1}".nii.gz -c t2
	sct_deepseg_gm -i "${1}".nii.gz
	sct_maths -i "${1}"_seg.nii.gz -sub "${1}"_gmseg.nii.gz -o tmp.nii.gz
	sct_maths -i tmp.nii.gz -thr 0 -o "${1}"_wmseg.nii.gz
	rm tmp.nii.gz
	sct_maths -i "${1}"_gmseg.nii.gz -add "${1}"_seg.nii.gz -o "${1}"_gw.nii.gz
}
do_seg ${MFFE}

# Create mask for t2sag/mffe registration
sct_create_mask -i ${MFFE}.nii.gz -p centerline,${MFFE}_seg.nii.gz -size ${MASKSIZE}mm \
	-o ${MFFE}_mask${MASKSIZE}.nii.gz

# Get cord seg for the T2 sag
sct_deepseg_sc -i ${T2SAG}.nii.gz -c t2

# Invert t2sag contrast so level-finding works better
invert_t2sag.py ${T2SAG}.nii.gz invt2sag.nii.gz

# Get vert labels on the inverted t2sag and list them
sct_label_vertebrae -i invt2sag.nii.gz -s ${T2SAG}_seg.nii.gz -c t1
sct_label_utils -i ${T2SAG}_seg_labeled_discs.nii.gz -display 

# Register t2sag to mffe
sct_register_multimodal -i ${T2SAG}.nii.gz -iseg ${T2SAG}_seg.nii.gz \
	-d ${MFFE}.nii.gz -dseg ${MFFE}_seg.nii.gz \
	-m ${MFFE}_mask${MASKSIZE}.nii.gz \
	-o ${T2SAG}_mffespace.nii.gz \
	-owarp warp_${T2SAG}2${MFFE}.nii.gz


# Resample mffe images to iso voxel for better label placement later
FAC=$(get_ijk.py f ${MFFE}.nii.gz)
sct_resample -i ${MFFE}.nii.gz -f 1x1x${FAC} -x linear -o i${MFFE}.nii.gz
sct_resample -i ${MFFE}_mask${MASKSIZE}.nii.gz -f 1x1x${FAC} -x nn -o i${MFFE}_mask${MASKSIZE}.nii.gz
sct_resample -i ${MFFE}_seg.nii.gz -f 1x1x${FAC} -x nn -o i${MFFE}_seg.nii.gz
sct_resample -i ${MFFE}_gmseg.nii.gz -f 1x1x${FAC} -x nn -o i${MFFE}_gmseg.nii.gz
sct_resample -i ${MFFE}_wmseg.nii.gz -f 1x1x${FAC} -x nn -o i${MFFE}_wmseg.nii.gz
sct_resample -i ${MFFE}_gw.nii.gz -f 1x1x${FAC} -x nn -o i${MFFE}_gw.nii.gz
sct_resample -i ${T2SAG}_mffespace.nii.gz -f 1x1x${FAC} -x nn -o ${T2SAG}_imffespace.nii.gz

# Make a padded imffe to put body markers in
sct_image -i i${MFFE}.nii.gz -pad 0,0,40 -o pi${MFFE}.nii.gz

# Resample level ROIs to pimffe space
sct_apply_transfo -i ${T2SAG}_seg_labeled.nii.gz -d pi${MFFE}.nii.gz \
    -w warp_${T2SAG}2${MFFE}.nii.gz -x nn \
	-o ${T2SAG}_seg_labeled_pimffespace.nii.gz

# Create body markers in pimffe space
sct_label_utils -i ${T2SAG}_seg_labeled_pimffespace.nii.gz -vert-body 0 \
	-o ${T2SAG}_seg_labeled_body_pimffespace.nii.gz

# Crop body markers and level image back to imffe space
sct_crop_image -i ${T2SAG}_seg_labeled_body_pimffespace.nii.gz \
	-ref i${MFFE}.nii.gz -o ${T2SAG}_seg_labeled_body_imffespace.nii.gz
sct_crop_image -i ${T2SAG}_seg_labeled_pimffespace.nii.gz \
	-ref i${MFFE}.nii.gz -o ${T2SAG}_seg_labeled_imffespace.nii.gz


# Can we use propseg to get a subject CSF? Not very accurate, invades GM
#sct_propseg -i ${MFFE}.nii.gz -c t2 -CSF


# Get vertebral labels for mffe - QUESTIONABLE
#sct_label_vertebrae -i ${MFFE}.nii.gz -s ${MFFE}_seg.nii.gz -c t2 -initcenter ${INITCENTER}

# NOTE - body labels resampled to mffe space are pretty coarse, should we resample mffe
# to iso voxel to improve accuracy?




# Dilate disc markers and resample
#sct_maths -i ${T2SAG}_seg_labeled_discs.nii.gz -dilate 10,10,3 \
#	-o ${T2SAG}_seg_labeled_discs_dil.nii.gz
#sct_apply_transfo -i ${T2SAG}_seg_labeled_discs_dil.nii.gz -d ${MFFE}.nii.gz \
#    -w warp_${T2SAG}2${MFFE}.nii.gz -x nn \
#	-o ${T2SAG}_seg_labeled_discs_dil_mffespace.nii.gz


# Apply transforms to labels
#sct_apply_transfo -i ${T2SAG}_seg_labeled.nii.gz -d ${MFFE}.nii.gz \
#    -w warp_${T2SAG}2${MFFE}.nii.gz -x nn -o ${MFFE}_seg_labeled_from_t2sag.nii.gz



# Crop template to relevant levels. sct_register_multimodal is not smart enough to 
# handle non-identical label sets.
sct_label_utils -i ${TDIR}/PAM50_label_body.nii.gz \
	-remove-reference ${T2SAG}_seg_labeled_body_imffespace.nii.gz \
	-o PAM50_label_body_cropped.nii.gz

# Create synthetic T2 from template
sct_maths -i ${TDIR}/PAM50_gm.nii.gz -add ${TDIR}/PAM50_cord.nii.gz -o PAM50_gw.nii.gz

# Register mffe to template via GM/WM seg
sct_register_multimodal \
-i i${MFFE}_gw.nii.gz \
-iseg i${MFFE}_seg.nii.gz \
-ilabel ${T2SAG}_seg_labeled_body_imffespace.nii.gz \
-d PAM50_gw.nii.gz \
-dseg ${TDIR}/PAM50_cord.nii.gz \
-dlabel PAM50_label_body_cropped.nii.gz \
-o ${MFFE}_gw_PAM50space.nii.gz \
-param step=0,type=label,dof=Tx_Ty_Tz_Sz:\
step=1,type=seg,algo=slicereg,poly=3:\
step=2,type=im,algo=syn

# Warp level labels to template
sct_apply_transfo -i ${T2SAG}_seg_labeled_imffespace.nii.gz -d PAM50_gw.nii.gz \
    -w warp_i${MFFE}_gw2PAM50_gw.nii.gz \
	-x nn -o ${T2SAG}_seg_labeled_PAM50space.nii.gz

# Extract first fmri volume, find centerline, make fmri space mask
sct_image -keep-vol 0 -i ${FMRI}.nii.gz -o ${FMRI}_0.nii.gz
sct_get_centerline -c t2s -i ${FMRI}_0.nii.gz
sct_create_mask -i ${FMRI}_0.nii.gz -p centerline,${FMRI}_0_centerline.nii.gz -size ${MASKSIZE}mm \
-o ${FMRI}_mask${MASKSIZE}.nii.gz

# fMRI motion correction
sct_fmri_moco -m ${FMRI}_mask${MASKSIZE}.nii.gz -i ${FMRI}.nii.gz 

# Find cord on mean fMRI to improve registration
sct_deepseg_sc -i ${FMRI}_moco_mean.nii.gz -c t2s

# Register mean fMRI to mFFE
sct_register_multimodal \
-i ${FMRI}_moco_mean.nii.gz -iseg ${FMRI}_moco_mean_seg.nii.gz \
-d ${MFFE}.nii.gz -dseg ${MFFE}_seg.nii.gz \
-m ${MFFE}_mask${MASKSIZE}.nii.gz \
-param step=1,type=seg,algo=centermass,metric=MeanSquares,smooth=2:\
step=2,type=im,algo=slicereg,metric=MI

# Warp template t2s to mffe space
sct_apply_transfo -i ${TDIR}/PAM50_t2s.nii.gz \
-w warp_PAM50_gw2i${MFFE}_gw.nii.gz \
-d ${MFFE}_gw.nii.gz -o PAM50_t2s_mffespace.nii.gz

# Warp mask to template space and trim template space images to actual FOV
sct_apply_transfo -i ${MFFE}_mask${MASKSIZE}.nii.gz -x nn \
-w warp_i${MFFE}_gw2PAM50_gw.nii.gz \
-d ${TDIR}/PAM50_t2s.nii.gz  -o ${MFFE}_mask${MASKSIZE}_PAM50space.nii.gz

sct_crop_image -i ${TDIR}/PAM50_t2s.nii.gz \
-m ${MFFE}_mask${MASKSIZE}_PAM50space.nii.gz \
-o PAM50_t2s_cropped.nii.gz

# Warp mean fmri, mffe, gm, ROIs to template space
sct_apply_transfo -i ${FMRI}_moco_mean.nii.gz \
-w warp_${FMRI}_moco_mean2mffe1.nii.gz warp_i${MFFE}_gw2PAM50_gw.nii.gz \
-d PAM50_t2s_cropped.nii.gz  -o ${FMRI}_moco_mean_PAM50space.nii.gz

sct_apply_transfo -i ${MFFE}.nii.gz \
-w warp_i${MFFE}_gw2PAM50_gw.nii.gz \
-d PAM50_t2s_cropped.nii.gz  -o ${MFFE}_PAM50space.nii.gz

sct_apply_transfo -i ${MFFE}_gmseg.nii.gz -x nn \
-w warp_i${MFFE}_gw2PAM50_gw.nii.gz \
-d PAM50_t2s_cropped.nii.gz -o ${MFFE}_gmseg_PAM50space.nii.gz

sct_apply_transfo -i ${FMRI}_moco_GMcutlabel.nii.gz  -x nn \
-w warp_${FMRI}_moco_mean2mffe1.nii.gz warp_i${MFFE}_gw2PAM50_gw.nii.gz \
-d PAM50_t2s_cropped.nii.gz  -o ${FMRI}_moco_GMcutlabel_PAM50space.nii.gz


# ROIs to mffe space
sct_apply_transfo -i ${FMRI}_moco_GMcutlabel.nii.gz  -x nn \
-w warp_${FMRI}_moco_mean2mffe1.nii.gz \
-d i${MFFE}_gw.nii.gz -o ${FMRI}_moco_GMcutlabel_imffespace.nii.gz


# Warp template CSF to fmri space and mffe space
sct_apply_transfo -i ${TDIR}/PAM50_csf.nii.gz -x nn \
-w warp_PAM50_gw2i${MFFE}_gw.nii.gz warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_CSF.nii.gz

sct_apply_transfo -i ${TDIR}/PAM50_csf.nii.gz -x nn \
-w warp_PAM50_gw2i${MFFE}_gw.nii.gz \
-d i${MFFE}_gw.nii.gz -o i${MFFE}_CSF.nii.gz


# Get mffe GM/WM/label/centerline in fmri space
sct_apply_transfo -i i${MFFE}_gmseg.nii.gz -x nn \
-w warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_GM.nii.gz

sct_apply_transfo -i i${MFFE}_wmseg.nii.gz -x nn \
-w warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_WM.nii.gz

sct_apply_transfo -i ${T2SAG}_seg_labeled_imffespace.nii.gz -x nn \
-w warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_LABEL.nii.gz


# Make "not-spine" ROI in fmri space (combine CSF and seg, dilate, invert)
sct_maths -i ${FMRI}_moco_mean_seg.nii.gz -add ${FMRI}_moco_CSF.nii.gz -o tmp.nii.gz
sct_maths -i tmp.nii.gz -bin 0.1 -o tmp.nii.gz
sct_maths -i tmp.nii.gz -dilate 5,5,1 -o ${FMRI}_moco_SPINE.nii.gz
sct_maths -i ${FMRI}_moco_SPINE.nii.gz -mul -1 -o tmp.nii.gz
sct_maths -i tmp.nii.gz -add 1 -o tmp.nii.gz
sct_maths -i tmp.nii.gz -bin 0.1 -o  ${FMRI}_moco_NOTSPINE.nii.gz
rm tmp.nii.gz

# Make horn- and level-specific gray matter ROI images
make_gm_rois.py ${FMRI}_moco_GM.nii.gz ${FMRI}_moco_LABEL.nii.gz 


# RETROICOR
# First split physlog into card and resp, and trim to match length of scan.
parse_physlog.py SCANPHYSLOG*.log 496 fmri.dcm
RetroTS.py -r physlog_respiratory.csv -c physlog_cardiac.csv -p 496 -n 1 \
    -v `cat volume_acquisition_time.txt` -cardiac_out 0 -prefix ricor
cleanup_physlog.py


# Regression-based cleanup of confounds
regress.py

# Compute connectivity images
compute_connectivity_slice.py
compute_connectivity_level.py

# Resample connectivity images to mffe and template space
for IMG in \
  connectivity_r_slice \
  connectivity_z_slice \
  connectivity_r_level \
  connectivity_z_level \
  ; do

     sct_apply_transfo -i ${IMG}.nii.gz \
	 -w warp_${FMRI}_moco_mean2${MFFE}.nii.gz \
	 -d i${MFFE}.nii.gz -o ${IMG}_imffespace.nii.gz

     sct_apply_transfo -i ${IMG}.nii.gz \
	 -w warp_${FMRI}_moco_mean2${MFFE}.nii.gz warp_i${MFFE}_gw2PAM50_gw.nii.gz \
	 -d ${TDIR}/PAM50_t2s.nii.gz -o ${IMG}_PAM50space.nii.gz

 done


 # Output QA PDF
 xvfb-run --server-num=$(($$ + 99)) \
 --server-args='-screen 0 1600x1200x24 -ac +extension GLX' \
 make_pdf.sh

 convert_pdf.sh
 


# Retroicor:
# 
# Motion correction first: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2833099/
#
# Barry 2014 https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4120419/
#
# Another procedure using FSL / PNM https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5315056/
#     popp, pnm_evs




