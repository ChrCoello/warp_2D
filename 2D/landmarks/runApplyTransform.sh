#!/bin/bash
#
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
dim=2
antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target0GenericAffine.mat \
	-o moving_affine_onlypixel.nii.gz

ImageMath 2 moving_affine_onlypixel.png Byte moving_affine_onlypixel.nii.gz

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target0GenericAffine.mat \
	-t moving2target1Warp.nii.gz \
	-o moving_warp_onlypixel.nii.gz

ImageMath 2 moving_warp_onlypixel.png Byte moving_warp_onlypixel.nii.gz

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_landmarks0GenericAffine.mat \
	-o moving_affine_onlylandmarks.nii.gz

ImageMath 2 moving_affine_onlylandmarks.png Byte moving_affine_onlylandmarks.nii.gz

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_landmarks0GenericAffine.mat \
	-t moving2target_landmarks1Warp.nii.gz \
	-o moving_warp_onlylandmarks.nii.gz

ImageMath 2 moving_warp_onlylandmarks.png Byte moving_warp_onlylandmarks.nii.gz

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land2pix80GenericAffine.mat \
	-o moving_affine_land2pix8.nii.gz

ImageMath 2 moving_affine_land2pix8.png Byte moving_affine_land2pix8.nii.gz

antsApplyTransforms -v -d $dim \
	-i moving.png -r target.png -n linear \
	-t moving2target_land2pix80GenericAffine.mat \
	-t moving2target_land2pix81Warp.nii.gz \
	-o moving_warp_onlylandmarks.nii.gz

ImageMath 2 moving_warp_land2pix8.png Byte moving_warp_land2pix8.nii.gz
