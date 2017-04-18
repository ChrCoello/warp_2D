## 18-04-2017 Non linear warping

1. Warping ecosystem
  + Advanced Normalization Tools ([ANTs](http://stnava.github.io/ANTs/)) has been selected as the platform/ecosystem to implement registrations
  + set of [functions](https://github.com/stnava/ANTs) (mainly C++) based on the Insight Segmentation and Registration Toolkit ([ITK](https://itk.org/) )
  + command-line
  + run on Linux and implemented on the [Abel Cluster Computer](http://www.uio.no/english/services/it/research/hpc/abel/)
  + active [community](https://sourceforge.net/p/advants/discussion/) of user and developers (mainly Brian Avants and Nick Tustison)
2. Warping tasks: stack of 2D slices
  + first task is to calculate a 2D to 2D diffeomorphism between stack of slices (2D) and a volumetric template (3D)
  + the stack of 2D slices have been initially manually anchored (i.e affine transformed) to the reference coordinate space using a template and/or atlas
  + once this stack of slices is anchored, the inverse affine transform is applied to the volumetric template to generate a stack of resliced 2D template slices. At this stage, a stack of N slices and a stack of corresponding N template slices is available
  + calculation of a diffeomorphism between each pair: pre-process original slice i and resliced template slices
  + for now, there is no relation between transformation of diffeomorphism found for slice pair i and slice pair i+1
  +
3. Warping tasks: heterogeneous set of 3D volumes or coherent 2D stack of slices to be warped into the
