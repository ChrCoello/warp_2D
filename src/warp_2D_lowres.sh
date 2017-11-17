#!/bin/bash
#


echo -e "\n"
echo -e "*********************************************"
echo -e "**********        WARP 2D         ***********"
echo -e "*********************************************"
echo -e "\n"

if [ $# -lt 3 ] ; then
echo This script will allow you to register two 2D images like this
echo -e "\n"
echo $0 source.tif source_MRI.png source_Atlas.png
echo -e "\n"
echo Please enter at least these three arguments: source.tif,source_MRI.png and source_Atlas.png
echo -e "\n"
exit
fi
# Input arguments
sec=$1
mri=$2
atl=$3

### General parameters
DISPLAY_OUTPUT=1
WEIGHT_LANDMARKS=1

### Parameters
work_width=1024
atlas_pixel_resolution=0.0390625 # mm
image_density=$(echo "scale=7;10/$atlas_pixel_resolution"|bc) # pixels per cm


### Separate filename and extension for section
sec_ext="${sec##*.}"
sec_fn="${sec%.*}"
### Separate filename and extension for mri
mri_ext="${mri##*.}"
mri_fn="${mri%.*}"
### Separate filename and extension for atlas
atl_ext="${atl##*.}"
atl_fn="${atl%.*}"

echo -e "\n*********************************************"
echo -e "Input section filename:        "${sec_fn}
echo -e "Input MRI filename:            "${mri_fn}
echo -e "Input Atlas filename:          "${atl_fn}
echo -e "Atlas pixel resolution (mm):   "${atlas_pixel_resolution}
echo -e "Pixel density (pixels per cm): "${image_density}
echo -e "*********************************************\n"

### Change resolution in tiff file
sec_meta=${sec_fn}_meta.${sec_ext}
#
sec_meta_ext="${sec_meta##*.}"
sec_meta_fn="${sec_meta%.*}"
#
#echo -e "\nMetadata of" ${sec_fn}":"
#identify -verbose ${sec} | grep -E '(Resolution|Units|Print size|Geometry)'
echo -e "\nStriping physical space metadata of" ${sec_fn}
convert ${sec} -strip ${sec_meta}
#echo -e "\nMetadata of" ${sec_meta} "after stripping the physical space metadata:"
#identify -verbose ${sec_meta} | grep -E '(Resolution|Units|Print size|Geometry)'
#
#
#
######
### Resize the section
#
sec_dwn=${sec_fn}_resize.${sec_ext}
#
sec_dwn_ext="${sec_dwn##*.}"
sec_dwn_fn="${sec_dwn%.*}"
#
echo -e "\nResizing the original section to a width of ${work_width} pixels"
convert ${sec_meta} -resize ${work_width} -interpolate bilinear -gravity NorthWest ${sec_dwn}
echo -e "\nMetadata after resizing"
identify -verbose ${sec_dwn} | grep -E '(Resolution|Units|Print size|Geometry)'

######
# remove extra cranial stuff
mri_msk=${mri_fn}_msk.${mri_ext}
echo -e "\nRemoving extra cranial objects in the MRI"
remove_outside_brain.sh ${mri} ${atl} ${mri_msk} ${DISPLAY_OUTPUT}
echo -e "\nRemoving extra cranial objects in the MRI -- done"
#######
### Resize (i.e upsample) the MRI to the same size as the experimental data
mri_res=${mri_fn}_resize.${mri_ext}
#
mri_res_ext="${mri_res##*.}"
mri_res_fn="${mri_res%.*}"
#
sec_width=$(convert ${sec_dwn} -ping -format "%w" info:)
sec_height=$(convert ${sec_dwn} -ping -format "%h" info:)
echo -e "\nResizing MRI file:" ${mri_fn} "to" ${sec_width}"x"${sec_height}
convert ${mri_msk} -resize ${sec_width}"x"${sec_height}! -interpolate bilinear -gravity NorthWest ${mri_res}

######
### Add spatial information
echo -e "\nAdding physical space information to the resized file"
convert ${sec_dwn} -units PixelsPerCentimeter ${sec_dwn}
convert ${sec_dwn} -density ${image_density}x${image_density} ${sec_dwn}
echo -e "\nMetadata of" ${sec_dwn} "after adding the physical space information:"
identify -verbose ${sec_dwn} | grep -E '(Resolution|Units|Print size|Geometry)'

######
### Tiff to Nifti, the resolution is preserved by ImageMath
echo -e "\nConverting to Nifti"
sec_dwn_nii=${sec_dwn_fn}.nii.gz
ImageMath 2 ${sec_dwn_nii} Byte ${sec_dwn}
echo -e "\nSection nifti file" ${sec_dwn_nii} "info:"
c3d ${sec_dwn_nii} -info-full | grep -E '(Bounding Box|Voxel Spacing|Image Dimensions)'

######
### PNG to Nifti, we have to get the transform from somewhere else
mri_res_nii=${mri_res_fn}.nii.gz
ImageMath 2 ${mri_res_nii} Byte ${mri_res}
# Copy header
c3d ${sec_dwn_nii} ${mri_res_nii} -copy-transform -o ${mri_res_nii}
# Change to short
c3d ${mri_res_nii} -type ushort -o ${mri_res_nii}
echo -e "\nMRI nifti file" ${mri_res_nii} "info:"
c3d ${mri_res_nii} -info-full | grep -E '(Bounding Box|Voxel Spacing|Image Dimensions)'

### Draw landmarks manually
mri_res_lm_nii=${mri_res_fn}_landmarks.nii.gz
sec_dwn_lm_nii=${sec_dwn_fn}_landmarks.nii.gz

### Registration
echo -e "\nRegistration"
ants_trans=${sec_fn}_transf
time runElastic.sh ${ants_trans} ${sec_dwn_nii} ${mri_res_nii} ${sec_dwn_lm_nii} ${mri_res_lm_nii} ${WEIGHT_LANDMARKS}
echo -e "\nRegistration done with success"

### This part is only for validation of the regiostration process and achieves applies the transformation to the Atlas, both low res and high res
echo -e "**********************************************************"
echo -e "************ Working with the downsampled atlas **********"
echo -e "**********************************************************"
######
### Resize (i.e upsample) the Atlas to the same size as the resized experimental data
atl_res=${atl_fn}_resize.${atl_ext}
#
atl_res_ext="${atl_res##*.}"
atl_res_fn="${atl_res%.*}"
#
echo -e "Resizing Atlas file:" ${atl_fn} "to" ${sec_width}"x"${sec_height}
convert ${atl} -resize ${sec_width}"x"${sec_height}! -interpolate nearest-neighbor -gravity NorthWest ${atl_res}
######
### PNG to Nifti, we have to get the transform from somewhere else
# split channels
convert ${atl_res} -separate ${atl_res_fn}_splitRGB%d.${atl_res_ext}

atl_res_nii_0=${atl_res_fn}_splitRGB0.nii.gz
atl_res_nii_1=${atl_res_fn}_splitRGB1.nii.gz
atl_res_nii_2=${atl_res_fn}_splitRGB2.nii.gz
ImageMath 2 ${atl_res_nii_0} Byte ${atl_res_fn}_splitRGB0.${atl_res_ext}
ImageMath 2 ${atl_res_nii_1} Byte ${atl_res_fn}_splitRGB1.${atl_res_ext}
ImageMath 2 ${atl_res_nii_2} Byte ${atl_res_fn}_splitRGB2.${atl_res_ext}
# Copy header
c3d ${sec_dwn_nii} ${atl_res_nii_0} -copy-transform -o ${atl_res_nii_0}
c3d ${sec_dwn_nii} ${atl_res_nii_1} -copy-transform -o ${atl_res_nii_1}
c3d ${sec_dwn_nii} ${atl_res_nii_2} -copy-transform -o ${atl_res_nii_2}
# Change to short
c3d ${atl_res_nii_0} -type ushort -o ${atl_res_nii_0}
c3d ${atl_res_nii_1} -type ushort -o ${atl_res_nii_1}
c3d ${atl_res_nii_2} -type ushort -o ${atl_res_nii_2}
echo -e "\nAtlas nifti file" ${atl_res_nii_0} "info:"
c3d ${atl_res_nii_0} -info-full | grep -E '(Bounding Box|Voxel Spacing|Image Dimensions)'

### Apply transformation to the downsampled Atlas
echo -e "\nApply transformation to atlas"
comp_transf=${ants_trans}Composite.h5
#mri_res_warp_fn=${mri_res_fn}_warp
atl_res_warp_fn=${atl_res_fn}_warp
atl_res_warp_fn_0=${atl_res_fn}_splitRGB0_warp
atl_res_warp_fn_1=${atl_res_fn}_splitRGB1_warp
atl_res_warp_fn_2=${atl_res_fn}_splitRGB2_warp
# apply transforms to red green and blue
echo -e "\nApply transformation" ${comp_transf} "to" ${atl_res_nii_0}
time runApplyTransform.sh ${comp_transf} ${sec_dwn_nii} ${atl_res_nii_0} ${atl_res_warp_fn_0}
echo -e "Apply transformation" ${comp_transf} "to" ${atl_res_nii_1}
time runApplyTransform.sh ${comp_transf} ${sec_dwn_nii} ${atl_res_nii_1} ${atl_res_warp_fn_1}
echo -e "Apply transformation" ${comp_transf} "to" ${atl_res_nii_2}
time runApplyTransform.sh ${comp_transf} ${sec_dwn_nii} ${atl_res_nii_2} ${atl_res_warp_fn_2}

# regroup channels
echo -e "\nRegrouping the RGB channels into a warped low res Atlas"
convert ${atl_res_warp_fn_0}.png ${atl_res_warp_fn_1}.png ${atl_res_warp_fn_2}.png -set colorspace RGB -combine -set colorspace sRGB ${atl_res_warp_fn}.png
### Blend with target
composite -blend 50 -gravity South ${atl_res_warp_fn}.png ${sec_dwn} ${sec_dwn_fn}_warp_blend.png
composite -blend 50 -gravity South ${atl_res} ${sec_dwn} ${sec_dwn_fn}_blend.png
### Display
if [ ${DISPLAY_OUTPUT} -eq 1 ]
then
display ${sec_dwn_fn}_blend.png &
display ${sec_dwn_fn}_warp_blend.png &
fi

### Clean
rm *split*.*
