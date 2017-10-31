# Warping tasks: stack of 2D slices
This task will focus on calculating a 2D to 2D diffeomorphism between stack of slices (2D) and a volumetric template (3D) within the warping ecosystem using **intensity-based** metric, **landmark-based** metric, or a combination of both
  + the stack of 2D slices have been initially manually anchored (i.e affine transformed) to the reference coordinate space using a template and/or atlas
  + once this stack of slices is anchored, the inverse affine transform is applied to the volumetric template to generate a stack of resliced 2D template slices. At this stage, a **stack of N slices and a stack of corresponding N template slices** is available
  + calculation of a diffeomorphism (in the physical space) between each pair using the pre-process original slice i as moving image and resliced template slices as target. This is important as the target image is defining the space where the registration is occuring. Direct (section space to template space) and inverse (template space to section space)  transformation are calculated for each slice.
  + each transformation consist in an affine transformation followed by a diffeomorphism modeled as a [BSplineSyN](http://journal.frontiersin.org/article/10.3389/fninf.2013.00039/full)
  + for now, there is no relation between transformation of diffeomorphism found for slice pair i and slice pair i+1

## Example of pair of slices after anchoring
Target slice: this is the histology slice that has been pre-processed (RGB to grayscale + invert)
![target slice](https://github.com/ChrCoello/warp/blob/master/2D/elastic/target.png?raw=true "Target Slice")

Moving slice![moving slice](https://github.com/ChrCoello/warp/blob/master/2D/elastic/moving.png?raw=true "Moving Slice")

The image similarity between target and moving image is **0.976361**, and is calculated as follows:
```shell
chrcoello@cr01:$ MeasureImageSimilarity 2 1 target.nii.gz moving.nii.gz
target.nii.gz : moving.nii.gz => CC 0.976361
 targetvalue 0 metricvalue 0.976361 diff 0.976361 toler 1e+20
```
The image similarity metric is measured on all pixels, so it is normal to find such a high value (max CC  is 1). An improvement is to measure the metric on the masked image but this is not available with *MeasureImageSimilarity*.

Blend moving (green) and target(gray)![moving slice](https://github.com/ChrCoello/warp/blob/master/2D/animated.gif?raw=true "Green: moving, gray: target")

## Intensity-based registration
+ The code used for this task is available [here](https://github.com/ChrCoello/warp/blob/master/2D/elastic/runElastic.sh) :
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
![moving slice](https://github.com/ChrCoello/warp/blob/master/2D/animated_warp.gif?raw=true "Green: moving, gray: target")

## Adding landmark-based registration
Landmarks should be defined using ITKSnap. Each landmark has a different label as seen in the images below. Of, course, both moving and target images should have corrseponding landmarks.

<img src="https://github.com/ChrCoello/warp/blob/master/2D/landmarks/surfaceMoving.png?raw=true" alt="moving slice" width="256"><img src="https://github.com/ChrCoello/warp/blob/master/2D/landmarks/surfaceTarget.png?raw=true" alt="target slice" width="256">

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

Below are three examples :
 * warp with only image intensity information
 * warp with only landmark information
 * warp with a combination of both
