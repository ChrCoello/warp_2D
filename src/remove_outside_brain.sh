#!/bin/bash
#

disp=0

mri=$1
atl=$2
mri_output=$3
if [ $# -gt 3 ] ; then
disp=$4
fi
### Separate filename and extension for mri
mri_ext="${mri##*.}"
mri_fn="${mri%.*}"
### Separate filename and extension for atlas
atl_ext="${atl##*.}"
atl_fn="${atl%.*}"

convert ${atl} -threshold 0 ${atl_fn}_bin.${atl_ext}
#convert ${atl_fn}_bin.${atl_ext} -morphology Open Disk:14.14 ${atl_fn}_bin_open.${atl_ext}
convert ${atl_fn}_bin.${atl_ext} -morphology Dilate Disk:4.4 ${atl_fn}_bin.${atl_ext}
composite -blend 50 -gravity South ${atl_fn}_bin.${atl_ext} ${atl} ${atl_fn}_blend.${atl_ext}


c3d ${mri} ${atl_fn}_bin.${atl_ext} -multiply -o ${mri_fn}_masked.nii.gz
ImageMath 2 ${mri_output} Byte ${mri_fn}_masked.nii.gz

composite -blend 50 -gravity South ${atl_fn}_bin.${atl_ext} ${mri} ${mri_fn}_blend.${mri_ext}

### Display
if [ ${disp} -eq 1 ]
then
  convert ${mri} ${atl} ${mri_fn}_blend.${mri_ext} ${mri_output} +append ${mri_fn}_blend_composite.${mri_ext}
  display ${mri_fn}_blend_composite.${mri_ext} &
fi

### Clean
rm ${atl_fn}_bin.${atl_ext}
rm ${mri_fn}_masked.nii.gz
