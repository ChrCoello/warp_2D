#!/bin/bash
#
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
dim=2


# Only intensity

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land0pix100GenericAffine.mat \
	-o moving_affine_land0pix10.nii.gz
ImageMath 2 moving_affine_land0pix10.png Byte moving_affine_land0pix10.nii.gz

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land0pix100GenericAffine.mat \
	-t moving2target_land0pix101Warp.nii.gz \
	-o moving_warp_land0pix10.nii.gz
ImageMath 2 moving_warp_land0pix10.png Byte moving_warp_land0pix10.nii.gz

convert moving_warp_land0pix10.png -background black -channel green -combine moving_warp_land0pix10_green.png
composite -blend 50 -gravity South moving_warp_land0pix10_green.png target.png land_int_blend_001.png


# Landmarks 0.2 and Intensity 0.8

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land2pix80GenericAffine.mat \
	-o moving_affine_land2pix8.nii.gz
ImageMath 2 moving_affine_land2pix8.png Byte moving_affine_land2pix8.nii.gz

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land2pix80GenericAffine.mat \
	-t moving2target_land2pix81Warp.nii.gz \
	-o moving_warp_land2pix8.nii.gz
ImageMath 2 moving_warp_land2pix8.png Byte moving_warp_land2pix8.nii.gz

convert moving_warp_land2pix8.png -background black -channel green -combine moving_warp_land2pix8_green.png
composite -blend 50 -gravity South moving_warp_land2pix8_green.png target.png land_int_blend_002.png


# Landmarks 0.5 and Intensity 0.5

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land5pix50GenericAffine.mat \
	-o moving_affine_land5pix5.nii.gz
ImageMath 2 moving_affine_land5pix5.png Byte moving_affine_land5pix5.nii.gz

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land5pix50GenericAffine.mat \
	-t moving2target_land5pix51Warp.nii.gz \
	-o moving_warp_land5pix5.nii.gz
ImageMath 2 moving_warp_land5pix5.png Byte moving_warp_land5pix5.nii.gz

convert moving_warp_land5pix5.png -background black -channel green -combine moving_warp_land5pix5_green.png
composite -blend 50 -gravity South moving_warp_land5pix5_green.png target.png land_int_blend_003.png

# Landmarks 0.8 and Intensity 0.2

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land8pix20GenericAffine.mat \
	-o moving_affine_land8pix2.nii.gz
ImageMath 2 moving_affine_land8pix2.png Byte moving_affine_land8pix2.nii.gz

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land8pix20GenericAffine.mat \
	-t moving2target_land8pix21Warp.nii.gz \
	-o moving_warp_land8pix2.nii.gz
ImageMath 2 moving_warp_land8pix2.png Byte moving_warp_land8pix2.nii.gz

convert moving_warp_land8pix2.png -background black -channel green -combine moving_warp_land8pix2_green.png
composite -blend 50 -gravity South moving_warp_land8pix2_green.png target.png land_int_blend_004.png


# Only landmarks

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land10pix00GenericAffine.mat \
	-o moving_affine_land10pix0.nii.gz
ImageMath 2 moving_affine_land10pix0.png Byte moving_affine_land10pix0.nii.gz

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land10pix00GenericAffine.mat \
	-t moving2target_land10pix01Warp.nii.gz \
	-o moving_warp_land10pix0.nii.gz
ImageMath 2 moving_warp_land10pix0.png Byte moving_warp_land10pix0.nii.gz

convert moving_warp_land10pix0.png -background black -channel green -combine moving_warp_land10pix0_green.png
composite -blend 50 -gravity South moving_warp_land10pix0_green.png target.png land_int_blend_005.png

# original
convert moving.png -background black -channel green -combine moving_green.png
composite -blend 50 -gravity South moving_green.png target.png land_int_blend_000.png

# combine in a gif
convert -delay 50 -loop 0 land_int_blend_00*.png intensity2landmarks.gif






