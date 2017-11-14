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
if [ ! -f "${moving_lm}" ] || [ ! -f "${target_lm}" ]
then
antsRegistration -v -d $dim \
      	-m cc[${target},${moving},1,8] \
      	-t affine[0.10,1.e-7,20] \
      	-c [500] \
      	-s 4vox \
      	-f 4 \
	-m cc[${target},${moving},1,8] \
      	-t BSplineSyN[0.10,20x20,0,3] \
      	-c [50x50x50,1.e-7,5] \
      	-s 4x2x1vox \
	-f 4x2x1 \
      	-o ${output}
else
antsRegistration -v -d $dim \
      	-m cc[${target},${moving},0.5,8] \
	-m pse[${target_lm},${moving_lm},0.5,1,0,1,20] \
      	-t affine[0.10,1.e-7,20] \
      	-c [500] \
      	-s 4vox \
      	-f 4 \
	-m cc[${target},${moving},0.5,8] \
	-m pse[${target_lm},${moving_lm},0.5,1,0,1,20] \
      	-t BSplineSyN[0.10,20x20,0,3] \
      	-c [50x50x50,1.e-7,5] \
      	-s 4x2x1vox \
	-f 4x2x1 \
      	-o ${output}
fi	


