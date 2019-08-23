#!/bin/bash
#
# Make useful QA outputs with fsleyes
# https://users.fmrib.ox.ac.uk/~paulmc/fsleyes/userdoc/latest/command_line.html

# Location of fsleyes
FSLEYES=/opt/sct/python/envs/venv_sct/bin/fsleyes

# Location of template
TDIR=/opt/sct/data/PAM50/template/

${FSLEYES} render \
--scene ortho \
--xzoom 1000 --yzoom 1000 --zzoom 2500 \
--outfile test.png --size 1800 600 \
mffe1.nii.gz \
connectivity_r_slice_mffespace.nii.gz \
--useNegativeCmap \
--cmap red-yellow --negativeCmap blue-lightblue \
--displayRange 0.5 1.0
