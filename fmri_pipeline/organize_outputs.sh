#!/bin/bash

rsrc=PDF
mkdir "${rsrc}"
cp \
fmri_report.pdf \
"${rsrc}"

rsrc=WARPS
mkdir "${rsrc}"
cp \
warp_fmri2mffe.nii.gz \
warp_mffe2fmri.nii.gz \
"${rsrc}"

rsrc=MFFE
mkdir "${rsrc}"
cp \
fmri_mffe.nii.gz \
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

rsrc=FMRI_REGBP
mkdir "${rsrc}"
cp \
fmri_regbp.nii.gz \
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
"${rsrc}"

rsrc=WM
mkdir "${rsrc}"
cp \
fmri_wm.nii.gz \
"${rsrc}"

rsrc=CSF
mkdir "${rsrc}"
cp \
fmri_csf.nii.gz \
"${rsrc}"

rsrc=NOTSPINE
mkdir "${rsrc}"
cp \
fmri_notspine.nii.gz \
"${rsrc}"

rsrc=MASK
mkdir "${rsrc}"
cp \
fmri_mask??.nii.gz \
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
"${rsrc}"

rsrc=CORD_LABELED
mkdir "${rsrc}"
cp \
fmri_cord_labeled.nii.gz \
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

