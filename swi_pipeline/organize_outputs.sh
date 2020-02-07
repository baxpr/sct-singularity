#!/bin/bash

rsrc=PDF
mkdir "${rsrc}"
cp \
swi_report.pdf \
"${rsrc}"

rsrc=WARPS
mkdir "${rsrc}"
cp \
warp_swi2mffe.nii.gz \
warp_mffe2swi.nii.gz \
"${rsrc}"

rsrc=SWI
mkdir "${rsrc}"
cp \
mffe_swimag.nii.gz \
"${rsrc}"

rsrc=FILTSWI
mkdir "${rsrc}"
cp \
swi_filtswi.nii.gz \
mffe_filtswi.nii.gz \
PAM50_filtswi.nii.gz \
"${rsrc}"

rsrc=MIPFILTSWI
mkdir "${rsrc}"
cp \
swi_mip*_filtswi.nii.gz \
mffe_mip*_filtswi.nii.gz \
PAM50_mip*_filtswi.nii.gz \
"${rsrc}"

rsrc=PHASEMASK
mkdir "${rsrc}"
cp \
swi_maskph.nii.gz \
mffe_maskph.nii.gz \
PAM50_maskph.nii.gz \
"${rsrc}"

rsrc=MIPPHASEMASK
mkdir "${rsrc}"
cp \
swi_mip*_maskph.nii.gz \
mffe_mip*_maskph.nii.gz \
PAM50_mip*_maskph.nii.gz \
"${rsrc}"

rsrc=INVPHASEMASK
mkdir "${rsrc}"
cp \
swi_invmaskph.nii.gz \
mffe_invmaskph.nii.gz \
PAM50_invmaskph.nii.gz \
"${rsrc}"

rsrc=MIPINVPHASEMASK
mkdir "${rsrc}"
cp \
swi_mip*_invmaskph.nii.gz \
mffe_mip*_invmaskph.nii.gz \
PAM50_mip*_invmaskph.nii.gz \
"${rsrc}"

rsrc=MFFE
mkdir "${rsrc}"
cp \
swi_mffe.nii.gz \
"${rsrc}"

rsrc=MASK
mkdir "${rsrc}"
cp \
mffe_mask*.nii.gz \
"${rsrc}"

