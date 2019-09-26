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

# fmri voxel dims
IDIM_F=$(get_ijk.py i fmri_moco_mean.nii.gz)
let "IMID_F = $IDIM_F / 2"
JDIM_F=$(get_ijk.py j fmri_moco_mean.nii.gz)
let "JMID_F = $JDIM_F / 2"
KDIM_F=$(get_ijk.py k fmri_moco_mean.nii.gz)
let "KMAX_F = $KDIM_F - 1"
KSQRT_F=$(get_ijk.py s fmri_moco_mean.nii.gz)


# TODO
# Plot fmri mean movement from tsv with fixed axis limits


# Plot cor sections with ROIs for fmri, mffe, template alignment
# These are hard to see. Rather use slices
#${FSLEYES} render \
#  --scene ortho \
#  --hideCursor --hidex --hidez \
#  --outfile ROIs_cor_template.png --size 600 600 \
#  PAM50_t2s_cropped.nii.gz \
#    --interpolation linear \
#  fmri_moco_GMcutlabel_PAM50space.nii.gz \
#    --lut random_big \
#    --overlayType label
#
#${FSLEYES} render \
#  --scene ortho \
#  --hideCursor --hidex --hidez \
#  --outfile ROIs_cor_mffe.png --size 600 600 \
#  mffe1_PAM50space.nii.gz \
#    --interpolation linear \
#  fmri_moco_GMcutlabel_PAM50space.nii.gz \
#    --lut random_big \
#    --overlayType label
#		
#${FSLEYES} render \
#  --scene ortho \
#  --hideCursor --hidex --hidez \
#  --outfile ROIs_cor_fmri.png --size 600 600 \
#  fmri_moco_mean_PAM50space.nii.gz \
#    --interpolation linear \
#  fmri_moco_GMcutlabel_PAM50space.nii.gz \
#    --lut random_big \
#    --overlayType label



# Same but for level-based ROIs
#FIXME our ROIs are not 0..3 but something else
for v in 0 1 2 3; do
  for K in $(seq -w 0 $KMAX) ; do
    ${FSLEYES} render \
      --scene ortho \
      --hideCursor --hidex --hidey \
      --zzoom 2300 \
      --outfile connectivity_r_roi${v}_level_slice${K}.png --size 600 600 \
      --voxelLoc $IMID $JMID $K \
    mffe1.nii.gz \
    connectivity_r_level_mffespace.nii.gz \
      --volume $v \
      --useNegativeCmap \
      --cmap red-yellow --negativeCmap blue-lightblue \
      --displayRange 0.4 1.0 \
    mffe1_gmseg.nii.gz \
      --overlayType label \
      --outline --outlineWidth 2
  done
done

exit 0


# Check segmentation: Subject segmentation overlaid on subject MFFE
# ROIs on each mffe slice
for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
    --outfile roi_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  mffe1.nii.gz \
    --interpolation linear \
  fmri_moco_GMcutlabel_mffespace.nii.gz \
    --lut random_big \
    --overlayType label
done


# Plot cor sections for fmri, mffe, template alignment
${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidex --hidez \
  --outfile registration_cor_template.png --size 600 600 \
  PAM50_t2s_cropped.nii.gz \
    --interpolation linear \
  mffe1_gmseg_PAM50space.nii.gz \
    --lut harvard-oxford-subcortical \
    --overlayType label \
    --outline --outlineWidth 2

${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidex --hidez \
  --outfile registration_cor_mffe.png --size 600 600 \
  mffe1_PAM50space.nii.gz \
    --interpolation linear \
  mffe1_gmseg_PAM50space.nii.gz \
    --lut harvard-oxford-subcortical \
    --overlayType label \
    --outline --outlineWidth 2
		
${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidex --hidez \
  --outfile registration_cor_fmri.png --size 600 600 \
  fmri_moco_mean_PAM50space.nii.gz \
    --interpolation linear \
  mffe1_gmseg_PAM50space.nii.gz \
    --lut harvard-oxford-subcortical \
    --overlayType label \
    --outline --outlineWidth 2


# Check fmri registration: subject segmentation overlaid on fmri
for K in $(seq -w 0 $KMAX_F) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
    --outfile fmriregistration_slice${K}.png --size 600 600 \
    --voxelLoc $IMID_F $JMID_F $K \
  fmri_moco_mean.nii.gz \
    --interpolation linear \
  fmri_moco_WM.nii.gz \
    --lut melodic-classes \
    --overlayType label \
    --outline --outlineWidth 3 \
  fmri_moco_CSF.nii.gz \
    --lut harvard-oxford-subcortical \
    --overlayType label \
    --outline --outlineWidth 3
done


# Check template registration: subject segmentation overlaid on PAM50 T2s template
# GM/cord on template space image in mffe space
for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
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
    --zzoom 2300 \
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
      --zzoom 2300 \
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


# Same but for level-based ROIs
for v in 0 1 2 3; do
  for K in $(seq -w 0 $KMAX) ; do
    ${FSLEYES} render \
      --scene ortho \
      --hideCursor --hidex --hidey \
      --zzoom 2300 \
      --outfile connectivity_r_roi${v}_level_slice${K}.png --size 600 600 \
      --voxelLoc $IMID $JMID $K \
    mffe1.nii.gz \
    connectivity_r_level_mffespace.nii.gz \
      --volume $v \
      --useNegativeCmap \
      --cmap red-yellow --negativeCmap blue-lightblue \
      --displayRange 0.4 1.0 \
    mffe1_gmseg.nii.gz \
      --overlayType label \
      --outline --outlineWidth 2
  done
done


