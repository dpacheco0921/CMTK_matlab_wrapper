%% Params used for fly to ref registration
% notes

global p
p.ref2refreg = 0;
[p.refiDir, ~, ~] = regrelated_directories;
p.refImSu = 'nsybIVAi.nrrd'; % suffix for reference image 
p.floatImSu = []; % suffix for floating image
p.float2reject = 'cb';
p.floatiDir = ['.', filesep, 'images']; % default floating image directory
p.redo = 0;
p.agate = 1;
p.wgate = 1;
p.ragate = 0; % refine affine
p.jgate = 0;
p.rgate_ch2 = 0;
% affine parameters
iparams.regf2use = 1; 
iparams.aX = 13;
iparams.aM = '--nmi';
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
iparams.J = '1e-3'; % '1e-2';
iparams.I = '0';
iparams.E = '1'; % '1e-1';
iparams.R = '5';
iparams.wSpeed = 0;
iparams.wmatchHist = 0;
iparams.G = '170';
% registration parameters
%edit cmtk_paramgen.m
