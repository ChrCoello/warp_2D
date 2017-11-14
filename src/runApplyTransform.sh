#!/bin/bash
#
disp=0

comp_transf=$1
target=$2
moving=$3
output=$4
disp=$5

dim=2

### Apply transform #
antsApplyTransforms -v -d $dim \
	-i ${moving} -r ${target} \
	-t ${comp_transf} \
	-o ${output}.nii.gz

### Convert the warped output to PNG
ImageMath 2 ${output}.png Byte ${output}.nii.gz

### Change the warp color to green
convert ${output}.png -background black -channel green -combine ${output}_green.png
### Blend with target
target_fn="${target%.*}"
composite -blend 50 -gravity South ${output}_green.png ${target_fn}.tif ${output}_blend.png
### Display
if [ ${disp} -eq 1 ]
then
display ${output}_blend.png &
fi


### Do the same for the moving
moving_fn="${moving%.*}"
convert ${moving_fn}.png -background black -channel green -combine ${moving_fn}_green.png
composite -blend 50 -gravity South ${moving_fn}_green.png ${target_fn}.tif ${moving_fn}_blend.png
if [ ${disp} -eq 1 ]
then
display ${moving_fn}_blend.png &
fi
