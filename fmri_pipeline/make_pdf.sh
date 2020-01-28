#!/bin/bash
#
# Make useful QA outputs with fsleyes
# https://users.fmrib.ox.ac.uk/~paulmc/fsleyes/userdoc/latest/command_line.html

# Location of fsleyes
FSLEYES=/opt/sct/python/envs/venv_sct/bin/fsleyes

# Get mffe voxel dims
IDIM=$(get_ijk.py i mffe_mffe.nii.gz)
let "IMID = $IDIM / 2"
JDIM=$(get_ijk.py j mffe_mffe.nii.gz)
let "JMID = $JDIM / 2"
KDIM=$(get_ijk.py k mffe_mffe.nii.gz)
let "KMAX = $KDIM - 1"
KSQRT=$(get_ijk.py s mffe_mffe.nii.gz)

# fmri voxel dims
IDIM_F=$(get_ijk.py i fmri_moco_mean.nii.gz)
let "IMID_F = $IDIM_F / 2"
JDIM_F=$(get_ijk.py j fmri_moco_mean.nii.gz)
let "JMID_F = $JDIM_F / 2"
KDIM_F=$(get_ijk.py k fmri_moco_mean.nii.gz)
let "KMAX_F = $KDIM_F - 1"
KSQRT_F=$(get_ijk.py s fmri_moco_mean.nii.gz)


#xvfb-run --server-num=$(($$ + 99)) --server-args='-screen 0 1600x1200x24 -ac +extension GLX' \

# Level labels on t2sag and fmri
${FSLEYES} render \
    --scene ortho --displaySpace t2sag_t2sag.nii.gz  \
    --hideCursor --hidex --hidey --zzoom 1000 \
    --outfile t2sag_levels.png --size 600 800 \
  t2sag_t2sag.nii.gz \
  t2sag_cord_labeled.nii.gz \
    --lut random_big \
    --overlayType label \
    --outline --outlineWidth 3

${FSLEYES} render \
    --scene ortho --displaySpace t2sag_t2sag.nii.gz  \
    --hideCursor --hidex --hidey --zzoom 1000 \
    --outfile fmri_levels.png --size 600 800 \
  t2sag_t2sag.nii.gz \
  mffe_moco_mean.nii.gz \
  mffe_cord_labeled.nii.gz \
    --lut random_big \
    --overlayType label \
    --outline --outlineWidth 3


# Plot cor sections for fmri, mffe alignment
${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidex --hidez \
  --outfile registration_cor_mffe.png --size 600 600 \
  PAM50_mffe.nii.gz \
    --interpolation linear \
  PAM50_gm.nii.gz \
    --lut harvard-oxford-subcortical \
    --overlayType label \
    --outline --outlineWidth 2
		
${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidex --hidez \
  --outfile registration_cor_fmri.png --size 600 600 \
  PAM50_moco_mean.nii.gz \
    --interpolation linear \
  PAM50_gm.nii.gz \
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
  fmri_wm.nii.gz \
    --lut melodic-classes \
    --overlayType label \
    --outline --outlineWidth 3 \
  fmri_csf.nii.gz \
    --lut harvard-oxford-subcortical \
    --overlayType label \
    --outline --outlineWidth 3
done


# Check connectivity: Seed connectivity maps overlaid on subject MFFE
# Connectivity maps for each mffe slice
for roi in Rdorsal Rventral Ldorsal Lventral ; do
  for K in $(seq -w 0 $KMAX) ; do
    ${FSLEYES} render \
      --scene ortho \
      --hideCursor --hidex --hidey \
      --zzoom 2300 \
      --outfile R_${roi}_slice${K}.png --size 600 600 \
      --voxelLoc $IMID $JMID $K \
    mffe_mffe.nii.gz \
    mffe_R_${roi}_inslice.nii.gz \
      --useNegativeCmap \
      --cmap red-yellow --negativeCmap blue-lightblue \
      --displayRange 0.4 1.0 \
    mffe_gm.nii.gz \
      --overlayType label \
      --outline --outlineWidth 2
  done
done
