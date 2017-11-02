#!/bin/bash

### Init cores
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

### Input script
output=$1
target=$2
moving=$3
target_lm=$4
moving_lm=$5

dim=2

### Register
antsRegistration -v -d $dim \
	-m pse[${target_lm},${moving_lm}, 1,8] \
      	-m mattes[${target},${moving}, 0,8] \
      	-t affine[0.10] \
      	-c [500] \
      	-s 4vox \
      	-f 4 \
	-m pse[${target_lm},${moving_lm}, 1,8] \
	-m mattes[${target},${moving},0,8] \
      	-t BSplineSyN[0.15,5x5,0,3] \
      	-c [50] \
      	-s 4vox \
	-f 4 \
      	-o ${output}
