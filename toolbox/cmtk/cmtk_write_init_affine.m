function cmtk_write_init_affine(iparams, oDir)
% cmtk_write_init_affine: write initial_affine text file
% 
% Usage:
%   cmtk_write_init_affine(iparams, oDir)
%
% Args:
%   iparams: deafult initial affine settings
%       (xlate, [0 0 0])
%       (rotate, [0 0 0])
%       (scale, [0 0 0])
%       (shear, [0 0 0])
%       (center, [0 0 0])
%   oDir: output directory
%
% Notes
% 2021-01-20: upated default scale to [1 1 1].

cparams.xlate = [0 0 0];
cparams.rotate = [0 0 0];
cparams.scale = [1 1 1];
cparams.shear = [0 0 0];
cparams.center = [0 0 0];

if ~exist('iparams', 'var'); iparams = []; end
cparams = loparam_updater(cparams, iparams);

mkdir(oDir)
if exist([oDir, filesep, 'registration'], 'file')
    fprintf('Overwritting registration\n')
    delete([oDir, filesep, 'registration']); 
end

% open/create log file
fid = fopen([oDir, filesep, 'registration'], 'a+');

% write file
fprintf(fid, '! TYPEDSTREAM 2.4\n\n');
fprintf(fid, 'affine_xform {\n');
fprintf(fid, ['\txlate ', num2str(cparams.xlate(1)),' ', ...
    num2str(cparams.xlate(2)),' ', num2str(cparams.xlate(3)),'\n']);
fprintf(fid, ['\trotate ', num2str(cparams.rotate(1)),' ', ...
    num2str(cparams.rotate(2)),' ', num2str(cparams.rotate(3)),'\n']);
fprintf(fid, ['\tscale ', num2str(cparams.scale(1)),' ', ...
    num2str(cparams.scale(2)),' ', num2str(cparams.scale(3)),'\n']);
fprintf(fid, ['\tshear ', num2str(cparams.shear(1)),' ', ...
    num2str(cparams.shear(2)),' ', num2str(cparams.shear(3)),'\n']);
fprintf(fid, ['\tcenter ', num2str(cparams.center(1)),' ', ...
    num2str(cparams.center(2)),' ', num2str(cparams.center(3)),'\n']);
fprintf(fid, '}\n\n');
fclose(fid);

% make it compatible to unix format
unix2dos([oDir, filesep, 'registration'], 1)

end
