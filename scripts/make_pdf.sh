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
KSQRT=$(get_ijk.py s mffe1.nii.gz)


# Check registration: subject segmentation overlaid on PAM50 T2s template
# GM/cord on template space image in mffe space
for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2100 \
    --outfile templateregistration_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  PAM50_t2s_mffespace.nii.gz \
    --interpolation linear \
  mffe1_gw.nii.gz \
    --lut melodic-classes \
    --overlayType label \
    --outline --outlineWidth 3 \
  mffe1_CSF.nii.gz \
    --lut harvard-oxford-subcortical \
    --overlayType label \
    --outline --outlineWidth 3
done


# Check segmentation: Subject segmentation overlaid on subject MFFE
# GM/WM/CSF outlines on each mffe slice
for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2500 \
    --outfile segmentation_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  mffe1.nii.gz \
    --interpolation linear \
  mffe1_gw.nii.gz \
    --lut melodic-classes \
    --overlayType label \
    --outline --outlineWidth 3 \
  mffe1_CSF.nii.gz \
    --lut harvard-oxford-subcortical \
    --overlayType label \
    --outline --outlineWidth 3
done


# Check connectivity: Seed connectivity maps overlaid on subject MFFE
# Connectivity maps for each mffe slice
for v in 0 1 2 3; do
  for K in $(seq -w 0 $KMAX) ; do
    ${FSLEYES} render \
      --scene ortho \
      --hideCursor --hidex --hidey \
      --zzoom 2500 \
      --outfile connectivity_r_roi${v}_slice${K}.png --size 600 600 \
      --voxelLoc $IMID $JMID $K \
    mffe1.nii.gz \
    connectivity_r_slice_mffespace.nii.gz \
      --volume $v \
      --useNegativeCmap \
      --cmap red-yellow --negativeCmap blue-lightblue \
      --displayRange 0.4 1.0 \
    mffe1_gmseg.nii.gz \
      --overlayType label \
      --outline --outlineWidth 2
  done
done



