function cmtkpars = cmtk_paramgen(iparams, verbose_)
% cmtk_paramgen: generate default parameters used by CMTK internal function
% 'cmtk_intfunc'
%
% Usage:
%   cmtkpars = cmtk_paramgen(iparams, verbose_)
%
% Args:
%   iparams: input parameters to update/edit
%   verbose_: verbose flag
%       (default, 0)
%
% Returns:
%   cmtkpars: structure with all cmtk parameters to use
%
% Notes:
% For more information on paramters read manual at https://www.nitrc.org/docman/view.php/212/708/UserGuideCMTK.pdf
% inspired by https://github.com/jefferis/AnalysisSuiteBin/blob/master/munger.pl

if ~exist('verbose_', 'var') || isempty(verbose_)
    verbose_ = 0;
end

% verbose_
cmtkpars.verb = 1;

% 1) initializing affine
% To do an initial affine you could use: a) 'make_initialaffine' or 
% b) do it directly (internaly) with 'registrationx'

% Use 'make_initialaffine'
%   (0, do not use, default)
%   (1, use)
cmtkpars.initf2use = 0;

% **********************************************************************************
% **********************************************************************************
% 1.1) define the type of initialization

% input for registrationx: 
%   (--none)
%   (--fov, align centers of field of view using a translation)
%   (--com, align center of mass using translation)
%   (--pax, align images by rotation using principal axes and translation
%       using center of mass)
cmtkpars.inittype_reg = '--fov';

% input for make_initialaffine:
%   (--direction-vectors, aligment based on image direction vectors
%       (internal acronym: dv))
%   (--centers-of-mass, aligment based on center of mass (translation only)
%       (internal acronym: com))
%   (--principal-axes, aligment based on principal axes (internal acronym:
%       pax))
%   (--identity, create only an identity transformation (internal acronym:
%       id))
cmtkpars.inittype_mia = '--principal-axes';

% **********************************************************************************
% **********************************************************************************
% 2) affine parameters

% reg function to use
%   (0: registration)
%   (1: registrationx, deafult)
cmtkpars.regf2use = 1; 

% 2.1) registration metric
%   (--nmi, normalized mututal information metric)
%   (--mi, standard mutual information metric)
%   (--cr, correlation ratio metric)
%   (--rms, root of mean squares metric)
%   (--msd, mean square difference metric)
%   (--ncc, normalized cross correlation metric)
cmtkpars.aM = '--nmi';

% 2.2) Floating image interpolation options

% --match-histograms: match histograms of floating to reference image histogram
cmtkpars.amatchHist = 0;

% 2.3) Image resolution parameters

% --coarsest: upper limit for image sampling in multiresolution hierarchy (max resampling)
% but this is power of 2 times the max pixel size (1.2 um)
% in this case will go from 4.8 --> 2.4 --> 1.2
cmtkpars.aC = 5;

% 2.4) Optimization parameters

% --max-stepsize | -e | --exploration: Optimizer step size
%   it has to be cmtkpars.aAccu*2^n, so in this case 13 (old ~25.6, or 52)
cmtkpars.aX = 13;

% --min-stepsize | -a | -- accuracy: Final optimizer step size, which determines precision
cmtkpars.aAccu = 0.4;

% 2.5) Transformation parameters

% degrees of freefom (dofs)
%   (0, no registration)
%   (3, translation only)
%   (6, 3 + rotation)
%   (9, 6 + anisotropic scale)
%   (7, 6 + global scale)
%   (12, 9 + shears)
cmtkpars.affineDOF = '--dofs 3 --dofs 6 --dofs 9 --dofs 12';

% gate to make transformation symmetric;
cmtkpars.aSym = 0;

% **********************************************************************************
% **********************************************************************************
% 3) warp parameters

% registration function to use
%   (0, warp)
%   (1, warpx)
cmtkpars.warpf2use = 0; 

% 3.1) Image Data

% warp metric (same options as for cmtkpars.aM)
cmtkpars.wM = '--nmi';

% --match-histograms: match histograms of floating to reference image histogram
cmtkpars.wmatchHist = 0;

% to add:
% --repeat-match-histograms: repeat matching after every level of the
%   registration to account for volume changes. When registering masked data
%   it is adviseable to also use the (force ouside values options) to
%   prevent poorly matched histograms

% --force-outside-value: force outside field of view to this value rather
%   then drop incomplete pixel pairs

% 3.2) Image resolution parameters

% --coarsest: upper limit for image sampling in multiresolution hierarchy (max resampling)
%   but this is power of 2 times the max pixel size (1.2 um)
%   in this case will go from 4.8 --> 2.4 --> 1.2
cmtkpars.wC = 5;

% 3.3) Transformation parameters

% --grid-spacing: Control point grid spacing
%   gridspacing size of small axes (3 points min)
cmtkpars.G = '160';

% --grid-refine | --refine: number of refinements (control point grid resolution levels)
%   (down to ~5 pixels (from 40 to 5)) in this case will be ~6.25
cmtkpars.R = '5';

% computation mode
%   (0, fast)
%   (1, accurate)
cmtkpars.wSpeed = 0;

% 3.4) Regularization parameters

% --jacobian-constraint-weight | --jacobian-weight: weight for jacobian-based local volume
%   preservation constraint
cmtkpars.J = '0';

% --inverse-consistency-weight | --ic-weight: weight for inverse consistency constraint
cmtkpars.I = '0';

% --smoothness-constraint-weight | --energy-weight: weight for smoothness constraint based on
%   second order grid bending 
cmtkpars.E = '1e-1';

% --relax-to-unfold: before each resolution level, regularize negative-Jacobian 
%   areas of the deformation to unfold them
cmtkpars.rToUnfold = 0;

% to add:
% --rigidity-weight: weight for local rigidity constraint

% constraint-relaxation-factor | --relax: weight relaxation factor for alternating under-constrained iterations

% 3.5) Optimization parameters

% --max-stepsize | -e | --exploration: Optimizer step size
cmtkpars.wX = 13;

% --min-stepsize | -a | -- accuracy: Final optimizer step size, which determines precision
cmtkpars.wAccu = 0.4;

% **********************************************************************************
% **********************************************************************************
% 4) reformat

% 4.1) interpolation method
%   (--linear: trilinear interpolation)
%   (--nn: nearest neighbor interpolation)
%   (--cubic: tricubic interpolation)
%   (--pv: partial volume interpolation)
%   (--sinc-cosine: sinc interpolation with cosine window)
%   (--sinc-hamming: sinc interpolation with hamming window)
cmtkpars.rM = '--linear';

% 4.2) output type
%   ('--char'; 8 bits, signed)
%   ('--byte'; 8 bits, unsigned)
%   ('--short'; 16 bits, signed)
%   ('--ushort'; 16 bits, unsigned)
%   ('--int'; 32 bits signed)
%   ('--uint'; 32 bits unsigned)
%   ('--float'; 32 bits floating point)
%   ('--double'; 64 bits floating point)
cmtkpars.rMotype = [];

% output image format
cmtkpars.rFormat = 'nrrd';

% 5) padding: 
% designate one value in your image as "padding" marker. The relevant paremeters for
%   registration(x) and warp(x) are "--pad-ref VAL" for the reference (fixed) image 
%   and "--pad-flt VAL" for the floating (moving) image. In either case, 
%   "VAL" is a value to be considered as "missing" data rather than as a data value itself. 
% The effect of using padding is that the pixels with the given passing value are excluded from all computations, 
%   they do not go into any interpolations (when used in the floating image) and they are removed from the set of 
%   pixel pairs considered for similarity computation (when used in the fixed image).
% It is usually better to use padding in the reference than in the floating image. 
% That's because then the number of padded pixels and their relative weights do not 
%   change dependent on the transformation between the images.
cmtkpars.padref = 0;
cmtkpars.padfloat = 0;
cmtkpars.padout = 0;
cmtkpars.padval = [0 0 0]; % order ref, float, out
% tool that could be used: "convertx"

% 6) extra tools to check
% convert_warp (outputs a fractional warp output for display), example
% convert_warp --fractional 1.0 warp_original.xform warp_fractional.xform
% reformatx -o out_stack --floating in_stack reference_stack warp_(original or fractional).xform 
% linear transformations to landmarks: fit_affine_xform_landmarks 
% http://imagej.net/Name_Landmarks_and_Register, by Mark Longair and Greg Jefferis
% http://flybrain.mrc-lmb.cam.ac.uk/dokuwiki/doku.php?id=warping_manual:calculating_an_initial_surface-based_registration_using_amira
% transform traces:
% gregxform, streamxform

% 7) define type of registration to run
%   (to select corresponding default transform directories)
%   ('ia', initial affine)
%   ('a', affine)
%   ('w', warp)
cmtkpars.rLevel = 'w';

% 8) updating parameters that are mentioned
if ~exist('iparams', 'var') || isempty(iparams)
    
    if verbose_; fprintf('Using default values\n'); end
    
else
    
    if ~exist('iparams', 'var'); iparams = []; end
    cmtkpars = loparam_updater(cmtkpars, iparams);
    
end

end