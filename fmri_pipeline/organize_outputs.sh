#!/bin/bash

rsrc=PDF
mkdir "${rsrc}"
cp \
qcreport.pdf \
"${rsrc}"

rsrc=WARPS
mkdir "${rsrc}"
cp \
warp_fmri2mffe.nii.gz \
warp_mffe2fmri.nii.gz \
warp_mffe2PAM50.nii.gz \
warp_PAM502mffe.nii.gz \
warp_mffe2t2sag.nii.gz \
warp_t2sag2mffe.nii.gz \
"${rsrc}"

rsrc=MFFE
mkdir "${rsrc}"
cp \
mffe_mffe.nii.gz \
fmri_mffe.nii.gz \
PAM50_mffe.nii.gz \
t2sag_mffe.nii.gz \
"${rsrc}"

rsrc=T2SAG
mkdir "${rsrc}"
cp \
t2sag_t2sag.nii.gz \
mffe_t2sag.nii.gz \
"${rsrc}"

rsrc=MOTION
mkdir "${rsrc}"
cp \
fmri_moco_params.tsv \
fmri_moco_params_X.nii.gz \
fmri_moco_params_Y.nii.gz \
"${rsrc}"

rsrc=FMRI_MOCO
mkdir "${rsrc}"
cp \
fmri_moco.nii.gz \
"${rsrc}"

rsrc=MOCO_MEAN
mkdir "${rsrc}"
cp \
fmri_moco_mean.nii.gz \
mffe_moco_mean.nii.gz \
PAM50_moco_mean.nii.gz \
"${rsrc}"

rsrc=GM
mkdir "${rsrc}"
cp \
fmri_gm.nii.gz \
mffe_gm.nii.gz \
PAM50_gm.nii.gz \
"${rsrc}"

rsrc=WM
mkdir "${rsrc}"
cp \
fmri_wm.nii.gz \
mffe_wm.nii.gz \
"${rsrc}"

rsrc=CSF
mkdir "${rsrc}"
cp \
fmri_csf.nii.gz \
mffe_csf.nii.gz \
"${rsrc}"

rsrc=NOTSPINE
mkdir "${rsrc}"
cp \
fmri_notspine.nii.gz \
"${rsrc}"

rsrc=MASK
mkdir "${rsrc}"
cp \
fmri_mask30.nii.gz \
mffe_mask30.nii.gz \
PAM50_mask30.nii.gz \
"${rsrc}"

rsrc=SYNT2
mkdir "${rsrc}"
cp \
mffe_synt2.nii.gz \
PAM50_synt2.nii.gz \
"${rsrc}"

rsrc=FMRI_CENTERLINE
mkdir "${rsrc}"
cp \
fmri_centerline.csv \
fmri_centerline.nii.gz \
"${rsrc}"

rsrc=GMCUT
mkdir "${rsrc}"
cp \
fmri_gmcut.nii.gz \
fmri_gmcut.csv \
"${rsrc}"

rsrc=GMCUTLABEL
mkdir "${rsrc}"
cp \
fmri_gmcutlabel.nii.gz \
fmri_gmcutlabel.csv \
mffe_gmcutlabel.nii.gz \
PAM50_gmcutlabel.nii.gz \
"${rsrc}"

rsrc=CORD
mkdir "${rsrc}"
cp \
fmri_cord.nii.gz \
mffe_cord.nii.gz \
t2sag_cord.nii.gz \
"${rsrc}"

rsrc=CORD_LABELED
mkdir "${rsrc}"
cp \
fmri_cord_labeled.nii.gz \
mffe_cord_labeled.nii.gz \
ipmffe_cord_labeled.nii.gz \
t2sag_cord_labeled.nii.gz \
PAM50_cord_labeled.nii.gz \
"${rsrc}"

rsrc=LABEL_POINTS
mkdir "${rsrc}"
cp \
ipmffe_cord_labeled_body.nii.gz \
t2sag_cord_labeled_discs.nii.gz \
"${rsrc}"

rsrc=RMAPS_FMRI
mkdir "${rsrc}"
cp \
fmri_R_Rdorsal_inslice.nii.gz \
fmri_R_Rventral_inslice.nii.gz \
fmri_R_Ldorsal_inslice.nii.gz \
fmri_R_Lventral_inslice.nii.gz \
"${rsrc}"

rsrc=ZMAPS_FMRI
mkdir "${rsrc}"
cp \
fmri_Z_Rdorsal_inslice.nii.gz \
fmri_Z_Rventral_inslice.nii.gz \
fmri_Z_Ldorsal_inslice.nii.gz \
fmri_Z_Lventral_inslice.nii.gz \
"${rsrc}"

rsrc=RMAPS_MFFE
mkdir "${rsrc}"
cp \
mffe_R_Rdorsal_inslice.nii.gz \
mffe_R_Rventral_inslice.nii.gz \
mffe_R_Ldorsal_inslice.nii.gz \
mffe_R_Lventral_inslice.nii.gz \
"${rsrc}"

rsrc=ZMAPS_MFFE
mkdir "${rsrc}"
cp \
mffe_Z_Rdorsal_inslice.nii.gz \
mffe_Z_Rventral_inslice.nii.gz \
mffe_Z_Ldorsal_inslice.nii.gz \
mffe_Z_Lventral_inslice.nii.gz \
"${rsrc}"

rsrc=RMAPS_PAM50
mkdir "${rsrc}"
cp \
PAM50_R_Rdorsal_inslice.nii.gz \
PAM50_R_Rventral_inslice.nii.gz \
PAM50_R_Ldorsal_inslice.nii.gz \
PAM50_R_Lventral_inslice.nii.gz \
"${rsrc}"

rsrc=ZMAPS_PAM50
mkdir "${rsrc}"
cp \
PAM50_Z_Rdorsal_inslice.nii.gz \
PAM50_Z_Rventral_inslice.nii.gz \
PAM50_Z_Ldorsal_inslice.nii.gz \
PAM50_Z_Lventral_inslice.nii.gz \
"${rsrc}"

rsrc=RMATRIX
mkdir "${rsrc}"
cp \
R_inslice.csv \
"${rsrc}"

rsrc=ZMATRIX
mkdir "${rsrc}"
cp \
Z_inslice.csv \
"${rsrc}"

rsrc=CSA
mkdir "${rsrc}"
cp \
mffe_csa.csv \
"${rsrc}"

rsrc=PHYSLOG
mkdir "${rsrc}"
cp \
physlog_cardiac.csv \
physlog_respiratory.csv \
ricor.csv \
ricor.slibase.1D \
"${rsrc}"

rsrc=VOL_ACQTIME
mkdir "${rsrc}"
cp \
volume_acquisition_time.txt \
"${rsrc}"

