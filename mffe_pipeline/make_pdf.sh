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


#xvfb-run --server-num=$(($$ + 99)) --server-args='-screen 0 1600x1200x24 -ac +extension GLX' \

# Level labels on t2sag and mffe
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
    --outfile mffe_levels.png --size 600 800 \
  t2sag_t2sag.nii.gz \
  mffe_mffe.nii.gz \
  ipmffe_cord_labeled.nii.gz \
    --lut random_big \
    --overlayType label \
    --outline --outlineWidth 3


# Plot cor sections for mffe, template alignment
${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidex --hidez \
  --outfile registration_cor_template.png --size 600 600 \
  PAM50_template_t2s_cropped.nii.gz \
    --interpolation linear \
  PAM50_gm.nii.gz \
    --lut harvard-oxford-subcortical \
    --overlayType label \
    --outline --outlineWidth 2

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
  --outfile registration_cor_levels.png --size 600 600 \
  PAM50_mffe.nii.gz \
    --interpolation linear \
  PAM50_cord_labeled.nii.gz \
    --lut random_big \
    --overlayType label \
    --outline --outlineWidth 3 \
  PAM50_template_cord_labeled.nii.gz \
    --lut random_big \
    --overlayType label \
    --outline --outlineWidth 3


# Check template registration: subject segmentation overlaid on PAM50 T2s template
# GM/cord on template space image in mffe space
for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
    --outfile templateregistration_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  mffe_template_t2s.nii.gz \
    --interpolation linear \
  mffe_synt2.nii.gz \
    --lut melodic-classes \
    --overlayType label \
    --outline --outlineWidth 3 \
  mffe_csf.nii.gz \
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
  mffe_mffe.nii.gz \
    --interpolation linear \
  mffe_synt2.nii.gz \
    --lut melodic-classes \
    --overlayType label \
    --outline --outlineWidth 3 \
  mffe_csf.nii.gz \
    --lut harvard-oxford-subcortical \
    --overlayType label \
    --outline --outlineWidth 3
done
