## Example of pair of slices after anchoring
Target slice: this is the histology slice that has been pre-processed (RGB to grayscale + invert)
<img src="https://github.com/ChrCoello/warp/blob/master/examples/elastic/target.png?raw=true" title="Target Slice" width="512">

Moving slice
<img src="https://github.com/ChrCoello/warp/blob/master/examples/elastic/moving.png?raw=true" title="Moving Slice" width="512">

The image similarity between target and moving image is **0.976361**, and is calculated as follows:
```shell
chrcoello@cr01:$ MeasureImageSimilarity 2 1 target.nii.gz moving.nii.gz
target.nii.gz : moving.nii.gz => CC 0.976361
 targetvalue 0 metricvalue 0.976361 diff 0.976361 toler 1e+20
```
The image similarity metric is measured on all pixels, so it is normal to find such a high value (max CC  is 1). An improvement is to measure the metric on the masked image but this is not available with *MeasureImageSimilarity*.

Blend moving (green) and target(gray)
<img src="https://github.com/ChrCoello/warp_2D/blob/master/images/animated.gif?raw=true" title="Green: moving, gray: target" width="512">

## Intensity-based registration
+ The code used for this task is available [here](https://github.com/ChrCoello/warp/blob/master/images/elastic/runElastic.sh) :
```shell      
#!/bin/bash
#
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4  #controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
dim=2
antsRegistration -v -d $dim -r [ target.nii.gz , moving.nii.gz ,1] \
-m mattes[ target.nii.gz , moving.nii.gz, 1 , 32, regular,0.1 ] \
-t affine[ 0.1 ] \
-c [500x500x50,1.e-8,20] \
-s 4x2x1vox \
-f 3x2x1 -l 1 \
-m cc[ target.nii.gz , moving.nii.gz, 1 , 4 ] \
-t BSplineSyN[ .15, 8, 0, 3 ]  \
-c [ 50x50x50,1.e-8,5 ] \
-s 1x0.5x0vox \
-f 4x2x1 -l 1 -u 1 -z 1 \
-o [moving,moving_diff.nii.gz,moving_inv.nii.gz]
```
To summarise, an affine and diffeomorphism transformation are calculated for the moving slice (*moving.nii.gz*) and the target slice (*target.nii.gz*). The diffeomorphism estimated is quite heavy (>MB) and this should be reduced.
The resulting warped image is closer to the target in term of image similarity (**CC 0.987**). We can observe better matching on the edges and in the white matter tracts. Nevertheless, we can also see that there is no good registration on the *olive structure*.

Moving slice
<img src="https://github.com/ChrCoello/warp_2D/blob/master/images/animated_warp.gif?raw=true" title="Green: moving, gray: target" width="512">

## Adding landmark-based registration
Landmarks should be defined using ITKSnap. Each landmark has a different label as seen in the images below. Of, course, both moving and target images should have corrseponding landmarks.

<img src="https://github.com/ChrCoello/warp_2D/blob/master/examples/landmarks/surfaceMoving.png?raw=true" alt="moving slice" width="256"><img src="https://github.com/ChrCoello/warp_2D/blob/master/examples/landmarks/surfaceTarget.png?raw=true" alt="target slice" width="256">

The metric used when doing landmark-based registration is point set estimation (PSE). This metric can be used on its own (landmark only) or in combination with pixel intensity registration.

```shell
#!/bin/bash
#
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4  # controls multi-threading
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
dim=2
antsRegistration -v -d $dim -r [ target.nii.gz , moving.nii.gz ,1] \
      -m mattes[ target.nii.gz , moving.nii.gz, 1 , 32, regular,0.1 ] \
      -t affine[ 0.15] \
      -c [200x200x50,1.e-8,20] \
      -s 4x2x1vox \
      -f 4x3x2 -l 1 \
      -m pse[surfaceTarget.nii.gz, surfaceMoving.nii.gz, 0.5 , 1, 0, 1, 20] \
      -m cc[target.nii.gz , moving.nii.gz, 0.5, 4] \
      -t syn[ .15, 3, 0.5 ] \
      -c [500x500x500,1.e-8,10] \
      -s 1x0.5x0vox \
      -f 4x3x2 -l 1 -u 1 -z 1 \
      -o [moving_surf,moving_surf_dir.nii.gz,moving_surf_inv.nii.gz]
```

Below are presented the result one gets using the above landmarks in the following configurtion :
 * original image
  <img src="https://github.com/ChrCoello/warp_2D/blob/master/examples/landmarks/land_int_blend_000.png?raw=true" alt="target slice" width="256">
 * warp with only image intensity information: very good fit on the edges but not the internal structure (*olive*)
 <img src="https://github.com/ChrCoello/warp_2D/blob/master/examples/landmarks/land_int_blend_001.png?raw=true" alt="target slice" width="256">
 * warp with 80% intensity and 20% landmarks
  <img src="https://github.com/ChrCoello/warp_2D/blob/master/examples/landmarks/land_int_blend_002.png?raw=true" alt="target slice" width="256">
 * warp with 50% intensity and 50% landmarks
  <img src="https://github.com/ChrCoello/warp_2D/blob/master/examples/landmarks/land_int_blend_003.png?raw=true" alt="target slice" width="256">
 * warp with 20% intensity and 80% landmarks
  <img src="https://github.com/ChrCoello/warp_2D/blob/master/examples/landmarks/land_int_blend_004.png?raw=true" alt="target slice" width="256">
 * warp with only landmark information
  <img src="https://github.com/ChrCoello/warp_2D/blob/master/examples/landmarks/land_int_blend_005.png?raw=true" alt="target slice" width="256">

Below is an animated gif showing the difference in fit when changing the weight from purely image intensity to purely landmark based.

<img src="https://github.com/ChrCoello/warp_2D/blob/master/examples/landmarks/landmark_2_intensity.gif?raw=true" alt="target slice" width="256">


## Applying transformation to high res images
One feature of the transformations calculated with ants is that they represent the deformation from a source space to the target space in the physical workd/space. It means that the calculated deformation is agnostic to the resolution of the image the transformation has been calculated on.

Let's look process the high resolution image *MR25_s019.tif* and associated MR and atlas
```bash
./warp2D_single_section.sh MR25_s018_WP.tif MR25_s018_WP_MRI.png MR25_s018_WP_Segmentation.png 5000 20
```


This tiff image is defining a given physical space, this space being captured by the following tiff tags defined by their [libtiff name](https://www.awaresystems.be/imaging/tiff/tifftags/baseline.html) TIFFTAG_IMAGEWIDTH,TIFFTAG_IMAGELENGTH,TIFFTAG_XRESOLUTION, TIFFTAG_YRESOLUTION,TIFFTAG_RESOLUTIONUNIT.

Metadata input *MR25_s019.tif*
```bash
echo -e "\nMetadata of" ${sec_fn} ":"
identify -verbose ${sec} | grep -E '(Resolution|Units|Print size|Geometry)'
Metadata of MR25_s018_WP:
  Geometry: 22500x17500+0+0
  Resolution: 72x72
  Print size: 312.5x243.056
  Units: PixelsPerInch
    tiff:ResolutionUnit: 2
    tiff:XResolution: 720000/10000
    tiff:YResolution: 720000/10000
```

Defining the correct physical space
```bash
convert ${sec} -strip ${sec_meta}
convert ${sec_meta} -units PixelsPerCentimeter ${sec_meta}
convert ${sec_meta} -density ${tif_res}x${tif_res} ${sec_meta}
echo -e "\nMetadata of" ${sec_meta} "after setting the physical space metadata:"
identify -verbose ${sec_meta} | grep -E '(Resolution|Units|Print size|Geometry)'
Metadata of MR25_s018_WP_meta.tif after setting the physical space metadata:
  Geometry: 22500x17500+0+0
  Resolution: 5000x5000
  Print size: 4.5x3.5
  Units: PixelsPerCentimeter
```

To downsample an image, the program resamples (Imagemagick [-resample](https://www.imagemagick.org/script/command-line-options.php#resample)) the image. In this example, a 20-fold resampling was chosen:
```bash
new_res=$((${tif_res} / ${tif_dwn}))
sec_dwn=${sec_fn}_resize.${sec_ext}
#
sec_dwn_ext="${sec_dwn##*.}"
sec_dwn_fn="${sec_dwn%.*}"
#
echo -e "\nDownsampling" ${tif_dwn} "times"
convert ${sec_meta} -resample ${new_res}x${new_res} ${sec_dwn}
echo -e "\nMetadata after downsampling"
identify -verbose ${sec_dwn} | grep -E '(Resolution|Units|Print size|Geometry)'

Downsampling 20 times

Metadata after downsampling
  Geometry: 1125x875+0+0
  Resolution: 250x250
  Print size: 4.5x3.5
  Units: PixelsPerCentimeter
```

We can see that the phyisal space (Print size) has not change between the high res and low res image. Just the geometry ad resolution are modified.

The physical space is transfered to the header of the Nifti file
using [ImageMath](http://manpages.ubuntu.com/manpages/trusty/man1/ImageMath.1.html)

```bash
echo -e "\nConverting to Nifti"
sec_dwn_nii=${sec_dwn_fn}.nii
ImageMath 2 ${sec_dwn_nii} Byte ${sec_dwn}
echo -e "\nSection nifti file" ${sec_dwn_nii} "info:"
c3d ${sec_dwn_nii} -info-full | grep -E '(Bounding Box|Voxel Spacing|Image Dimensions)'

Section nifti file MR25_s018_WP_resize.nii info:
  Image Dimensions   : [1125, 875, 1]
  Bounding Box       : {[0 0 0], [45 35 1]}
  Voxel Spacing      : [0.04, 0.04, 1]

```

Only tiff files have been tested using ImageMath.

Then the customised MRI cut and associated atlas delineations are resized to the same size as the downsampled version of the section and the transformation is calculated using the MRI as source and the section as target.
```bash
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
```
The important parameter here is 20x20: "the mesh size or, equivalently, the number of knot lines" [see more here](https://sourceforge.net/p/advants/discussion/840261/thread/91efe303/#370d). Here is the [paper](https://www.ncbi.nlm.nih.gov/pubmed/24409140) presenting the BSplineSyn. We can also think about this parameter as the parameter that allows to decrease the [regularisation](https://github.com/ANTsX/ANTs/issues/385).


The transformation can then be applied to the high res images, after they have been transformed to Nifti. Applying the transform to the high res should be done by providing the high res section as target and the hig res MRI as source. We can of course apply the transformation to the high res delineations.
