#!/bin/bash
#
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
dim=2
antsRegistration -v -d $dim -r [ target.nii.gz , moving.nii.gz ,1] \
      -m mattes[ target.nii.gz , moving.nii.gz, 1 , 32, regular,0.1 ] \
      -t affine[ 0.1 ] \
      -c [500x500x50,1.e-8,20] \
      -s 4x2x1vox \
      -f 3x2x1 -l 1 \
      -m cc[ target.nii.gz , moving.nii.gz, 1 , 4 ] \
      -t BSplineSyN[ .15, 8, 0.5 ] \
      -c [ 50x50x50,0,5 ] \
      -s 1x0.5x0vox \
      -f 4x2x1 -l 1 -u 1 -z 1 \
      -o [moving,moving_diff.nii.gz,moving_inv.nii.gz]
