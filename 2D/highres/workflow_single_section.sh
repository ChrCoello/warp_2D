#!/bin/bash
#

# Input arguments
work_dir=/data/warp/2D/highres/

tif_orig_size=$1
tif_res=$2
tif_dwn=$3

### Separate filename and extension
tif_orig_size_ext="${tif_orig_size##*.}"
tif_orig_size_fn="${tif_orig_size%.*}"

echo -e "\n"
echo -e "Input filename  :" ${tif_orig_size_fn}
echo -e "Input extension :" ${tif_orig_size_ext}
echo -e "Input resolution:" ${tif_res} "pixels per centimeter"

### Change resolution in tiff file
tif_res_fn=${tif_orig_size_fn}_meta.${tif_orig_size_ext}
#echo -e "\nMetadata before"
#identify -verbose ${tif_orig_size} | grep -E '(Resolution|Units|Print size|Geometry)'
#convert ${tif_orig_size} -units PixelsPerCentimeter ${tif_res_fn}
#convert ${tif_res_fn} -density ${tif_res}x${tif_res} ${tif_res_fn}
#echo -e "\nMetadata after\n"
#identify -verbose ${tif_res_fn} | grep -E '(Resolution|Units|Print size|Geometry)'

### Resize the experimental data
new_res=$((${tif_res} / ${tif_dwn}))
tif_dwn_fn=${tif_orig_size_fn}_resize.${tif_orig_size_ext}
#
#echo -e "\nDownsampling" ${tif_dwn} " times"
#convert ${tif_res_fn} -resample ${new_res}x${new_res} ${tif_dwn_fn}
#echo -e "\nMetadata after resizing"
#identify -verbose ${tif_dwn_fn} | grep -E '(Resolution|Units|Print size|Geometry)'

### Resize (i.e upsample) the MRI to the same size as the experimental data
tif_mri_fn=${tif_orig_size_fn}_MRI_m.png
tif_mri_res_fn=${tif_orig_size_fn}_MRI_m_resize.png

new_width=$(convert ${tif_dwn_fn} -ping -format "%w" info:)
new_height=$(convert ${tif_dwn_fn} -ping -format "%h" info:)
echo -e "Resizing MRI file:" ${tif_mri_fn} "to" ${new_width}"x"${new_height}
convert ${tif_mri_fn} -resize ${new_width}"x"${new_height}! -interpolate bilinear ${tif_mri_res_fn}

### Resize (i.e upsample) the Atlas to the same size as the resized experimental data
tif_atl_fn=${tif_orig_size_fn}_Segmentation_m.png
tif_atl_res_fn=${tif_orig_size_fn}_Segmentation_m_resize.png
echo -e "Resizing MRI file:" ${tif_atl_fn} "to" ${new_width}"x"${new_height}
convert ${tif_atl_fn} -resize ${new_width}"x"${new_height}! -interpolate nearest-neighbor ${tif_atl_res_fn}

### Tiff/png to Nifti, the resolution is preserved by ImageMath
echo -e "\nConverting to Nifti"
nii_tif=${tif_orig_size_fn}_resize.nii
ImageMath 2 ${nii_tif} Byte ${tif_dwn_fn}

nii_mri=${tif_orig_size_fn}_MRI_m_resize.nii
ImageMath 2 ${nii_mri} Byte ${tif_mri_res_fn}
c3d ${nii_tif} ${nii_mri} -copy-transform -o ${nii_mri} 
c3d ${nii_mri} -type ushort -o ${nii_mri}  

nii_atl=${tif_orig_size_fn}_Segmentation_m_resize.nii
ImageMath 2 ${nii_atl} Byte ${tif_atl_res_fn}
c3d ${nii_tif} ${nii_atl} -copy-transform -o ${nii_atl} 
c3d ${nii_atl} -type ushort -o ${nii_atl} 

### Draw landmarks manually
nii_mri_lm=${tif_orig_size_fn}_MRI_m_resize_landmarks.nii
nii_tif_lm=${tif_orig_size_fn}_resize_landmarks.nii

### Registration
echo -e "\nRegistration"
ants_trans=${tif_orig_size_fn}_transf
./runElastic.sh ${ants_trans} ${nii_tif} ${nii_mri} ${nii_tif_lm} ${nii_mri_lm}
echo -e "\nRegistration done with success"

### Apply transformation
echo -e "\nApply transformation"
aff_transf=${ants_trans}0GenericAffine.mat
nl_transf=${ants_trans}1Warp.nii.gz

./runApplyTransform.sh ${aff_transf} ${nl_transf} ${nii_tif} ${nii_atl} ${tif_orig_size_fn}_Segmentation_m_resize_warp


### Resize (i.e upsample) the Atlas to the same size as the experimental data
tif_atl_ori_fn=${tif_orig_size_fn}_Segmentation_m_original.png
ori_width=$(convert ${tif_res_fn} -ping -format "%w" info:)
ori_height=$(convert ${tif_res_fn} -ping -format "%h" info:)
echo -e "Resizing MRI file:" ${tif_atl_fn} "to" ${new_width}"x"${new_height}
convert ${tif_atl_fn} -resize ${new_width}"x"${new_height}! -interpolate nearest-neighbor ${tif_atl_ori_fn}

### Convert nifti
nii_atl_ori=${tif_orig_size_fn}_Segmentation_m_original.nii
ImageMath 2 ${nii_atl_ori} Byte ${tif_atl_ori_fn}

### Apply transformation high res
echo -e "\nApply transformation"
aff_transf=${ants_trans}0GenericAffine.mat
nl_transf=${ants_trans}1Warp.nii.gz

./runApplyTransform.sh ${aff_transf} ${nl_transf} ${nii_tif} ${nii_atl_ori} ${tif_orig_size_fn}_Segmentation_m_original_warp
