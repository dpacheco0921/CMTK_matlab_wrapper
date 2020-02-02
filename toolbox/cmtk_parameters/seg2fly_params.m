%% Params used for the segment to fly registration
% Notes
% 1) this registration should mostly be rigid so dofs of 3, 6, and 9 should suffice
% 2) center of mass does only translation for initial affine which is what
% you want (consider fixing scale or even changing the initial position based on region imaged)
% 3) include all pixels set iparams.pad* to 0
% 4) I used to use iparams.G = '30' and iparams.wX = 13, but it added
% deformations that where not necessary, so I reduce the grid size
% 5) If pad gate is on, then it tend to register images to pad-out pixels

global p

% registration params
iparams.regf2use = 1; 
iparams.initf2use = 1; % check if it works without manual editing
iparams.inittype_mia = '--centers-of-mass';
iparams.inittype_reg = '--com';
iparams.aM = '--nmi';
iparams.wM = '--nmi';

% Exploration step size should not be too small nor too big (guided by refgen settings)
iparams.aX = 13;
iparams.wX = 8;

% downsample
iparams.aC = 9;
iparams.wC = 9;

% They are different images (segment vs whole brain, so I dont expect to have similar hist)
iparams.amatchHist = 0;
iparams.wmatchHist = 0;

% in general the scaling should be the same across flies, so one could
% generate an initial affine with translation and scaling, and then
% constrain the affine to just rotation and translation.
iparams.affineDOF = '--dofs 3 --dofs 6 --dofs 9';

% for files where the prep moves or deforms a lot, one should rely more on
% the matching of anterior areas.
iparams.padref = 0;
iparams.padfloat = 0;
iparams.padout = 0;
iparams.G = '20';
iparams.R = '2';
iparams.J = '1e-2';
iparams.I = '0';
iparams.E = '1e-1'; 

% extra params
p.ref2refreg = 0;
p.refImSu = '_w_'; % suffix for reference image
p.floatImSu = '_s_'; % suffix for floating image
p.floatiDir = '.'; % default floating image directory
p.agate = 1;
p.redo = 0;
p.wgate = 1;

%registration parameters
%edit cmtk_paramgen.m
