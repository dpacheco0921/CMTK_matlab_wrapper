%% Params used for the generation of reference brain
% Affine registration
% function: registrationx outperforms registration (when using nmi)
% initial affine: initially I used 'fov' but now I use 'com' which makes more sense
% exploration: the maximun tranlation empirically observed in my own data
% is close to 53 um, but a small aX = 13 performs better (used 53 and 26 before)
% dof = 3,6,9,12
% metric: --nmi works the best for most of them. there are cases where msd does outperform nmi (2 out of 14)
% coarsest: I use a C of max 5 (um), above this value does not seem too informative (goes from 1.2, 2.4, 4.8 um)
% coarsest: I use a C of max 9 (um), above this value does not seem too informative (goes from 0.75, 1.5, 2.25, 3, 3.75,4.5, 5.25, 6, 6.75 ... 9 um)
% match histograms does not improve nmi, but in some cases it does for msd.
% However it makes sense to use it for affine, so for warping both images have the same histograms.
% Seems like padding can affect accuracy, so we are disabling it for now

global p
% which reference image to use
p.ref2refreg = 1;
p.refImSu = 'nsybIVAi.nrrd';
p.floatiDir = ['.', filesep, 'images'];
p.refiDir = ['.', filesep];
p.redo = 0;
p.agate = 1;
p.wgate = 1;
p.ragate = 0; % refine affine
p.jgate = 0;
p.rgate_ch2 = 0;

% affine parameters
iparams.regf2use = 1; 
iparams.aX = 13;
iparams.aM = '--nmi'; % given that the data has the same labeling you could try ncc
iparams.aAccu = 0.4;
iparams.aC = 9;
iparams.affineDOF = '--dofs 3 --dofs 6 --dofs 9 --dofs 12';
iparams.initf2use = 0;
iparams.inittype_mia = '--centers-of-mass';
iparams.inittype_reg = '--com';
iparams.amatchHist = 1;
iparams.aSym = 0;
iparams.padfloat = 0;
iparams.padref = 0;

% warp params
iparams.wX = 13;
iparams.wM = '--nmi';
iparams.wAccu = 0.4;
iparams.wC = 9;
iparams.J = '0';
iparams.I = '0';
iparams.E = '1e-1';
iparams.R = '5';
iparams.wSpeed = 0;
iparams.wmatchHist = 0;
iparams.G = '170';

% registration parameters
%edit cmtk_paramgen.m
