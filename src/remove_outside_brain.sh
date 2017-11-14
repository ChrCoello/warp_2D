#!/bin/bash
#

mri=$1
atl=$2
mri_output=$3
### Separate filename and extension for mri
mri_ext="${mri##*.}"
mri_fn="${mri%.*}"
### Separate filename and extension for atlas
atl_ext="${atl##*.}"
atl_fn="${atl%.*}"

convert ${atl} -threshold 0 ${atl_fn}_bin.${atl_ext}
convert ${atl_fn}_bin.${atl_ext} -morphology Open Disk:14.14 ${atl_fn}_bin_open.${atl_ext}
convert ${atl_fn}_bin_open.${atl_ext} -morphology Dilate Disk:3.4 ${atl_fn}_bin_open.${atl_ext}
composite -blend 50 -gravity South ${atl_fn}_bin_open.${atl_ext} ${atl} ${atl_fn}_blend.${atl_ext} 
display ${atl_fn}_blend.${atl_ext} &

c3d ${mri} ${atl_fn}_bin_open.${atl_ext} -multiply -o ${mri_fn}_masked.nii
ImageMath 2 ${mri_output} Byte ${mri_fn}_masked.nii
display ${mri_output} &

