#!/bin/bash
#
# Process fMRI:
#    Motion correction
#    Registration to mFFE
#    Warp to atlas space
#    ROI time series extraction

# Image filenames are <geometry>_<content>.nii.gz
# Template content always marked as "template", otherwise it's subject content

# Location of template
TDIR=${SCTDIR}/data/PAM50/template

# Use first echo of mffe
cp mffe1.nii.gz mffe_mffe.nii.gz
cp t2sag.nii.gz t2sag_t2sag.nii.gz
cp fmri.nii.gz fmri_fmri.nii.gz

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

# Get cord seg for the T2 sag
sct_deepseg_sc -i t2sag_t2sag.nii.gz -c t2
mv t2sag_t2sag_seg.nii.gz t2sag_cord.nii.gz

# Invert t2sag contrast so level-finding works better
invert_t2sag.py t2sag_t2sag.nii.gz t2sag_invt2sag.nii.gz

# Get vert labels on the inverted t2sag and list them
sct_label_vertebrae -i t2sag_invt2sag.nii.gz -s t2sag_cord.nii.gz -c t1
sct_label_utils -i t2sag_cord_labeled_discs.nii.gz -display 

# Register t2sag to mffe
sct_register_multimodal -i t2sag_t2sag.nii.gz -iseg t2sag_cord.nii.gz \
	-d mffe_mffe.nii.gz -dseg mffe_cord.nii.gz \
	-m mffe_mask${MASKSIZE}.nii.gz \
	-o mffe_t2sag.nii.gz \
	-owarp warp_t2sag2mffe.nii.gz
mv warp_mffe_mffe2t2sag_t2sag.nii.gz warp_mffe2t2sag.nii.gz
mv mffe_t2sag_inv.nii.gz t2sag_mffe.nii.gz



# Resample mffe to iso voxel for better label placement
FAC=$(get_ijk.py f mffe_mffe.nii.gz)
sct_resample -i mffe_mffe.nii.gz -f 1x1x${FAC} -x nn -o imffe_mffe.nii.gz
sct_resample -i mffe_cord.nii.gz -ref imffe_mffe.nii.gz -x nn -o imffe_cord.nii.gz
sct_resample -i mffe_synt2.nii.gz -ref imffe_mffe.nii.gz -x nn -o imffe_synt2.nii.gz

# Make a padded imffe to put body markers in
sct_image -i imffe_mffe.nii.gz -pad 0,0,40 -o pimffe_mffe.nii.gz

# Resample level ROIs to pimffe space
sct_apply_transfo -i t2sag_cord_labeled.nii.gz -d pimffe_mffe.nii.gz \
    -w warp_t2sag2mffe.nii.gz -x nn \
	-o pimffe_cord_labeled.nii.gz

# Create body markers in pimffe space
sct_label_utils -i pimffe_cord_labeled.nii.gz -vert-body 0 \
	-o pimffe_cord_labeled_body.nii.gz

# Crop body markers and level image back to imffe space
sct_crop_image -i pimffe_cord_labeled_body.nii.gz \
	-ref imffe_mffe.nii.gz -o imffe_cord_labeled_body.nii.gz
sct_crop_image -i pimffe_cord_labeled.nii.gz \
	-ref imffe_mffe.nii.gz -o imffe_cord_labeled.nii.gz

# Crop template to relevant levels. sct_register_multimodal is not smart enough to 
# handle non-identical label sets.
sct_label_utils -i ${TDIR}/PAM50_label_body.nii.gz \
	-remove-reference imffe_cord_labeled_body.nii.gz \
	-o PAM50_template_cord_labeled_body.nii.gz

# Create synthetic T2 from template
sct_maths -i ${TDIR}/PAM50_gm.nii.gz -add ${TDIR}/PAM50_cord.nii.gz -o PAM50_template_synt2.nii.gz

# Register imffe to template via GM/WM seg
sct_register_multimodal \
-i mffe_synt2.nii.gz \
-iseg mffe_cord.nii.gz \
-ilabel imffe_cord_labeled_body.nii.gz \
-d PAM50_template_synt2.nii.gz \
-dseg ${TDIR}/PAM50_cord.nii.gz \
-dlabel PAM50_template_cord_labeled_body.nii.gz \
-o PAM50_synt2.nii.gz \
-param step=0,type=label,dof=Tx_Ty_Tz_Sz:\
step=1,type=seg,algo=slicereg,poly=3:\
step=2,type=im,algo=syn

mv warp_mffe_synt22PAM50_template_synt2.nii.gz warp_mffe2PAM50.nii.gz
mv warp_PAM50_template_synt22mffe_synt2.nii.gz warp_PAM502mffe.nii.gz 
mv PAM50_synt2_inv.nii.gz mffe_PAM50_template_synt2.nii.gz

# Warp level labels to template
sct_apply_transfo -i t2sag_cord_labeled.nii.gz -d PAM50_synt2.nii.gz \
    -w warp_t2sag2mffe.nii.gz warp_mffe2PAM50.nii.gz \
	-x nn -o PAM50_cord_labeled.nii.gz


# Extract first fmri volume, find centerline, make fmri space mask
sct_image -keep-vol 0 -i fmri_fmri.nii.gz -o fmri_fmri0.nii.gz
sct_get_centerline -c t2s -i fmri_fmri0.nii.gz
mv fmri_fmri0_centerline.nii.gz fmri_centerline.nii.gz
mv fmri_fmri0_centerline.csv fmri_centerline.csv
sct_create_mask -i fmri_fmri0.nii.gz -p centerline,fmri_centerline.nii.gz -size ${MASKSIZE}mm \
-o fmri_mask${MASKSIZE}.nii.gz

# fMRI motion correction
sct_fmri_moco -m fmri_mask${MASKSIZE}.nii.gz -i fmri_fmri.nii.gz 
mv fmri_fmri_moco.nii.gz fmri_moco.nii.gz
mv fmri_fmri_moco_mean.nii.gz fmri_moco_mean.nii.gz
mv fmri_fmri_moco_params_X.nii.gz fmri_moco_params_X.nii.gz
mv fmri_fmri_moco_params_Y.nii.gz fmri_moco_params_Y.nii.gz
mv fmri_fmri_moco_params.tsv fmri_moco_params.tsv
rm fmri_fmri_T????.nii.gz


# Find cord on mean fMRI to improve registration
sct_deepseg_sc -i fmri_moco_mean.nii.gz -c t2s
mv fmri_moco_mean_seg.nii.gz fmri_cord.nii.gz

# Register mean fMRI to mFFE
sct_register_multimodal \
-i fmri_moco_mean.nii.gz -iseg fmri_cord.nii.gz \
-d mffe_mffe.nii.gz -dseg mffe_cord.nii.gz \
-m mffe_mask${MASKSIZE}.nii.gz \
-param step=1,type=seg,algo=centermass,metric=MeanSquares,smooth=2:\
step=2,type=im,algo=slicereg,metric=MI

mv warp_fmri_moco_mean2mffe_mffe.nii.gz warp_fmri2mffe.nii.gz
mv warp_mffe_mffe2fmri_moco_mean.nii.gz warp_mffe2fmri.nii.gz
mv fmri_moco_mean_reg.nii.gz mffe_moco_mean.nii.gz
mv mffe_mffe_reg.nii.gz fmri_mffe.nii.gz


exit 0


# Warp template t2s to mffe space
sct_apply_transfo -i ${TDIR}/PAM50_t2s.nii.gz \
-w warp_PAM502mffe.nii.gz \
-d mffe_mffe.nii.gz -o PAM50_t2s_mffespace.nii.gz

# Warp mask to template space and trim template space images to actual FOV
sct_apply_transfo -i mffe_mask${MASKSIZE}.nii.gz -x nn \
-w warp_mffe2PAM50.nii.gz \
-d ${TDIR}/PAM50_t2s.nii.gz  -o PAM50_mask${MASKSIZE}.nii.gz

sct_crop_image -i ${TDIR}/PAM50_t2s.nii.gz \
-m PAM50_mask${MASKSIZE}.nii.gz \
-o PAM50_t2s_cropped.nii.gz

# Warp mean fmri, mffe, gm, ROIs to template space
sct_apply_transfo -i fmri_moco_mean.nii.gz \
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




