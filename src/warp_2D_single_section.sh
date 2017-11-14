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

tif_res=$4
#tif_dwn=$5

### Parameters
work_width=1024
atlas_pixel_resolution=0.0390625 # mm
image_density=256 # pixels per cm

### Separate filename and extension for section
sec_ext="${sec##*.}"
sec_fn="${sec%.*}"
### Separate filename and extension for mri
mri_ext="${mri##*.}"
mri_fn="${mri%.*}"
### Separate filename and extension for atlas
atl_ext="${atl##*.}"
atl_fn="${atl%.*}"

echo -e "Input section filename:" ${sec_fn}
echo -e "Input MRI filename:" ${mri_fn}
echo -e "Input Atlas filename:" ${atl_fn}
echo -e "Atlas pixel resolution (mm):" ${atlas_pixel_resolution}
echo -e "Pixel density (pixels per cm):" ${image_density}

### Change resolution in tiff file
sec_meta=${sec_fn}_meta.${sec_ext}
#
sec_meta_ext="${sec_meta##*.}"
sec_meta_fn="${sec_meta%.*}"
#
#echo -e "\nMetadata of" ${sec_fn}":"
#identify -verbose ${sec} | grep -E '(Resolution|Units|Print size|Geometry)'
#convert ${sec} -strip ${sec_meta}
#echo -e "\nMetadata of" ${sec_meta} "after stripping the physical space metadata:"
#identify -verbose ${sec_meta} | grep -E '(Resolution|Units|Print size|Geometry)'
#
#
#
######
### Resize the sectionon
#
sec_dwn=${sec_fn}_resize.${sec_ext}
#
sec_dwn_ext="${sec_dwn##*.}"
sec_dwn_fn="${sec_dwn%.*}"
#
echo -e "\nResizing the section to ${work_width} width"
convert ${sec_meta} -resize ${work_width} -interpolate bilinear -gravity NorthWest ${sec_dwn}
echo -e "\nMetadata after downsampling"
identify -verbose ${sec_dwn} | grep -E '(Resolution|Units|Print size|Geometry)'

######
### Resize (i.e upsample) the MRI to the same size as the experimental data
#mri_width=$(convert ${mri} -ping -format "%w" info:)
#mri_height=$(convert ${mri} -ping -format "%h" info:)
mri_res=${mri_fn}_resize.${mri_ext}
# remove extra cranial stuff
echo -e "\nRemoving extra cranial objects in the MRI"
remove_outside_brain.sh ${mri} ${atl} ${mri_res}
echo -e "\nRemoving extra cranial objects in the MRI -- done"
#
mri_res_ext="${mri_res##*.}"
mri_res_fn="${mri_res%.*}"
#
sec_width=$(convert ${sec_dwn} -ping -format "%w" info:)
sec_height=$(convert ${sec_dwn} -ping -format "%h" info:)
echo -e "\nResizing MRI file:" ${mri_fn} "to" ${sec_width}"x"${sec_height}
convert ${mri_res} -resize ${sec_width}"x"${sec_height}! -interpolate bilinear -gravity NorthWest ${mri_res}

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
### Add spatial information
echo -e "\nAdding physical space information to the resized file"
convert ${sec_dwn} -units PixelsPerCentimeter ${sec_dwn}
convert ${sec_dwn} -density ${image_density}x${image_density} ${sec_dwn}
echo -e "\nMetadata of" ${sec_dwn} "after adding the physical space information:"
identify -verbose ${sec_dwn} | grep -E '(Resolution|Units|Print size|Geometry)'

######
### Tiff to Nifti, the resolution is preserved by ImageMath
echo -e "\nConverting to Nifti"
sec_dwn_nii=${sec_dwn_fn}.nii
ImageMath 2 ${sec_dwn_nii} Byte ${sec_dwn}
echo -e "\nSection nifti file" ${sec_dwn_nii} "info:"
c3d ${sec_dwn_nii} -info-full | grep -E '(Bounding Box|Voxel Spacing|Image Dimensions)'

######
### PNG to Nifti, we have to get the transform from somewhere else
mri_res_nii=${mri_res_fn}.nii
ImageMath 2 ${mri_res_nii} Byte ${mri_res}
# Copy header
c3d ${sec_dwn_nii} ${mri_res_nii} -copy-transform -o ${mri_res_nii}
# Change to short
c3d ${mri_res_nii} -type ushort -o ${mri_res_nii}
echo -e "\nMRI nifti file" ${mri_res_nii} "info:"
c3d ${mri_res_nii} -info-full | grep -E '(Bounding Box|Voxel Spacing|Image Dimensions)'

######
### PNG to Nifti, we have to get the transform from somewhere else
atl_res_nii=${atl_res_fn}.nii
ImageMath 2 ${atl_res_nii} Byte ${atl_res}
# Copy header
c3d ${sec_dwn_nii} ${atl_res_nii} -copy-transform -o ${atl_res_nii}
# Change to short
c3d ${atl_res_nii} -type ushort -o ${atl_res_nii}
echo -e "\nAtlas nifti file" ${atl_res_nii} "info:"
c3d ${atl_res_nii} -info-full | grep -E '(Bounding Box|Voxel Spacing|Image Dimensions)'

### Draw landmarks manually
mri_res_lm_nii=${mri_res_fn}_landmarks.nii
sec_dwn_lm_nii=${sec_dwn_fn}_landmarks.nii
#if [ ! -f "${mri_res_lm}" ]
#then
#	echo -e "\n"
#	echo -e "**********************************************************"
#	echo -e "*   Draw landmarks for" ${mri_res_nii} "using ITKSnap "
#	echo -e "**********************************************************"
#	echo -e "\n"
#	exit 3
#fi
#if [ ! -f "${sec_dwn_lm}" ]
#then
#	echo -e "\n"
#	echo -e "**********************************************************"
#	echo -e "*   Draw landmarks for" ${sec_dwn_nii} "using ITKSnap "
#	echo -e "**********************************************************"
#	echo -e "\n"
#	exit 3
#fi

### Registration
echo -e "\nRegistration"
ants_trans=${sec_fn}_transf
time runElastic.sh ${ants_trans} ${sec_dwn_nii} ${mri_res_nii} ${sec_dwn_lm_nii} ${mri_res_lm_nii}
echo -e "\nRegistration done with success"

### Apply transformation to the downsampled MRI
echo -e "\nApply transformation"
comp_transf=${ants_trans}Composite.h5
mri_res_warp_fn=${mri_res_fn}_warp
atl_res_warp_fn=${atl_res_fn}_warp
runApplyTransform.sh ${comp_transf} ${sec_dwn_nii} ${mri_res_nii} ${mri_res_warp_fn} 1
#./runApplyTransform.sh ${aff_transf} ${nl_transf} ${sec_dwn_nii} ${atl_res_nii} ${atl_res_warp_fn}



### Resize (i.e upsample) the MRI to the same size as the experimental data
mri_ori=${mri_fn}_original.${mri_ext}
#
mri_ori_ext="${mri_ori##*.}"
mri_ori_fn="${mri_ori%.*}"
#
ori_width=$(convert ${sec} -ping -format "%w" info:)
ori_height=$(convert ${sec} -ping -format "%h" info:)
echo -e "Resizing MRI file:" ${mri_fn} "to" ${ori_width}"x"${ori_height}
convert ${mri} -resize ${ori_width}"x"${ori_height}! -interpolate bilinear ${mri_ori}

######
### tiff to Nifti high res
echo -e "\nConverting to Nifti the high res section"
sec_meta_nii=${sec_meta_fn}.nii
ImageMath 2 ${sec_meta_nii} Byte ${sec_meta}
echo -e "\nHigh res section nifti file" ${sec_meta_nii} "info:"
c3d ${sec_meta_nii} -info-full | grep -E '(Bounding Box|Voxel Spacing|Image Dimensions)'

######
### PNG to Nifti, we have to get the transform from somewhere else
echo -e "\nConverting to Nifti the high res MRI"
mri_ori_nii=${mri_ori_fn}.nii
ImageMath 2 ${mri_ori_nii} Byte ${mri_ori}
# Copy header
c3d ${sec_meta_nii} ${mri_ori_nii} -copy-transform -o ${mri_ori_nii}
# Change to short
c3d ${mri_ori_nii} -type ushort -o ${mri_ori_nii}
echo -e "\nHigh res MRI nifti file" ${mri_ori_nii} "info:"
c3d ${mri_ori_nii} -info-full | grep -E '(Bounding Box|Voxel Spacing|Image Dimensions)'


### Apply transformation to the high res MRI
echo -e "\nApply transformation to high res"
aff_transf=${ants_trans}0GenericAffine.mat
nl_transf=${ants_trans}1Warp.nii.gz
mri_ori_warp_fn=${mri_ori_fn}_warp
atl_res_warp_fn=${atl_res_fn}_warp
runApplyTransform.sh ${comp_transf} ${sec_meta_nii} ${mri_ori_nii} ${mri_ori_warp_fn}
