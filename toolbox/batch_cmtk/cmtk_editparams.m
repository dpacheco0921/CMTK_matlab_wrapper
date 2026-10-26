function [p, registration_params] = ...
    cmtk_editparams(reg_edit, p, registration_params)
% cmtk_editparams: modify registration parameters on the go, encoded as numeric
%   codes in reg_edit (applied one by one for each value in the vector reg_edit);
%   sets fields of p and registration_params and returns both.
%
% Edit codes (as implemented in edit_per_value below; unknown codes do nothing):
%   affine function:  1 registrationx (regf2use = 1), 2 registration (regf2use = 0)
%   metric:           3/4/5 affine msd/nmi/ncc (aM); 6 warp msd, 8 warp ncc (wM)
%                     7 sets aM = nmi (NOTE known issue, not yet fixed: likely meant wM = nmi)
%   initial affine:   9 use make_initial_affine (initf2use = 1)
%   jacobian weight:  11 J=0, 12 J=1e-1, 13 J=1e-2, 14 J=1e-3
%   grid size G, refinements R: 15 G=40,R=3; 16 G=80,R=4; 17 G=170,R=5
%   energy weight:    18 E=1e-1, 19 E=1
%   refgen related:   20 p.refImSu='nsybIVAn_1'; 21 G=160; 22 p.refImSu='JFRC2_cbrain_m.';
%                     26 p.refImSu='JRC2018f.'; 27 p.refImSu='JRC2018u.'
%   affine dofs:      30 dofs 3,6,9,12; 31 dofs 3,6,9; 32 dofs 3,6; 33 dofs 3
%   ref2ref (fixed brains as targets, floating = 'nsybIVA.'): sets p.refImSu, p.floatImSu and G:
%                     41 IBNWBs2th G=90; 42 JFRC2s2th G=102; 43 IS2 G=85; 44 T1 G=85; 45 FCWB G=54
%   dsx fly2ref:      51 (dofs 3,6, nmi, ref 'dsxIVA_iTh_m', floats '_w' in '.', refDir ../refDsx);
%                     52 same as 51 without setting aM
%   virilis fly2ref:  61 (ref 'DvirIS.nrrd', floats 'w_02' in '.', nmi, G=85)
%   default refIm:    70 p.floatImSu = {'w_01'}
%   combination:      80 G=40, R=3, E=1
%   (codes whose meaning changed or were removed are listed in the comments
%   inside edit_per_value and in the deprecated block at the end of the file;
%   G = control point grid spacing, R = number of grid refinements, J/E = jacobian
%   and smoothness-energy constraint weights, see cmtk_paramgen)
%
% Usage:
%   [p, registration_params] = ...
%       cmtk_editparams(reg_edit, p, registration_params)
%
% Args:
%   reg_edit: numeric value that defines finer edits of registration
%       parameters.
%   p: controls which files to load, details of server usage, etc
%   registration_params: registration parameters
%
% Output:
%   p: edited controls which files to load, details of server usage, etc
%   registration_params: edited registration parameters

n = numel(reg_edit);
for i = 1:n
    [p, registration_params] = ...
        edit_per_value(reg_edit(i), p, registration_params);
end

end

function [p, registration_params] = ...
    edit_per_value(reg_edit, p, registration_params)
% edit_per_value: modify registration parameters on the go
%   encoded on reg_edit
%
% Usage:
%   [p, registration_params] = ...
%       edit_per_value(reg_edit, p, registration_params)
%
% Args:
%   reg_edit: numeric value that defines finer edits of registration
%       parameters.
%   p: controls which files to load, details of server usage, etc
%   registration_params: registration parameters
%
% Output:
%   p: edited controls which files to load, details of server usage, etc
%   registration_params: edited registration parameters

    % ********* affine function to use *********
if reg_edit == 1
    % registration function to use: registrationx
    registration_params.regf2use = 1;
elseif reg_edit == 2
    % registration function to use: registration
    registration_params.regf2use = 0;
    
    % ********* metric to use *********
elseif reg_edit == 3
    registration_params.aM = '--msd';
elseif reg_edit == 4
    registration_params.aM = '--nmi';
elseif reg_edit == 5
    registration_params.aM = '--ncc';
elseif reg_edit == 6
    registration_params.wM = '--msd';
elseif reg_edit == 7
    registration_params.aM = '--nmi';
elseif reg_edit == 8
    registration_params.wM = '--ncc'; 

    % ********* inital-affine function to use *********
elseif reg_edit == 9
    registration_params.initf2use = 1;

    % ********* jacobian *********    
elseif reg_edit == 11
    registration_params.J = '0';
elseif reg_edit == 12
    registration_params.J = '1e-1';
elseif reg_edit == 13
    registration_params.J = '1e-2';
elseif reg_edit == 14
    registration_params.J = '1e-3';

    % ********* grid size *********
elseif reg_edit == 15
    registration_params.G = '40';
    registration_params.R = '3';
elseif reg_edit == 16
    registration_params.G = '80';
    registration_params.R = '4';
elseif reg_edit == 17
    registration_params.G = '170';
    registration_params.R = '5';
    
    % ********* energy *********
elseif reg_edit == 18
    registration_params.E = '1e-1';
elseif reg_edit == 19
    registration_params.E = '1';

    % ********* refgen related *********
elseif reg_edit == 20
    p.refImSu = 'nsybIVAn_1'; 
elseif reg_edit == 21
    registration_params.G = '160';
elseif reg_edit == 22
    p.refImSu = 'JFRC2_cbrain_m.';
elseif reg_edit == 26
    p.refImSu = 'JRC2018f.';    
elseif reg_edit == 27
    p.refImSu = 'JRC2018u.';

% reg_edit == 21 - current 21 used to be [20 21]
% reg_edit == original 22 [20 21 13] - current 22 used to be 24
% reg_edit == 23 [20 21 14]
% reg_edit == 25 [22 32]
% reg_edit == 28 [26 32]

    % ******** dofs *********
elseif reg_edit == 30
    registration_params.affineDOF = '--dofs 3 --dofs 6 --dofs 9 --dofs 12';
elseif reg_edit == 31
    registration_params.affineDOF = '--dofs 3 --dofs 6 --dofs 9';
elseif reg_edit == 32
    registration_params.affineDOF = '--dofs 3 --dofs 6';
elseif reg_edit == 33 
    registration_params.affineDOF = '--dofs 3';

% reg_edit == original 33 % [32, 15, 13] - current 33 used to be 35
% reg_edit == 34 % [32, 16, 13]
% reg_edit == 36 % [32 18]
% reg_edit == 37 % [32] + registration_params.E = '5e-1';
% reg_edit == 38 % [3 32]
% reg_edit == 39 % [18 11]

    % ******** ref2ref related target fixed brains *********
elseif reg_edit == 41
    p.refImSu = 'IBNWBs2th';
    p.floatImSu = 'nsybIVA.';
    registration_params.G = '90';
elseif reg_edit == 42
    p.refImSu = 'JFRC2s2th';
    p.floatImSu = 'nsybIVA.';
    registration_params.G = '102';
elseif reg_edit == 43
    p.refImSu = 'IS2';
    p.floatImSu = 'nsybIVA.';
    registration_params.G = '85';
elseif reg_edit == 44
    p.refImSu = 'T1';
    p.floatImSu = 'nsybIVA.';
    registration_params.G = '85';
elseif reg_edit == 45
    p.refImSu = 'FCWB';
    p.floatImSu = 'nsybIVA.';
    registration_params.G = '54';

    % ******** dsx fly2ref *********
elseif reg_edit == 51
    p.refiDir = ['..', filesep, 'refDsx'];
    registration_params.affineDOF = '--dofs 3 --dofs 6';
    p.refImSu = 'dsxIVA_iTh_m';
    p.floatImSu = '_w';
    p.floatiDir = '.';
    registration_params.aM = '--nmi';
elseif reg_edit == 52
    p.refiDir = ['..', filesep, 'refDsx'];
    registration_params.affineDOF = '--dofs 3 --dofs 6';
    p.refImSu = 'dsxIVA_iTh_m';
    p.floatImSu = '_w';
    p.floatiDir = '.';

    % ******** virilis fly2ref *********
elseif reg_edit == 61
    p.refImSu = 'DvirIS.nrrd';
    p.floatImSu = 'w_02';
    p.floatiDir = '.';
    p.refiDir = ['..', filesep, '..', filesep, 'referencebrains'];
    registration_params.aM = '--nmi';
    registration_params.G = '85';

    % ******** use default refIm from default reffolder *********
elseif reg_edit == 70
    p.floatImSu = {'w_01'};

    % ******** Combinations *********
elseif reg_edit == 80
    registration_params.G = '40';
    registration_params.R = '3';
    registration_params.E = '1';
end

end

% deprecated
% % ********* single modifications *********
% if reg_edit == 1
%     % registration function to use: registrationx
%     registration_params.regf2use = 1;
% elseif reg_edit == 2
%     % registration function to use: registration
%     registration_params.regf2use = 0;
% elseif reg_edit == 3
%     registration_params.aM = '--msd';
% elseif reg_edit == 4
%     registration_params.aM = '--nmi';
% elseif reg_edit == 5
%     registration_params.aM = '--ncc';
% elseif reg_edit == 6
%     registration_params.wM = '--msd';
% elseif reg_edit == 7
%     registration_params.aM = '--nmi';
% elseif reg_edit == 8
%     registration_params.wM = '--ncc'; 
% elseif reg_edit == 9
%     registration_params.initf2use = 1;
% 
%     % ********* jacobian *********    
% elseif reg_edit == 11
%     registration_params.J = '0';
% elseif reg_edit == 12
%     registration_params.J = '1e-1';
% elseif reg_edit == 13
%     registration_params.J = '1e-2';
% elseif reg_edit == 14
%     registration_params.J = '1e-3';
% 
%     % ********* grid size *********
% elseif reg_edit == 15
%     registration_params.G = '40';
%     registration_params.R = '3';
% elseif reg_edit == 16
%     registration_params.G = '80';
%     registration_params.R = '4';
% elseif reg_edit == 17
%     registration_params.G = '170';
%     registration_params.R = '5';
%     
%     % ********* energy *********
% elseif reg_edit == 18
%     registration_params.E = '1e-1';
% elseif reg_edit == 19
%     registration_params.E = '1';
% 
%     % ********* refgen related *********
% elseif reg_edit == 20
%     p.refImSu = 'nsybIVAn_1'; 
% elseif reg_edit == 21
%     p.refImSu = 'nsybIVAn_1';
%     registration_params.G = '160';
% elseif reg_edit == 22
%     p.refImSu = 'nsybIVAn_1';
%     registration_params.G = '160';
%     registration_params.J = '1e-1';
% elseif reg_edit == 23
%     p.refImSu = 'nsybIVAn_1';
%     registration_params.G = '160';
%     registration_params.J = '1e-2';
% elseif reg_edit == 24
%     p.refImSu = 'JFRC2_cbrain_m.';
% elseif reg_edit == 25
%     p.refImSu = 'JFRC2_cbrain_m.';
%     registration_params.affineDOF = '--dofs 3 --dofs 6';
% elseif reg_edit == 26
%     p.refImSu = 'JRC2018f.';    
% elseif reg_edit == 27
%     p.refImSu = 'JRC2018u.';
% elseif reg_edit == 28
%     p.refImSu = 'JRC2018f.';
%     registration_params.affineDOF = '--dofs 3 --dofs 6';
% elseif reg_edit == 29
%     p.refImSu = 'FAFB14.';   
%     registration_params.E = '5e-1';
%     registration_params.J = '1e-3';
% 
%     % ******** dofs *********
% 
%     % ******** ref2ref related target fixed brains *********
% elseif reg_edit == 41
%     p.refImSu = 'IBNWBs2th';
%     p.floatImSu = 'nsybIVA.';
%     registration_params.G = '90';
% elseif reg_edit == 42
%     p.refImSu = 'JFRC2s2th';
%     p.floatImSu = 'nsybIVA.';
%     registration_params.G = '102';
% elseif reg_edit == 43
%     p.refImSu = 'IS2';
%     p.floatImSu = 'nsybIVA.';
%     registration_params.G = '85';
% elseif reg_edit == 44
%     p.refImSu = 'T1';
%     p.floatImSu = 'nsybIVA.';
%     registration_params.G = '85';
% elseif reg_edit == 45
%     p.refImSu = 'FCWB';
%     p.floatImSu = 'nsybIVA.';
%     registration_params.G = '54';
% 
%     % ******** dsx fly2ref *********
% elseif reg_edit == 51
%     p.refiDir = ['..', filesep, 'refDsx'];
%     registration_params.affineDOF = '--dofs 3 --dofs 6';
%     p.refImSu = 'dsxIVA_iTh_m';
%     p.floatImSu = '_w';
%     p.floatiDir = '.';
%     registration_params.aM = '--nmi';
% elseif reg_edit == 52
%     p.refiDir = ['..', filesep, 'refDsx'];
%     registration_params.affineDOF = '--dofs 3 --dofs 6';
%     p.refImSu = 'dsxIVA_iTh_m';
%     p.floatImSu = '_w';
%     p.floatiDir = '.';
% 
%     % ******** virilis fly2ref *********
% elseif reg_edit == 61
%     p.refImSu = 'DvirIS.nrrd';
%     p.floatImSu = 'w_02';
%     p.floatiDir = '.';
%     p.refiDir = ['..', filesep, '..', filesep, 'referencebrains'];
%     registration_params.aM = '--nmi';
%     registration_params.G = '85';
% 
%     % ******** Alex VNC *********
% elseif reg_edit == 62
%     alex_params % it edits parameters
% 
%     % ******** use default refIm from default reffolder *********
% elseif reg_edit == 70
%     p.floatImSu = {'w_01'};
% 
%     % ******** Combinations *********
% elseif reg_edit == 80
%     registration_params.G = '40';
%     registration_params.R = '3';
%     registration_params.E = '1';
% end