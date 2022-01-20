%% Params used for the generation of reference brain
% Starting with default refgen params

% which reference image to use
p.ref2refreg = 0;
p.floatiDir = ['.', filesep, 'images'];
[p.refiDir, ~, ~] = regrelated_directories;
p.refImSu = 'JFRC2.';
p.floatImSu = [];
p.redo = 0;
p.wgate = 0;
p.agate = 1;
% registration parameters
iparams.regf2use = 1; 
iparams.initf2use = 1;
iparams.aX = 13;
iparams.aM = '--nmi';
iparams.aC = 9;
iparams.wX = 13;
iparams.wC = 9;
iparams.inittype_mia = '--centers-of-mass';
iparams.inittype_reg = '--com';
iparams.amatchHist = 1;
iparams.padfloat = 0;
iparams.padref = 0;
iparams.G = '170';
iparams.J = '0'; % '1e-3'
iparams.I = '0';
iparams.E = '1e-1'; %'0.5';

%Update grid spacing depending on target brain atlas
if ~isempty(strfind(p.refImSu, 'IBNWB'))
    iparams.G = '90';
elseif ~isempty(strfind(p.refImSu, 'JFRC2.'))
    iparams.G = '102';
elseif ~isempty(strfind(p.refImSu, 'JFRC2018'))
    iparams.G = '90';
    iparams.rC = 4;
elseif ~isempty(strfind(p.refImSu, 'FCWB'))
    iparams.G = '54';
elseif ~isempty(strfind(p.refImSu, 'nsybIVA'))
    iparams.G = '170';
elseif ~isempty(strfind(p.refImSu, 'IS2'))
    iparams.G = '85';
elseif ~isempty(strfind(p.refImSu, 'T1'))
    iparams.G = '85';
elseif ~isempty(strfind(p.refImSu, 'FAFB'))
    iparams.G = '100';
end

%edit cmtk_paramgen.m
