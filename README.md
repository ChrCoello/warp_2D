# warp_2D
script to estimate a non linear transformation between a 2D microscopic section and the anchored template section

.. image:: https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000
   :target: https://github.com/ChrCoello/warp_2D/blob/master/LICENSE
   :alt: license

## Installation

* Requirements :
  * [ANTs version 2.1.0.post780-g767f7](https://github.com/ANTsX/ANTs) or superior
  * [c3d-1.0.0](https://sourceforge.net/projects/c3d/files/c3d/1.0.0/) or nightly build
  * [ImageMagick 7.0.7-11](https://www.imagemagick.org/script/download.php) or superior

* Clone this repo to your local machine
```bash
cd $HOME
git clone https://github.com/ChrCoello/warp_2D.git
```
* Add the warp_2d/src folder to your PATH by adding the lines below to your ``.bashrc``
```bash
export ANTSPATH="$HOME/ants/bin"
export C3DPATH="$HOME/itksnap/bin"
export ITKSNAPPATH="$HOME/c3d/bin"
export WARP2DPATH="$HOME/warp_2D/src"
PATH="${WARP2DPATH}:${WARP2DPATH}:${WARP2DPATH}:${WARP2DPATH}:$PATH"
```

## General usage

Necessary inputs:
* source.tif: the 2D microscopic image
* template.png: the 2D template section obtained after  anchoring source.tif to the reference atlas using the QuickNii tool
* atlas.png: the 2D atlas section obtained after anchoring source.tif to the reference atlas using the QuickNii tool

Main files:

[**prepare_nifti_for_landmarks.sh**](warp_2D/src/prepare_nifti_for_landmarks.sh)
To prepare Nifti files for drawing the landmarks
```bash
prepare_nifti_for_landmarks.sh source.tif template.png atlas.png
```

[**warp_2D.sh**](warp_2D/src/warp_2D.sh)
To calculate the non linear transformation
```bash
warp2D.sh source.tif template.png atlas.png
```
The calculated transformation will be called *source2templateComposite.h5*

[**warp_2D_lowres.sh**](warp_2D/src/warp_2D_lowres.sh)
To calculate the non linear transformation and apply it to the low resolution (e.g. width 1024) atlas:
```bash
warp2D_lowres.sh source.tif template.png atlas.png
```

[**warp_2D_highres.sh**](warp_2D/src/warp_2D_highres.sh)
To calculate the non linear transformation and apply it to the high res atlas (careful as this takes a lot of time and resources)
```bash
warp2D_highres.sh source.tif template.png atlas.png
```

## General description

This script calculates a diffeomorphism between a 2D image and another 2D image. It can be used:
 * using only a similarity metric based on **image intensity**,  
 * using only a similarity metric based on **landmarks**,
 * a combination of both metrics

The calculation of the diffeomorphism is made in the physical space. Header information of the Nifti fed to the antsRegistration call is important. Pre-processing steps to make this header information correct are done.

Extract from ANTs documentation:
**ANTs uses the direction/orientation, spacing and origin in its definitions of the mapping between images.
That is, ANTs uses the ITK standard defintions of an image space. So, the image orientation, direction matrix, origin and spacing are important! If in doubt about, for example, which side is viewed as left or right by ANTs, then take a look at [ITK-SNAP](http://www.itksnap.org)  and label an image’s known left side. Then apply an ANTs or ITK mapping to the image to see how the data is transformed. ITK and ANTs do not use the s-form that may be stored in some Nifti images**

Each transformation consist is composition of an affine transformation followed by a diffeomorphism modeled as a [BSplineSyN](http://journal.frontiersin.org/article/10.3389/fninf.2013.00039/full)

## Warping ecosystem

+ Advanced Normalization Tools ([ANTs](http://stnava.github.io/ANTs/)) has been selected as the platform/ecosystem to implement registrations
+ set of [functions](https://github.com/ANTsX/ANTs) (mainly C++) based on the Insight Segmentation and Registration Toolkit ([ITK](https://itk.org/) )
+ command-line tools
+ run on Linux (pk-ana-1317a) and implemented on the [Abel Cluster Computer](http://www.uio.no/english/services/it/research/hpc/abel/)
+ active [community](https://sourceforge.net/p/advants/discussion/) of user and developers (mainly Brian Avants and Nick Tustison)
+ as for October 2017, warp functions in Python : [ANTsPy](https://github.com/ANTsX/ANTsPy)

## Workflow
November 2017
![Workflow warp_2D_lowres.sh and warp_2D_highres.sh](images/workflow.svg)

## Examples
See ![here](examples/README.md) for examples
