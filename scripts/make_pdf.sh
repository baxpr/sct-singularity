#!/bin/bash
#
# Make useful QA outputs with fsleyes
# https://users.fmrib.ox.ac.uk/~paulmc/fsleyes/userdoc/latest/command_line.html

# Location of fsleyes
FSLEYES=/opt/sct/python/envs/venv_sct/bin/fsleyes

# Location of template
TDIR=/opt/sct/data/PAM50/template/

# Get mffe voxel dims
IDIM=$(get_ijk.py i mffe1.nii.gz)
let "IMID = $IDIM / 2"
JDIM=$(get_ijk.py j mffe1.nii.gz)
let "JMID = $JDIM / 2"
KDIM=$(get_ijk.py k mffe1.nii.gz)
let "KMAX = $KDIM - 1"

# Connectivity maps for each mffe slice
for K in $(seq -w 0 $KMAX) ; do
${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidex --hidey \
  --zzoom 2500 \
  --showColourBar --colourBarLocation right \
  --outfile test_${K}.png --size 600 600 \
  --voxelLoc $IMID $JMID $K \
mffe1.nii.gz \
connectivity_r_slice_mffespace.nii.gz \
  --useNegativeCmap \
  --cmap red-yellow --negativeCmap blue-lightblue \
  --displayRange 0.4 1.0 \
mffe1_gmseg.nii.gz \
  --overlayType label \
  --outline --outlineWidth 2
done


# GM/WM/CSF outlines on each mffe slice

# Something, maybe GM/cord, on template space image

