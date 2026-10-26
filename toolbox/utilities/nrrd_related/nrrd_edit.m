function nrrd_edit(FolderName, FileName, iparams)
% nrrd_edit: function that edits nrrd voxel size, numerical type, and compress images.
%
% Usage:
%   nrrd_edit(FolderName, FileName, iparams)
%
% Args:
%   FolderName: only edit files whose directory contains this string ([] = all)
%   FileName: only edit files whose name contains this string ([] = all)
%   iparams: parameters to update
%       (XYZres: pixel resolution ('x y z', 'width height depth'))
%           (default, [])
%       (numtype: numerical type ('uint16', 'uint8'))
%           (default, [])
%       (compression: type of compresssion (gzip, or raw))
%           (default, [])
%       (planes2zero: set of planes to set to zero)
%           (default, [])
%       (cuboid2erode: creates a 3-D cuboidal structuring element of size [m n p])
%           (default, [])
%       (medfilt: median filter window, e.g. [3 3 1])
%           (default, [], no filtering)
%       (dir_depth: depth of directory search, values above 1 act as 2)
%           (default, 0)
%       (fsuffix: file suffix/extension to look for)
%           (default, '.nrrd')
%       (flip_axis: axis to flip)
%           (default, [0 0 0], 'height witdh depth')
%       (save_mirror: save also mirror image on selected axis)
%           (default, [0 0 0], 'height witdh depth')
%       (save_mirror_str: [n_axes x 2] cell, {string to replace, replacement}
%           per axis, used for naming the mirror image)
%           (default, {'w', 'ymw'; 'w', 'xmw'; 'w', 'zmw'}, 'height width depth')
%
% Returns:
%   none (each file is rewritten in place)
%
% Notes:
% Requires mat2uint16 and mat2uint8 (external, not in this repo), and the
%   Image Processing Toolbox (medfilt3, imfill, imerode, strel).
% NOTE (known issues, not yet fixed): the edited image overwrites the input
%   file, and the numeric type defaults to uint16 (intensities rescaled) even
%   if numtype is empty. The mirror name is made by strrep on the FULL path,
%   so a 'w' in a folder name changes the folder, and if the token is not
%   in the file name the mirror overwrites the original.

if ~exist('FileName','var')
    FileName = [];
end

if ~exist('FolderName','var')
    FolderName = [];
end

ipars.XYZres = [];
ipars.numtype = [];
ipars.compression = [];
ipars.fsuffix = '.nrrd';
ipars.planes2zero = [];
ipars.cuboid2erode = [];
ipars.medfilt = [];
ipars.dir_depth = 0;
ipars.flip_axis = [0 0 0];
ipars.save_mirror = [0 0 0];
ipars.save_mirror_str = {'w', 'ymw'; 'w', 'xmw'; 'w', 'zmw'};

% update variables
if ~exist('iparams', 'var'); iparams = []; end
ipars = loparam_updater(ipars, iparams);

% define files to use
if ipars.dir_depth == 0
    f2run = rdir(['.', filesep, '*', ...
        ipars.fsuffix]);
elseif ipars.dir_depth == 1
    f2run = rdir(['.', filesep, '*', ...
        filesep, '*', ipars.fsuffix]);
else
    f2run = rdir(['.', filesep, '*', ...
        filesep, '*', filesep, '*', ...
        ipars.fsuffix]);
end

f2run = {f2run.name}';
[filename, iDir] = split_path(f2run);

if ~isempty(FileName)
    f2run = find(contains(filename, FileName));
    filename = filename(f2run);
    iDir = iDir(f2run);
end

if ~isempty(FolderName)
    f2run = find(contains(iDir, FolderName));
    filename = filename(f2run);
    iDir = iDir(f2run);
end

fprintf(['Editing ', ...
    num2str(numel(filename)), ' files\n'])

% plot sMod results
for i = 1:numel(filename)

    editnrrd([iDir{i}, filesep, filename{i}], ipars);

end

fprintf('... Done\n')

end

function editnrrd(filename, ipars)
% editnrrd: edit each nrrd file
%
% Usage:
%   editnrrd(filename, ipars)
%
% Args:
%   filename: full file name
%   ipars: parameters to update
%       (XYZres: pixel resolution ('x y z', 'width height depth'))
%           (default, [])
%       (numtype: numerical type ('uint16', 'uint8'))
%           (default, [])
%       (compression: type of compresssion (gzip, or raw))
%           (default, [])
%       (planes2zero: set of planes to set to zero)
%           (default, [])
%       (cuboid2erode:  creates a 3-D cuboidal structuring element of size [m n p])
%           (default, [])
%       (medfilt: median filter window, e.g. [3 3 1])
%           (default, [], no filtering)
%       (dir_depth: depth of directory search, values above 1 act as 2)
%           (default, 0)
%       (fsuffix: file suffix/extension to look for)
%           (default, '.nrrd')
%       (flip_axis: axis to flip)
%           (default, [0 0 0], 'height witdh depth')
%       (save_mirror: save also mirror image on selected axis)
%           (default, [0 0 0], 'height witdh depth')
%       (save_mirror_str: string to replace for naming mirror image)
%           (default, {'w', 'ymw'; 'w', 'xmw'; 'w', 'zmw'}, 'height width depth')

% load image
[Data, meta] = nrrdread(filename);

% update voxel size
if ~isempty(ipars.XYZres)
    
    fprintf(['updating voxel size from ', num2str(nrrdread_res(meta)), ...
        'to', num2str(ipars.XYZres), '\n'])
    
else
    
    ipars.XYZres = nrrdread_res(meta);
    
end

% update numeric type size
if ~isempty(ipars.numtype)
    
    numtype = ipars.numtype;
    
else
    
    numtype = 'uint16';
    
end

% set come planes to zero
if ~isempty(ipars.planes2zero)
    Data(:, :, ipars.planes2zero) = 0;
end

% do median filtering
if ~isempty(ipars.medfilt)
    Data = medfilt3(double(Data), ipars.medfilt);
end

% apply numeric type change
switch numtype

    case 'uint16'

        Data = mat2uint16(Data, 1);

    case 'uint8'

        Data = mat2uint8(Data, 1);

end

% erode image: build a mask of the brain (smooth, fill holes), shrink it so
%   the noisy edge planes are excluded, and zero everything outside it
if ~isempty(ipars.cuboid2erode)
    
    % fill in holes
    mask_ = medfilt3(double(Data > 0), [7 7 1]);
    
    mask_ = imfill(mask_ > 0, 26, 'holes');
    
    % erode edge planes
    mask_ = imerode(mask_, strel('cuboid', ipars.cuboid2erode));
    
    % fill in holes
    mask_ = imfill(mask_, 26, 'holes');
    
    Data(mask_ == 0) = 0;
    
    % to visualize use
    % pi = [];
    % pi.range = [0 prctile(double(Data(:)), 98)];
    % slice3Dmatrix(double(Data), pi)
    
end

fprintf(['Saving nrrd as ', numtype, '\n'])

if ~isempty(ipars.compression)
    
    compressiontype = ipars.compression;
    
else
    
    compressiontype = 'gzip';
    
end

fprintf(['Saving nrrd as ', compressiontype, '\n'])

% flip axis
for i = 1:3
    if ipars.flip_axis(i)
        Data = flip(Data, i);
    end
end

nrrdWriter(filename, Data, ipars.XYZres, [0 0 0], compressiontype);

% save, in addition, mirror images of defined axis
for i = 1:3
    if ipars.save_mirror(i)
        
        Data_m = flip(Data, i);
        nrrdWriter(strrep(filename, ipars.save_mirror_str{i, 1}, ipars.save_mirror_str{i, 2}), ...
            Data_m, ipars.XYZres, [0 0 0], compressiontype);
        
    end
end

end
