#!/bin/bash
#
# Process fMRI:
#    Motion correction
#    Registration to mFFE
#    Warp to atlas space
#    ROI time series extraction

cd ../OUTPUTS
cp ../INPUTS/fmri.dcm .
cp ../INPUTS/fmri.nii.gz .
cp ../INPUTS/mffe_e1.nii.gz .
cp ../INPUTS/physlog.dcm .
export PATH=/wkdir/scripts:${PATH}

# Which images will we work on?
MFFE=mffe_e1
FMRI=fmri
PHYS=physlog

# Vertebral label for center slice of mffe
INITCENTER=3

# How big of a mask to use for registrations?
MSIZE=30

# Location of template
TDIR=/opt/sct/data/PAM50/template


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
sct_create_mask -i ${FMRI}_0.nii.gz -p centerline,${FMRI}_0_centerline.nii.gz -size ${MSIZE}mm \
-o ${FMRI}_mask${MSIZE}.nii.gz

# fMRI motion correction
sct_fmri_moco -m ${FMRI}_mask${MSIZE}.nii.gz -i ${FMRI}.nii.gz 

# Find cord on mean fMRI to improve registration
sct_deepseg_sc -i ${FMRI}_moco_mean.nii.gz -c t2s

# Create mffe space mask for registration
sct_create_mask -i ${MFFE}.nii.gz -p centerline,${MFFE}_seg.nii.gz -size ${MSIZE}mm \
-o ${MFFE}_mask${MSIZE}.nii.gz

# Register mean fMRI to mFFE
sct_register_multimodal \
-i ${FMRI}_moco_mean.nii.gz -iseg ${FMRI}_moco_mean_seg.nii.gz \
-d ${MFFE}.nii.gz -dseg ${MFFE}_seg.nii.gz \
-m ${MFFE}_mask${MSIZE}.nii.gz \
-param step=1,type=seg,algo=centermass,metric=MeanSquares,smooth=2:\
step=2,type=im,algo=slicereg,metric=MI

# Warp template CSF to fmri space
sct_apply_transfo -i ${TDIR}/PAM50_csf.nii.gz -x nn \
-w warp_PAM50_gw2${MFFE}_gw.nii.gz warp_${MFFE}2${FMRI}_moco_mean.nii.gz \
-d ${FMRI}_moco_mean.nii.gz -o ${FMRI}_moco_CSF.nii.gz

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
make_gm_rois.py


# RETROICOR
# First split physlog into card and resp, and trim to match length of scan.
unzip ${PHYS}.dcm
parse_physlog.py SCANPHYSLOG*.log 496 fmri.dcm
RetroTS.py -r respiratory.1D -c cardiac.1D -p 496 -n 1 -v `cat vat.txt` -prefix ricor
cleanup_physlog.py

# Regression-based cleanup of confounds
regress.py

# Compute connectivity images
compute_connectivity.py








# Retroicor:
# 
# Motion correction first: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2833099/
#
# Barry 2014 https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4120419/
#
# Another procedure using FSL / PNM https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5315056/
#     popp, pnm_evs




