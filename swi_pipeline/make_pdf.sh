#!/bin/bash
#
# Make useful QA outputs with fsleyes
# https://users.fmrib.ox.ac.uk/~paulmc/fsleyes/userdoc/latest/command_line.html

# Location of fsleyes
FSLEYES=/opt/sct/python/envs/venv_sct/bin/fsleyes


# mffe geom slices of swi after proc with mffe cord overlaid
# pam50 filtswi
# pam50 5 and 9 mips


# Get voxel dims
IDIM=$(get_ijk.py i mffe_mffe.nii.gz)
let "IMID = $IDIM / 2"
JDIM=$(get_ijk.py j mffe_mffe.nii.gz)
let "JMID = $JDIM / 2"
KDIM=$(get_ijk.py k mffe_mffe.nii.gz)
let "KMAX = $KDIM - 1"
KSQRT=$(get_ijk.py s mffe_mffe.nii.gz)




#xvfb-run --server-num=$(($$ + 99)) --server-args='-screen 0 1600x1200x24 -ac +extension GLX' \


# mffe geom sag swi beside mffe
${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidey --hidez \
  --outfile mffe_swimag.png --size 600 600 \
  mffe_mffe.nii.gz \
  mffe_swimag.nii.gz

${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidey --hidez \
  --outfile mffe_mffe.png --size 600 600 \
  mffe_mffe.nii.gz
  
# Same in PAM50 space
${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidey --hidez \
  --outfile pam50_swimag.png --size 600 600 \
  PAM50_mffe.nii.gz \
  PAM50_swimag.nii.gz

${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidey --hidez \
  --outfile pam50_mffe.png --size 600 600 \
  PAM50_mffe.nii.gz


# PAM50 geom slices of swi before proc with mffe cord overlaid
for K in $(seq -w 0 $KMAX) ; do
  xvfb-run --server-num=$(($$ + 99)) --server-args='-screen 0 1600x1200x24 -ac +extension GLX' \
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
    --outfile before_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  mffe_swimag.nii.gz \
  mffe_cord.nii.gz \
    --lut melodic-classes \
    --overlayType label \
    --outline --outlineWidth 3
done


# Same after proc
for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
    --outfile after_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  mffe_filtswi.nii.gz \
  mffe_cord.nii.gz \
    --lut melodic-classes \
    --overlayType label \
    --outline --outlineWidth 3
done


# Same for mips
for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
    --outfile mip11_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  mffe_mip11_filtswi.nii.gz \
  mffe_cord.nii.gz \
    --lut melodic-classes \
    --overlayType label \
    --outline --outlineWidth 3
done

for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
    --outfile mip21_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  mffe_mip21_filtswi.nii.gz \
  mffe_cord.nii.gz \
    --lut melodic-classes \
    --overlayType label \
    --outline --outlineWidth 3
done

