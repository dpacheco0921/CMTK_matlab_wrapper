%% Params to register atlas (reference) brains to each other (atlas to atlas)
% Sets p.* (ref2refreg, floatiDir, refiDir, refImSu, floatImSu, redo, wgate, agate)
%   and iparams.* (affine + warp settings, G picked per target atlas); no outputs.
% Starting with default refgen params
% NOTE (known issue, not yet fixed): the grid-spacing block below uses
%   p.rIm2sel, which is never defined, so this script errors when run.

global p
% which reference image to use
p.ref2refreg = 0;
[p.floatiDir, ~, ~] = regrelated_directories;
[p.refiDir, ~, ~] = regrelated_directories;
% from fixed-to-invivo
p.refImSu = {'FCWB.', 'IBNWB.', 'IBNWBs2.', 'IBNWBs1.', 'JFRC2.', 'JFRC2s1.', 'JFRC2s2.'};
p.floatImSu = {'nsybIVAi.', 'nsybIVAiFC.', 'nsybIVAiIB.'};
% from invivo-to-fixed
%p.refImSu = 'nsybIVAi.';
%p.floatImSu = {'IBNWB.'};
p.redo = 0;
p.wgate = 1;
p.agate = 1;
% registration parameters
iparams.regf2use = 1; 
iparams.initf2use = 1;
iparams.aX = 13;
iparams.aM = '--nmi';
iparams.wM = '--msd';
iparams.aC = 9;
iparams.E = '1e-1'; % default
%iparams.E = '1e-2';
iparams.wX = 13;
iparams.wC = 9;
iparams.inittype_mia = '--centers-of-mass';
iparams.inittype_reg = '--com';
iparams.amatchHist = 1;
iparams.padfloat = 0;
iparams.padref = 0;
iparams.G = '170';
%Update grid spacing depending on target brain atlas
if contains(p.refImSu(p.rIm2sel), 'IBNWB')
    iparams.G = '90';
elseif contains(p.refImSu(p.rIm2sel), 'JFRC2')
    iparams.G = '102';
elseif contains(p.refImSu(p.rIm2sel), 'FCWB')
    iparams.G = '54';
elseif contains(p.refImSu(p.rIm2sel), 'IVA')
    iparams.G = '170';
elseif contains(p.refImSu(p.rIm2sel), 'IS2')
    iparams.G = '85';
elseif contains(p.refImSu(p.rIm2sel), 'T1')
    iparams.G = '85';    
end

%edit cmtk_paramgen.m
