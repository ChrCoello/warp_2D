#!/bin/bash

### Init cores
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

### Init
weigth_landmarks=0
weight_intensity=1

### Input script
output=$1
target=$2
moving=$3
target_lm=$4
moving_lm=$5
if [ $# -gt 5 ] ; then
weight_landmarks=$(echo "scale=4;$6"|bc)
weight_intensity=$(echo "scale=4;1-${weight_landmarks}"|bc)
fi


echo -e "\nWeight landmarks similarity metric:" ${weight_landmarks}
echo -e "Weight intensity similarity metric:" ${weight_intensity}

dim=2
MESH_BSPLINE_REDUCTION=10

### Getting the mesh
width=$(c3d ${target} -info-full | grep -oP ' dim\[1\] = \s*\K\d+')
height=$(c3d ${target} -info-full | grep -oP ' dim\[2\] = \s*\K\d+')
mesh_bspline_width=$((${width}/${MESH_BSPLINE_REDUCTION}))
mesh_bspline_height=$((${height}/${MESH_BSPLINE_REDUCTION}))

echo -e "BSpline mesh points (wxh):" ${mesh_bspline_width}"x"${mesh_bspline_height}

### Register
if [ ! -f "${moving_lm}" ] || [ ! -f "${target_lm}" ]
then
  echo -e "\nRunning registration without landmarks"
  antsRegistration -d $dim \
   -m mattes[${target},${moving},1,8] \
   -t affine[0.10] \
   -c [479,1e-7,11] \
   -s 4vox \
   -f 4 \
   -m cc[${target},${moving},1,8] \
   -t BSplineSyN[0.10,${mesh_bspline_width}"x"${mesh_bspline_height},0,3] \
   -c [61x61x61,1e-7,11] \
   -s 4x2x1vox \
   -f 4x2x1 \
   --write-composite-transform \
   -o ${output}
else
  echo -e "\nRunning registration with landmarks"
  echo -e "["${target}","${moving}","${weight_intensity}",8]"
  antsRegistration -v -d $dim \
   -m mattes[${target},${moving},${weight_intensity},8] \
   -m pse[${target_lm},${moving_lm},${weight_landmarks}] \
   -t affine[0.10] \
   -c [479,1e-7,11] \
   -s 4vox \
   -f 4 \
   -m cc[${target},${moving},${weight_intensity},8] \
   -m pse[${target_lm},${moving_lm},${weight_landmarks}] \
   -t BSplineSyN[0.10,${mesh_bspline_width}"x"${mesh_bspline_height},0,3] \
   -c [61x61x61,1e-7,11] \
   -s 4x2x1vox \
   -f 4x2x1 \
   --write-composite-transform \
   -o ${output}
fi
