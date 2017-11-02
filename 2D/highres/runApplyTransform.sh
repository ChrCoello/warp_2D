#!/bin/bash
#

aff_transf=$1
nl_transf=$2
target=$3
moving=$4
output=$5

dim=2

### Apply transform
antsApplyTransforms -v -d $dim \
	-i ${moving} -r ${target} \
	-t ${aff_transf} \
	-t ${nl_transf}  \
	-o ${output}.nii.gz

ImageMath 2 ${output}.png Byte ${output}.nii.gz

#convert moving_warp_land0pix10.png -background black -channel green -combine moving_warp_land0pix10_green.png
#composite -blend 50 -gravity South moving_warp_land0pix10_green.png target.png land_int_blend_001.png






