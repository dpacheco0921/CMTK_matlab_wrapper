function [iObject, err_] = cmtk_xform(iObject, refi, refo, iparams)
% cmtk_xform: reformat xyz points (matrix of points or trees) 
%   from one reference to another reference coordinates (using CMTK)
%
% Usage:
%   [iObject, err_] = cmtk_xform(iObject, refi, refo, iparams)
%
% Args:
%   iObject: input obj (tree, trees, xyz matrix)
%   refi: name of source reference image
%   refo: name of target reference image
%   iparams: parameters to update
%       (jitter: jitter resolution in um)
%           (default, 10^-1)
%       (fixgate: gate to try to fix points that failed)
%           (default, 1)
%       (presicion: round all digits bellow ()-1 this values
%           (default, 10^3)
%       (siz_: steps in ibpars.jitter to explore possible solutions for failed points)
%           (default, 1:9)
%       (transform_dir: directory of transform)
%           (default, '.')
%       (oDir: output directory)
%           (default, '.')
%       (imSuffix: file suffix)
%           (default, '.nrrd')
%       (verbose: verbose)
%           (default, 1)
%       (eSuffix: extra string to select transformation)
%           (default, '')
%
% Returns:
%   iObject: reformated obj (tree, trees, xyz matrix)
%   err_: error flag
%
% Notes:
% for non-linear registration, certain points may not exist, therefore I
%   added a jitter component to find points in the vicinity of the point to
%   register that have a matching point in the reference coordinates.
% inspired by xform (NAT package, https://github.com/jefferis/nat)
% see cmtk_xform_im cmtk_streamxform
%
% ToDo:
% add condition to just do affine

ibpars = [];
ibpars.jitter = 10^-1;
ibpars.fixgate = 1;
ibpars.presicion = 10^3;
ibpars.siz_ = 1:9;
ibpars.verbose = 0;
ibpars.transform_dir = '.';
ibpars.oDir = '.';
ibpars.imSuffix = '.nrrd'; 
ibpars.verbose = 1;
ibpars.eSuffix = '';

if ~exist('iparams', 'var'); iparams = []; end
ibpars = loparam_updater(ibpars, iparams);

% remove format suffix
if contains(refi, '.nrrd')
    refi = strrep(refi, '.nrrd', '');
end

if contains(refo, '.nrrd')
    refo = strrep(refo, '.nrrd', '');
end

% extract xyz from object
xyz = getObj_xyz(iObject);

% change precision
xyz = round(xyz.*ibpars.presicion)./ibpars.presicion;

% reformat coordinates
[xyz_reg, err_, idx_] = cmtk_streamxform(xyz, refi, refo, ibpars);

% deal with failed points: solution add jitter and map nearby point
jitter_m = [-1 0 0; 0 -1 0; 0 0 -1; ...
    -1 -1 0; 0 -1 -1; -1 0 -1; -1 -1 -1; 0 0 0];

if err_ && ibpars.fixgate
    
    err_ = 0;
    ibpars.verbose = 0;
    rng('shuffle');
    xyz_2cor = xyz(idx_, :);
    
    % add jitter
    fprintf('Adding jitter to map some failed points\n')
    
    for i = 1:size(xyz_2cor, 1)
        
        fprintf(['Point # ', num2str(i), ': '])
        k = 1; l = 1;
        
        while k == 1 && l <= numel(ibpars.siz_)
            fprintf([num2str(l), ' '])
            xyz_temp = xyz_2cor(i, :);
            xyz_temp = repmat(xyz_temp, [size(jitter_m, 1) 1]);
            xyz_temp = xyz_temp + jitter_m.*ibpars.jitter*ibpars.siz_(l);
            [xyz_reg_, ~, k_idx] = cmtk_streamxform(xyz_temp, refi, refo, ibpars);
            k = numel(k_idx) == size(xyz_reg_, 1);
            l = l + 1;
        end
        
        if k == 0
            k_idx = setdiff(1:size(xyz_reg_, 1), k_idx);
            xyz_2cor(i, :) = xyz_reg_(k_idx(1), :);
        else
            xyz_2cor(i, :) = [nan nan nan];
            fprintf('*** jitter failed ***');
            err_ = 1;
        end
        
        clear xyz_temp xyz_reg_ k l;
        fprintf('\n')
        
    end
    
    xyz_reg(idx_, :) = xyz_2cor;
    
else
    
    xyz_reg(idx_, :) = nan;
    fprintf('*** not correcting failed points ***\n')
    
end

% update xyz from object
iObject = updObj_xyz(iObject, xyz_reg);

end
