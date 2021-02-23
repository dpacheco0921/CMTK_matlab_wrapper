# CMTK_matlab_wrapper

Matlab functions to interface with CMTK toolbox.
Inspired by [munger.pl](https://github.com/jefferis/AnalysisSuiteBin/blob/master/munger.pl)

- It uses CMTK functions:
    - 'registrationx', 'warpx', 'reformatx', 'average_images', 'avg_adm' and 'streamxform'.
- to:
    - register, transform images or coordinates, and generate average images (using average dedormation model).

Also, it has functions to perform deformation-based morphometry (implemented as in [Cachero et al](https://www.sciencedirect.com/science/article/pii/S0960982210009474?via%3Dihub)).

# Usage

- Edit regrelated_directoriestoedit.m file.
    - provide user defined directories, in particular folder where atlases' images will be.
- see cmtk_demo.m
    - download demo data containing:
        - reference image: nsybIVAidownsample.nrrd
        - 'images' folder with floating images
    - use batch_cmtkperfile to run batches of images per folder

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
- download registration-related repositories
    - [https://github.com/VirtualFlyBrain/DrosAdultBRAINdomains](https://github.com/VirtualFlyBrain/DrosAdultBRAINdomains)
    - [https://github.com/VirtualFlyBrain/DrosAdultHalfBRAINdomains](https://github.com/VirtualFlyBrain/DrosAdultHalfBRAINdomains)
    - [https://github.com/jefferislab/BridgingRegistrations](https://github.com/jefferislab/BridgingRegistrations)
    - [https://github.com/jefferislab/MirrorRegistrations](https://github.com/jefferislab/MirrorRegistrations)
    - [https://github.com/jefferislab/DrosophilidBridgingRegistrations](https://github.com/jefferislab/DrosophilidBridgingRegistrations)
- download Fiji
- download pu_cluster_interface (it requires the user defined temporary folder to save job parameters)
    - [https://github.com/dpacheco0921/pu_cluster_interface](https://github.com/dpacheco0921/pu_cluster_interface)

# Acknowledgements

Special thanks to:
- [Gregory Jefferis](https://github.com/jefferis) and Torsten Rohlfing for help with [CMTK toolbox](https://www.nitrc.org/projects/cmtk)

# Citation

If you use this code please cite the following corresponding paper:
[Diego Pacheco, Stephan Thiberge, Eftychios Pnevmatikakis, Mala Murthy (2019). Auditory Activity is Diverse and Widespread Throughout the Central Brain of Drosophila](https://www.nature.com/articles/s41593-020-00743-y)
