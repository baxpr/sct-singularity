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
mffe_filtswi.nii.gz \
PAM50_filtswi.nii.gz \
swi_filtswi.nii.gz \
"${rsrc}"

rsrc=MIPFILTSWI
mkdir "${rsrc}"
cp \
PAM50_mip*_filtswi.nii.gz \
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

