# CMTK_matlab_wrapper

Matlab functions to interface with CMTK toolbox.
Inspired by [munger.pl](https://github.com/jefferis/AnalysisSuiteBin/blob/master/munger.pl)

It uses CMTK functions:
    - 'registrationx', 'warpx', 'reformatx', 'average_images', 'avg_adm' and 'streamxform'.
to:
    - register, transform images or coordinates, and generate average images (using average dedormation model).

Also, it has functions to perform deformation-based morphometry (implemented as described in [Cachero et al](https://www.sciencedirect.com/science/article/pii/S0960982210009474?via%3Dihub)).

# Usage

-

# Organization of data

- Input (floating) images: images in [NRRD](http://teem.sourceforge.net/nrrd/format.html)) format.
- do not use letters for naming files.
- if using more than one channel:
    - make a folder 'images' for the reference channel (use to generate trasnformations).
    - put extra channels in 'images_ch2' and 'images_ch3' (if you have three channels).
    - all transformations will be saved in 'registration' folder, within 'affine' or 'warp' subfolders for ridig and non-rigid transformations respectively.
    - when applying transformations they will be saved in reformatted, reformatted_ch2, or reformatted_ch3 depending on the floating channel used.

# Dependencies

This pipeline requires the following packages:
- the Computational Morphometry Toolkit [CMTK](https://www.nitrc.org/projects/cmtk)
    - download toolbox at [CMTK-Download](https://www.nitrc.org/frs/?group_id=212), for windows install see [CMTK-windows](https://github.com/jefferis/nat/blob/master/vignettes/Installation.Rmd)

# Acknowledgements

Special thanks to:
- [Gregory Jefferis](https://github.com/jefferis) and Torsten Rohlfing for help with [CMTK toolbox](https://www.nitrc.org/projects/cmtk)

# Citation

If you use this code please cite the following corresponding paper:
[Diego Pacheco, Stephan Thiberge, Eftychios Pnevmatikakis, Mala Murthy (2019). Auditory Activity is Diverse and Widespread Throughout the Central Brain of Drosophila](https://doi.org/10.1101/709519)
