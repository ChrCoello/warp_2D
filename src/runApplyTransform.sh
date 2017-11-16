#!/bin/bash
#

comp_transf=$1
target=$2
moving=$3
output=$4


dim=2

### Apply transform #
antsApplyTransforms -d $dim \
	-i ${moving} -r ${target} \
	-t ${comp_transf} \
	-o ${output}.nii.gz

### Convert the warped output to PNG
ImageMath 2 ${output}.png Byte ${output}.nii.gz
