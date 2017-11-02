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
echo -e "Input resolution:" ${tif_res} " pixels per centimeters"

### Embed resolution in tiff
tiff_res_fn=${tif_orig_size_fn}_res.${tif_orig_size_ext}
#echo -e "\nMetadata before"
#identify -verbose ${tif_orig_size} | grep -E '(Resolution|Units|Print size|Geometry)'
#convert ${tif_orig_size} -units PixelsPerCentimeter ${tiff_res_fn}
#convert ${tiff_res_fn} -density ${tif_res}x${tif_res} ${tiff_res_fn}
#echo -e "\nMetadata after\n"
#identify -verbose ${tiff_res_fn} | grep -E '(Resolution|Units|Print size|Geometry)'

### Resize the experimental data
new_res=$((${tif_res} / ${tif_dwn}))
tiff_dwn_fn=${tif_orig_size_fn}_res10.${tif_orig_size_ext}
#
#echo -e "\nDownsampling" ${tif_dwn} " times"
#convert ${tiff_res_fn} -resample ${new_res}x${new_res} ${tiff_dwn_fn}
#echo -e "\nMetadata after resizing"
#identify -verbose ${tiff_dwn_fn} | grep -E '(Resolution|Units|Print size|Geometry)'

### Resize (i.e upsample) the MRI to the same size as the experimental data
tif_mri_fn=${tif_orig_size_fn}_MRI_m.png
tif_mri_res_fn=${tif_orig_size_fn}_MRI_m_resize.png

new_width=$(convert ${tiff_dwn_fn} -ping -format "%w" info:)
new_height=$(convert ${tiff_dwn_fn} -ping -format "%h" info:)
echo -e "Resizing MRI file:" ${tif_mri_fn} "to" ${new_width}"x"${new_height}
convert ${tif_mri_fn} -resize ${new_width}"x"${new_height} -interpolate bilinear ${tif_mri_res_fn}

### Tiff/png to Nifti




# Initialisation
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
dim=2

