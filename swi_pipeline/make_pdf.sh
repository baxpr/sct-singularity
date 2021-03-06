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
IMID=$(get_com.py i swi_cord.nii.gz)
JMID=$(get_com.py j swi_cord.nii.gz)
KDIM=$(get_ijk.py k swi_swimag.nii.gz)
let "KMAX = $KDIM - 1"
KSQRT=$(get_ijk.py s swi_swimag.nii.gz)




#xvfb-run --server-num=$(($$ + 99)) --server-args='-screen 0 1600x1200x24 -ac +extension GLX' \


# mffe geom sag swi beside mffe
${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidey --hidez \
  --xzoom 1200 \
  --outfile mffe_swimag.png --size 600 600 \
  mffe_mffe.nii.gz \
  mffe_swimag.nii.gz

${FSLEYES} render \
  --scene ortho \
  --hideCursor --hidey --hidez \
  --xzoom 1200 \
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


# slices of swi before proc with cord overlaid
for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
    --outfile before_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  swi_swimag.nii.gz \
  swi_cord.nii.gz \
    --lut melodic-classes \
    --overlayType label \
    --outline --outlineWidth 3
done


# PAM50 geom slices of mffe with cord outline and invmaskph
for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
    --outfile invmaskph_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  swi_mffe.nii.gz \
  swi_invmaskph.nii.gz \
    --cmap red-yellow \
    --displayRange 0.5 1.0 \
  swi_cord.nii.gz \
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
  swi_filtswi.nii.gz
done


# Same for mips
for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
    --outfile mip11_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  swi_mip11_filtswi.nii.gz
done

for K in $(seq -w 0 $KMAX) ; do
  ${FSLEYES} render \
    --scene ortho \
    --hideCursor --hidex --hidey \
    --zzoom 2300 \
    --outfile mip21_slice${K}.png --size 600 600 \
    --voxelLoc $IMID $JMID $K \
  swi_mip21_filtswi.nii.gz
done

