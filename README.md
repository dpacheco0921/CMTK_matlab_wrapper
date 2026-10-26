# CMTK_matlab_wrapper

Matlab functions to interface with CMTK toolbox.
Inspired by [munger.pl](https://github.com/jefferis/AnalysisSuiteBin/blob/master/munger.pl)

- It uses CMTK functions:
    - 'registrationx', 'warpx', 'reformatx', 'average_images', 'avg_adm' and 'streamxform'.
- to:
    - register, transform images or coordinates, and generate average images (using average dedormation model).

Also, it has functions to perform deformation-based morphometry (implemented as in [Cachero et al](https://www.sciencedirect.com/science/article/pii/S0960982210009474?via%3Dihub)).

# Usage

- Copy toolbox/utilities/user_defined_info/regrelated_directoriestoedit.m to regrelated_directories.m (same folder; the function inside is already named regrelated_directories and every script calls that name), then edit the copy.
    - regrelated_directories.m is git-ignored because it holds machine-specific paths.
    - provide user defined directories, in particular folder where atlases' images will be.
- see cmtk_demo.m
    - download demo data containing:
        - reference image: nsybIVAidownsampled.nrrd
        - 'images' folder with floating images
    - use batch_cmtkperfile to run batches of images per folder

# Organization of data

- Input (floating) images: images in [NRRD](http://teem.sourceforge.net/nrrd/format.html) format.
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
- download StackViewer to visualize results (MatLab wrapper of FIJI functions)
    - [https://github.com/dpacheco0921/StackViewer](https://github.com/dpacheco0921/StackViewer)
- download pu_cluster_interface (it requires the user defined temporary folder to save job parameters)
    - [https://github.com/dpacheco0921/pu_cluster_interface](https://github.com/dpacheco0921/pu_cluster_interface)

# Other requirements (not in this repo)

- MATLAB toolboxes: Parallel Computing (parpool utilities), Image Processing (e.g. medfilt3, imerode), Statistics (ttest2).
- Functions called from the repositories above (StackViewer / pu_cluster_interface): operationIm2Im, mat2uint16, mat2uint8, interp3DxT, user_defined_directories, server_interface, getclus_taskid.
- batch_cmtkperfile only writes the .slurm job file for cluster runs; submit it manually with sbatch from the job folder.

# Acknowledgements

Special thanks to:
- [Gregory Jefferis](https://github.com/jefferis) and Torsten Rohlfing for help with [CMTK toolbox](https://www.nitrc.org/projects/cmtk)

# Citation

If you use this code please cite the following corresponding paper:
[Diego Pacheco, Stephan Thiberge, Eftychios Pnevmatikakis, Mala Murthy (2019). Auditory Activity is Diverse and Widespread Throughout the Central Brain of Drosophila](https://www.nature.com/articles/s41593-020-00743-y)
