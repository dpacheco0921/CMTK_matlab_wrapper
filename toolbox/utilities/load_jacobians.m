function load_jacobians(f2r_im, f2r_dir, sizY_2d, sizY_3d, ...
    bmask_int, dataObj, stat2use, iRes, oRes)
% load_jacobians: load jacobian image per file and saves it in dataObj (variable Y)
%
% Usage:
%   load_jacobians(f2r_im, f2r_dir, sizY_2d, sizY_3d, bmask_int, dataObj)
%
% Args:
%   f2r_im: file names
%   f2r_dir: file directories
%   sizY_2d: 2D size (flattened)
%   sizY_3d: 3D size
%   bmask_int: mask with voxels/pixels to use (sizY_2d)
%   stat2use: stat to use for jacobian denominator)
%       (1, mean, default)
%       (2, median)
%   iRes: original resolution
%   oRes: target resolution

if ~exist('iRes', 'var'); iRes = []; end
if ~exist('oRes', 'var'); oRes = []; end

fprintf('Loading jacobians from all groups\n')
dataObj.Y = [];

if stat2use == 1
    fprintf('mean normalized\n')
elseif stat2use == 2
    fprintf('median normalized\n')
end

for i = 1:numel(f2r_im)

    t0 = tic;
    display(f2r_im{i})
    [tdata, ~] = nrrdread([f2r_dir{i}, filesep, f2r_im{i}]);
    
    sizY_3d_init = size(tdata);
    sizY_2d_init = [prod(sizY_3d_init), 1];
    tdata = reshape(tdata, sizY_2d_init);
    
    % replace negative values
    fprintf(['init_min : ', num2str(min(tdata))]); 
    minpos = min(tdata(tdata >= 0));
    tdata(tdata < 0) = minpos; 
    fprintf(['end_min : ', num2str(min(tdata)), '\n']); 
    
    % change resolution
    if ~isempty(iRes) && ~isempty(oRes)
        tdata = reshape(tdata, sizY_3d_init);
        tdata = interp3DxT(tdata, iRes, oRes, 3);
        tdata = reshape(tdata, sizY_2d);
    end
    
    % get mean or median
    if stat2use == 1
        tm = mean(tdata(bmask_int == 1));
    elseif stat2use == 2
        tm = median(tdata(bmask_int == 1));
    end
    
    % normalize and get log
    tdata = log(tdata/tm);
    dataObj.Y(1:sizY_2d(1), i) = tdata;
    clear tdata
    toc(t0)
    
    if i == 1
        fprintf(['Estimated time ', num2str(toc(t0)*numel(f2r_im)/3600), ' hours\n'])
    end
    
end

dataObj.sizY = [sizY_2d(1), numel(f2r_im)];
dataObj.sizYo = sizY_3d;
fprintf('\n');

end
