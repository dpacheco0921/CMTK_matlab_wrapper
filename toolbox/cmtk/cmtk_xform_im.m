function status_ = cmtk_xform_im(refi, refo, iFloat, oFloat, iparams)
% cmtk_xform_im: transform 'iFloat' image from 'refi' to 'refo' coordinate
% system (using CMTK).
%
% Usage:
%   status_ = cmtk_xform_im(refi, refo, iFloat, oFloat, iparams)
%
% Args:
%   refi: name of source reference image
%   refo: name of target reference image
%   iFloat: name of floating image
%   oFloat: name of output transformed image
%   iparams: parameters to update
%       (transform_dir: directory of transform)
%           (default, ['.', filesep, 'registration', filesep, 'affine'])
%       (interp_method: interpolation method)
%           ('--cubic')
%           ('--nn', default)
%       (image_format: output format)
%           (default, '--ushort', 16 bits unsigned)
%       (refo_dir: output reference coordinates directory)
%           (default, '.')
%       (iFloat_dir: input floating image directory)
%           (default, '.')
%       (oFloat_dir: output floating image directory)
%           (default, '.')
%       (imsuffix: file suffix)
%           (default, '.nrrd')
%       (padfloat: padding pixels from floating image)
%           (default, [])
%       (transform2ignore: string to exclude transformations to use)
%           (default ignore initial affine, '_pa.list')
%       (xform: transformation command)
%           (default, [])
%
% Returns:
%   status_: command exit status
%
% Notes:
% it assumes you already have all the required transformations generated
%   using cmtk_intfunc

% Default parameters
ibpars = [];
ibpars.transform_dir = ['.', filesep, 'registration', filesep, 'affine'];
ibpars.interp_method = '--nn';
ibpars.image_format = '--ushort';
ibpars.refo_dir = '.';
ibpars.iFloat_dir = '.';
ibpars.oFloat_dir = '.';
ibpars.imsuffix = '.nrrd';
ibpars.padfloat = [];
ibpars.transform2ignore = '_pa.list';
ibpars.xform = [];

if ~exist('iparams', 'var'); iparams = []; end
ibpars = loparam_updater(ibpars, iparams);

status_ = 0;

% clean names (remove .nrrd | ibpars.imsuffix)
refi = strrep(refi, ibpars.imsuffix, '');
refo = strrep(refo, ibpars.imsuffix, '');
iFloat = strrep(iFloat, ibpars.imsuffix, '');
oFloat = strrep(oFloat, ibpars.imsuffix, '');

% find xform folder (finds direct and indirect transformations)
if isempty(ibpars.xform)
    xform = cmtk_findxform(refo, refi, ...
        ibpars.transform_dir, ibpars.transform2ignore);
else
    if ~contains(ibpars.xform, ibpars.transform_dir)
        xform = [ibpars.transform_dir, filesep, ibpars.xform];
    else
        xform = ibpars.xform;
    end
end

if ~isempty(xform)
    status_ = 1;
    
    % parse images
    oFloat = [ibpars.oFloat_dir, filesep, oFloat, '.nrrd'];
    refo = [ibpars.refo_dir, filesep, refo, '.nrrd'];
    iFloat = [ibpars.iFloat_dir, filesep, iFloat, '.nrrd'];

    % writte command and submit
    reformat_arg = ['reformatx -v ', ibpars.image_format, ' ', ibpars.interp_method];

    if ~isempty(ibpars.padfloat)
        reformat_arg = [reformat_arg, ' --pad-floating ', num2str(ibpars.padfloat)];
    end

    st2execute = [reformat_arg, ' -o ', oFloat, ...
        ' --floating ', iFloat, ' ', refo, ' ', xform];

    % correct string to work on cygwin (when using PC)
    if ispc

        % correct drive names
        st2execute = strrep(st2execute, filesep, '/');
        spattern = '\w*(?=:)'; replace = '/cygdrive/${lower($0)}';
        st2execute = regexprep(st2execute, spattern, replace);
        st2execute = strrep(st2execute, ':', '');

    end

    coexecuter(st2execute)
    
end

end
