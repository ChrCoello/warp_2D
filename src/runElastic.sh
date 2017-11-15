#!/bin/bash

### Init cores
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

### Input script
output=$1
target=$2
moving=$3
target_lm=$4
moving_lm=$5
weigth_landmarks=$6

dim=2
MESH_BSPLINE_REDUCTION=20

### Getting the mesh
width=$(c3d ${target} -info-full | grep -oP ' dim\[1\] = \s*\K\d+')
height=$(c3d ${target} -info-full | grep -oP ' dim\[2\] = \s*\K\d+')
mesh_bspline_width=$((${width}/${MESH_BSPLINE_REDUCTION}))
mesh_bspline_height=$((${height}/${MESH_BSPLINE_REDUCTION}))
echo -e "\n BSpline mesh points (wxh):" ${mesh_bspline_width}"x"${mesh_bspline_height}


### Register
if [ ! -f "${moving_lm}" ] || [ ! -f "${target_lm}" ]
then
  antsRegistration -d $dim \
        	-m cc[${target},${moving},1,8] \
        	-t affine[0.10] \
        	-c [500,1.e-7,20] \
        	-s 4vox \
        	-f 4 \
  	      -m cc[${target},${moving},1,8] \
        	-t BSplineSyN[0.10,${mesh_bspline_width}"x"${mesh_bspline_height},0,3] \
        	-c [200x100x50,1.e-7,5] \
        	-s 4x2x1vox \
  	      -f 4x2x1 \
          --write-composite-transform \
          --print-similarity-measure-interval \
        	-o ${output}
else
  antsRegistration -d $dim \
        	-m cc[${target},${moving},1-${weigth_landmarks},8] \
  	      -m pse[${target_lm},${moving_lm},${weigth_landmarks},1,0,1,20] \
        	-t affine[0.10] \
        	-c [500,1.e-7,20] \
        	-s 4vox \
        	-f 4 \
  	      -m cc[${target},${moving},1-${weigth_landmarks},8] \
  	      -m pse[${target_lm},${moving_lm},${weigth_landmarks},1,0,1,20] \
        	-t BSplineSyN[0.10,${mesh_bspline_width}"x"${mesh_bspline_height},0,3] \
        	-c [200x100x50,1.e-7,5] \
        	-s 4x2x1vox \
  	      -f 4x2x1 \
          --write-composite-transform \
          --print-similarity-measure-interval \
        	-o ${output}
fi
