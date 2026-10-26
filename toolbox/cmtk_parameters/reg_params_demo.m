%% Params for the demo (cmtk_demo.m): register ./images to 'nsybIVAidownsampled.nrrd' (affine dofs 3,6,9 + warp)
% Sets p.* (ref2refreg, refiDir, refImSu, floatImSu, float2reject, floatiDir, gates) and iparams.* (G=170, J=1e-3, E=1); no outputs.
% iparams.G = control point grid spacing of the warp (image units, um); larger = coarser, smoother deformation (see cmtk_paramgen).
% NOTE: float2reject = 'cb' skips any floating file whose name contains 'cb' (inherited from fly2ref_params.m).
% This file has no 'global p' line, which is why it works inside batch_cmtkperfile.
% notes
% in general uses same registration parameters as used in refgen.m
% it adds specifics for folder and file names

p.ref2refreg = 0;
p.refiDir = '.';
p.refImSu = 'nsybIVAidownsampled.nrrd'; % suffix for reference image
p.floatImSu = []; % suffix for floating image
p.float2reject = 'cb';
p.floatiDir = ['.', filesep, 'images']; % default floating image directory
p.redo = 0;
p.agate = 1;
p.wgate = 1;
p.ragate = 0;
p.jgate = 0;
p.rgate_ch2 = 0;
% affine parameters
% when using nmi or msd metric for affine, nmi at non-linear reaches the
% same solution (or almost the same)
iparams.regf2use = 1; 
iparams.aX = 13;
iparams.aM = '--nmi';
iparams.aAccu = 0.4;
iparams.aC = 9;
iparams.affineDOF = '--dofs 3 --dofs 6 --dofs 9';
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
iparams.J = '1e-3';
iparams.I = '0';
iparams.E = '1';
iparams.R = '5';
iparams.wSpeed = 0;
iparams.wmatchHist = 0;
iparams.G = '170';

% registration parameters
%edit cmtk_paramgen.m
