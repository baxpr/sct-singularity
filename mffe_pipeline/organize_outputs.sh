#!/bin/bash

rsrc=PDF
mkdir "${rsrc}"
cp \
mffe_report.pdf \
"${rsrc}"

rsrc=WARPS
mkdir "${rsrc}"
cp \
warp_mffe2PAM50.nii.gz \
warp_PAM502mffe.nii.gz \
warp_mffe2t2sag.nii.gz \
warp_t2sag2mffe.nii.gz \
"${rsrc}"

rsrc=MFFE
mkdir "${rsrc}"
cp \
mffe_mffe.nii.gz \
PAM50_mffe.nii.gz \
t2sag_mffe.nii.gz \
"${rsrc}"

rsrc=T2SAG
mkdir "${rsrc}"
cp \
t2sag_t2sag.nii.gz \
mffe_t2sag.nii.gz \
"${rsrc}"

rsrc=GM
mkdir "${rsrc}"
cp \
mffe_gm.nii.gz \
PAM50_gm.nii.gz \
"${rsrc}"

rsrc=WM
mkdir "${rsrc}"
cp \
mffe_wm.nii.gz \
PAM50_wm.nii.gz \
"${rsrc}"

rsrc=CSF
mkdir "${rsrc}"
cp \
mffe_csf.nii.gz \
PAM50_csf.nii.gz \
"${rsrc}"

rsrc=MASK
mkdir "${rsrc}"
cp \
mffe_mask30.nii.gz \
PAM50_mask30.nii.gz \
"${rsrc}"

rsrc=SYNT2
mkdir "${rsrc}"
cp \
mffe_synt2.nii.gz \
PAM50_synt2.nii.gz \
"${rsrc}"

rsrc=CORD
mkdir "${rsrc}"
cp \
mffe_cord.nii.gz \
t2sag_cord.nii.gz \
PAM50_cord.nii.gz \
"${rsrc}"

rsrc=CORD_LABELED
mkdir "${rsrc}"
cp \
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

rsrc=CSA
mkdir "${rsrc}"
cp \
mffe_csa.csv \
"${rsrc}"
