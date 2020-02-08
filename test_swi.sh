#!/bin/bash
#
# Test SWI

singularity run \
--app swi_pipeline \
--bind `pwd`:/wkdir \
baxpr-sct-singularity-master-v3.0.0.simg \
--outdir OUTPUTS_swi \
--swi_dir INPUTS_swi/swi_dir \
--mffe_dir OUTPUTS_mffe/MFFE \
--cord_dir OUTPUTS_mffe/CORD \
--warps_dir OUTPUTS_mffe/WARPS \
--swi_reg_param "step=1,type=seg,algo=slicereg:step=2,type=im,algo=rigid,metric=CC,slicewise=1" \
--masksize 30 \
--ph_scale 0.001 \
--window_alpha 30 \
--haacke_factor 5 \
--project TESTPROJ \
--subject TESTSUBJ \
--session TESTSESS \
--scan TESTSCAN
