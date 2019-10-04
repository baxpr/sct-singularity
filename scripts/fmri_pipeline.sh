#!/bin/bash
#
# Process fMRI:
#    Motion correction
#    Registration to mFFE
#    Warp to atlas space
#    ROI time series extraction

# Which images will we work on?
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

# Get vertebral labels for mffe
sct_label_vertebrae -i ${MFFE}.nii.gz -s ${MFFE}_seg.nii.gz -c t2 -initcenter ${INITCENTER} -r 0

# Crop template to relevant levels. sct_register_multimodal is not smart enough to 
# handle non-identical label sets:
cp ${TDIR}/PAM50_label_disc.nii.gz .
crop_template_labels.py ${MFFE}_seg_labeled_discs.nii.gz ${TDIR}/PAM50_label_disc.nii.gz

# Create synthetic T2 from template
sct_maths -i ${TDIR}/PAM50_gm.nii.gz -add ${TDIR}/PAM50_cord.nii.gz -o PAM50_gw.nii.gz

# Register mffe to template via GM/WM seg
sct_register_multimodal \
-i ${MFFE}_gw.nii.gz \
-iseg ${MFFE}_seg.nii.gz \
-ilabel ${MFFE}_seg_labeled_discs.nii.gz \
-d PAM50_gw.nii.gz \
-dseg ${TDIR}/PAM50_cord.nii.gz \
-dlabel PAM50_label_disc_cropped.nii.gz \
-o ${MFFE}_gw_warped.nii.gz \
-param step=0,type=label,dof=Tx_Ty_Tz_Sz:\
step=1,type=seg,algo=slicereg,poly=3:\
step=2,type=im,algo=syn

# Extract first fmri volume, find centerline, make fmri space mask
sct_image -keep-vol 0 -i ${FMRI}.nii.gz -o ${FMRI}_0.nii.gz
sct_get_centerline -c t2s -i ${FMRI}_0.nii.gz
sct_create_mask -i ${FMRI}_0.nii.gz -p centerline,${FMRI}_0_centerline.nii.gz -size ${MASKSIZE}mm \
-o ${FMRI}_mask${MASKSIZE}.nii.gz

# fMRI motion correction
sct_fmri_moco -m ${FMRI}_mask${MASKSIZE}.nii.gz -i ${FMRI}.nii.gz 

# Find cord on mean fMRI to improve registration
sct_deepseg_sc -i ${FMRI}_moco_mean.nii.gz -c t2s

# Create mffe space mask for registration
sct_create_mask -i ${MFFE}.nii.gz -p centerline,${MFFE}_seg.nii.gz -size ${MASKSIZE}mm \
-o ${MFFE}_mask${MASKSIZE}.nii.gz

# Register mean fMRI to mFFE
sct_register_multimodal \
-i ${FMRI}_moco_mean.nii.gz -iseg ${FMRI}_moco_mean_seg.nii.gz \
-d ${MFFE}.nii.gz -dseg ${MFFE}_seg.nii.gz \
-m ${MFFE}_mask${MASKSIZE}.nii.gz \
-param step=1,type=seg,algo=centermass,metric=MeanSquares,smooth=2:\
step=2,type=im,algo=slicereg,metric=MI

# Warp template t2s to mffe space
sct_apply_transfo -i ${TDIR}/PAM50_t2s.nii.gz \
-w warp_PAM50_gw2${MFFE}_gw.nii.gz \
-d ${MFFE}_gw.nii.gz -o PAM50_t2s_mffespace.nii.gz

# Warp mask to template space and trim template space images to actual FOV
sct_apply_transfo -i ${MFFE}_mask${MASKSIZE}.nii.gz -x nn \
-w warp_${MFFE}_gw2PAM50_gw.nii.gz \
-d ${TDIR}/PAM50_t2s.nii.gz  -o ${MFFE}_mask${MASKSIZE}_PAM50space.nii.gz

sct_crop_image -i ${TDIR}/PAM50_t2s.nii.gz \
-m ${MFFE}_mask${MASKSIZE}_PAM50space.nii.gz \
-o PAM50_t2s_cropped.nii.gz

# Warp mean fmri, mffe, gm, ROIs to template space
sct_apply_transfo -i ${FMRI}_moco_mean.nii.gz \
-w warp_${FMRI}_moco_mean2mffe1.nii.gz warp_${MFFE}_gw2PAM50_gw.nii.gz \
-d PAM50_t2s_cropped.nii.gz  -o ${FMRI}_moco_mean_PAM50space.nii.gz

sct_apply_transfo -i ${MFFE}.nii.gz \
-w warp_${MFFE}_gw2PAM50_gw.nii.gz \
-d PAM50_t2s_cropped.nii.gz  -o ${MFFE}_PAM50space.nii.gz

sct_apply_transfo -i ${MFFE}_gmseg.nii.gz -x nn \
-w warp_${MFFE}_gw2PAM50_gw.nii.gz \
-d PAM50_t2s_cropped.nii.gz -o ${MFFE}_gmseg_PAM50space.nii.gz

sct_apply_transfo -i ${FMRI}_moco_GMcutlabel.nii.gz  -x nn \
-w warp_${FMRI}_moco_mean2mffe1.nii.gz warp_${MFFE}_gw2PAM50_gw.nii.gz \
-d PAM50_t2s_cropped.nii.gz  -o ${FMRI}_moco_GMcutlabel_PAM50space.nii.gz


# ROIs to mffe space
sct_apply_transfo -i ${FMRI}_moco_GMcutlabel.nii.gz  -x nn \
-w warp_${FMRI}_moco_mean2mffe1.nii.gz \
-d ${MFFE}_gw.nii.gz -o ${FMRI}_moco_GMcutlabel_mffespace.nii.gz


# Warp template CSF to fmri space and mffe space
sct_apply_transfo -i ${TDIR}/PAM50_csf.nii.gz -x nn \
-w warp_PAM50_gw2${MFFE}_gw.nii.gz warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_CSF.nii.gz

sct_apply_transfo -i ${TDIR}/PAM50_csf.nii.gz -x nn \
-w warp_PAM50_gw2${MFFE}_gw.nii.gz \
-d ${MFFE}_gw.nii.gz -o ${MFFE}_CSF.nii.gz


# Get mffe GM/WM/label/centerline in fmri space
sct_apply_transfo -i ${MFFE}_gmseg.nii.gz -x nn \
-w warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_GM.nii.gz

sct_apply_transfo -i ${MFFE}_wmseg.nii.gz -x nn \
-w warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_WM.nii.gz

sct_apply_transfo -i ${MFFE}_seg_labeled.nii.gz -x nn \
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
	 -d ${MFFE}.nii.gz -o ${IMG}_mffespace.nii.gz

     sct_apply_transfo -i ${IMG}.nii.gz \
	 -w warp_${FMRI}_moco_mean2${MFFE}.nii.gz warp_${MFFE}_gw2PAM50_gw.nii.gz \
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




