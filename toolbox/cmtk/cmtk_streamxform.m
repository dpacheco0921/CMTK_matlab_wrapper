function [xyz_out, err_status, idx_status] = ...
    cmtk_streamxform(xyz, refi, refo, iparams)
% cmtk_streamxform: reformat xyz points from one reference to another reference
% coordinates (using CMTK)
%
% Usage:
%   [xyz_out, err_status, idx_status] = ...
%       cmtk_streamxform(xyz, refi, refo, iparams)
%
% Args:
%   xyz: matrix with xyz coordinates to reformat
%   refi: name of source reference image
%   refo: name of target reference image
%   iparams: parameters to update
%       (transform_dir: transform's directory)
%           (default, '.')
%       (oDir: output's directory)
%           (default, '.')
%       (imSuffix: file suffix)
%           (default, '.nrrd')
%       (verbose: verbose)
%           (default, 1)
%       (eSuffix: extra string to select transformation)
%           (default, '')
%
% Notes:
% it assumes you already have all the required transformations
% inspired by xform.streamxform (NAT package, https://github.com/jefferis/nat)
% see cmtk_xform_im cmtk_findxform_coord cmtk_xform

ibpars = [];
ibpars.transform_dir = '.';
ibpars.oDir = '.';
ibpars.imSuffix = '.nrrd'; 
ibpars.verbose = 1;
ibpars.eSuffix = '';

if ~exist('iparams', 'var'); iparams = []; end
ibpars = loparam_updater(ibpars, iparams);

% clean names
refi = strrep(refi, ibpars.imSuffix, '');
refo = strrep(refo, ibpars.imSuffix, '');

% find xform folder
xform = cmtk_findxform_coord(refo, refi, ibpars.transform_dir, ibpars.eSuffix);

% write text file
xyz_table = table(xyz(:, 1), xyz(:, 2), xyz(:, 3));
writetable(xyz_table, 'ifile.txt', 'Delimiter', ' ', ...
    'WriteVariableNames', false, 'WriteRowNames', false)
fid = fopen('ofile.txt', 'wt');
fclose(fid);

% writte command and submit (you could also add --affine-only)
reformat_arg = 'streamxform --inversion-tolerance 1e-03 --precision 5 -- ';

if contains(xform, 'inverse')
    st2execute = [reformat_arg, xform, ' < ifile.txt > ofile.txt'];
else
    st2execute = [reformat_arg, xform, ' < ifile.txt > ofile.txt'];
end

coexecuter(st2execute, 0)

% read textfile and replace coordinates
[xyz_out, err_status, idx_status] = readtable_(ibpars.verbose);

% delete temporal files generated
delete([pwd, filesep, 'ifile.txt']);
delete([pwd, filesep, 'ofile.txt']);

end

function [xyz, err_status, err_idx] = readtable_(verbose)
% readtable_: read reformated coordinates from txt file
% coordinates (using CMTK)
%
% Usage:
%   [xyz, err_status, err_idx] = readtable_(verbose)
%
% Args:
%   verbose: verbose
% 
% Returns:
%   xyz: reformated coordinates from txt file
%   err_status: did any error happen
%   err_idx: indeces where error happened

err_status = 0;
err_idx = [];
xyz = [];

fileID = fopen('ofile.txt');
xyzs_ = textscan(fileID, '%f%f%f%s');
fclose(fileID);
xyz = [xyzs_{1}, xyzs_{2}, xyzs_{3}];
status = xyzs_{4};
failed_fi = contains(status, 'FAILED');

if sum(failed_fi) ~= 0
    
    if verbose
        fprintf(['**** streamxform failed at ', ...
            num2str(find(failed_fi)'), ' lines ****\n'])
    end
    
    err_status = 1;
    err_idx = find(failed_fi);
    
end

end
