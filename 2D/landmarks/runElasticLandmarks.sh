#!/bin/bash
#
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
dim=2

# Only intensity
antsRegistration -v -d $dim -r [ target.png , moving.png ,1] \
	-m pse[ surfaceTarget.nii.gz , surfaceMoving.nii.gz, 0,1,0,1,20] \
      	-m mattes[ target.png , moving.png, 1 , 32, regular,0.1 ] \
      	-t affine[ 0.1 ] \
      	-c [500,1.e-7,20] \
      	-s 4vox \
      	-f 4 -l 1 \
      	-m pse[surfaceTarget.nii.gz , surfaceMoving.nii.gz, 0,1,0,1,20] \
	-m cc[target.png , moving.png, 1, 4] \
      	-t BSplineSyN[ .15, 8, 0.5 ] \
      	-c [50,1.e-7,5 ] \
      	-s 4vox \
      	-f 4 -u 1 -z 1 \
      	-o moving2target_land0pix10

# Landmarks 0.2 and Intensity 0.8
antsRegistration -v -d $dim -r [ target.png , moving.png ,1] \
	-m pse[ surfaceTarget.nii.gz , surfaceMoving.nii.gz, 0.2,1,0,1,20] \
      	-m mattes[ target.png , moving.png, 0.8 , 32, regular,0.1 ] \
      	-t affine[ 0.1 ] \
      	-c [500,1.e-7,20] \
      	-s 4vox \
      	-f 4 -l 1 \
      	-m pse[surfaceTarget.nii.gz , surfaceMoving.nii.gz, 0.2,1,0,1,20] \
	-m cc[target.png , moving.png, 0.8, 4] \
      	-t BSplineSyN[ .15, 8, 0.5 ] \
      	-c [50,1.e-7,5 ] \
      	-s 4vox \
      	-f 4 -u 1 -z 1 \
      	-o moving2target_land2pix8

# Landmarks 0.5 and Intensity 0.5
antsRegistration -v -d $dim -r [ target.png , moving.png ,1] \
	-m pse[ surfaceTarget.nii.gz , surfaceMoving.nii.gz, 0.5,1,0,1,20] \
      	-m mattes[ target.png , moving.png, 0.5 , 32, regular,0.1 ] \
      	-t affine[ 0.1 ] \
      	-c [500,1.e-7,20] \
      	-s 4vox \
      	-f 4 -l 1 \
      	-m pse[surfaceTarget.nii.gz , surfaceMoving.nii.gz, 0.5,1,0,1,20] \
	-m cc[target.png , moving.png, 0.5, 4] \
      	-t BSplineSyN[ .15, 8, 0.5 ] \
      	-c [50,1.e-7,5 ] \
      	-s 4vox \
      	-f 4 -u 1 -z 1 \
      	-o moving2target_land5pix5

# Landmarks 0.8 and Intensity 0.2
antsRegistration -v -d $dim -r [ target.png , moving.png ,1] \
	-m pse[ surfaceTarget.nii.gz , surfaceMoving.nii.gz, 0.8,1,0,1,20] \
      	-m mattes[ target.png , moving.png, 0.2 , 32, regular,0.1 ] \
      	-t affine[ 0.1 ] \
      	-c [500,1.e-7,20] \
      	-s 4vox \
      	-f 4 -l 1 \
      	-m pse[surfaceTarget.nii.gz , surfaceMoving.nii.gz, 0.8,1,0,1,20] \
	-m cc[target.png , moving.png, 0.2, 4] \
      	-t BSplineSyN[ .15, 8, 0.5 ] \
      	-c [50,1.e-7,5 ] \
      	-s 4vox \
      	-f 4 -u 1 -z 1 \
      	-o moving2target_land8pix2


# Only landmarks
antsRegistration -v -d $dim -r [ target.png , moving.png ,1] \
	-m pse[ surfaceTarget.nii.gz , surfaceMoving.nii.gz, 1,1,0,1,20] \
      	-m mattes[ target.png , moving.png, 0 , 32, regular,0.1 ] \
      	-t affine[ 0.1 ] \
      	-c [500,1.e-7,20] \
      	-s 4vox \
      	-f 4 -l 1 \
      	-m pse[surfaceTarget.nii.gz , surfaceMoving.nii.gz, 1,1,0,1,20] \
	-m cc[target.png , moving.png, 0, 4] \
      	-t BSplineSyN[ .15, 8, 0.5 ] \
      	-c [50,1.e-7,5 ] \
      	-s 4vox \
      	-f 4 -u 1 -z 1 \
      	-o moving2target_land10pix0
