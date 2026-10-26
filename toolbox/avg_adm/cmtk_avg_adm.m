function cmtk_avg_adm(inputfiles, oref_name, oImDir, ...
    oIMFormat, numericType)
% cmtk_avg_adm: Generate an average-deformation average intensity image
%   based on a set of input xforms using CMTK function 'avg_adm'.
%
% Usage:
%   cmtk_avg_adm(inputfiles, oref_name, oImDir, oIMFormat, numericType)
%
% Args:
%   inputfiles: select files to be used as inputs
%       (text or cell of text matched in the xform folder names)
%       (otherwise it uses all files in the hardcoded input folder)
%		(basically all xforms within 'ixformdir')
%   oref_name: name of target reference image
%		(default, 'nsybIVA_1')
%   oImDir: output directory
%		(default, ['.', filesep, 'average_im'])
%   oIMFormat: output image format ('.nrrd' or '.nii')
%       (default, '.nrrd')
%   numericType: numeric type to output
%       ('--byte (8 bits) --ushort (16), --float (32), --double (64)')
%       (default, '')
%
% Returns:
%   (none; writes the average image and the average xform to disk)
%
% Notes:
% NOTE (known issue, not yet fixed): (1) giving oref_name that already
%   contains the extension makes strrep error; (2) the output is always
%   written with the 'NRRD:' prefix, even with '.nii'; (3) the verbose mode
%   used for coexecuter returns status 1, so 'File Failed' is always printed;
%   (4) it does not stop if no xform files were found.
% home directory needs to be organized as follows:
% 	(subdirectory with raw input images: images)
% 	(subdirectory with transformations: registration)
%		(this in turn should have both 'affine' and 'warp' subdirectories)
%       (by default cmtk functions generate these subdirectories)
% inspired by https://github.com/jefferislab/MakeAverageBrain/commands/avgcmdIterationPadOut.sh
% by default average intensity image is saved in the subdirectory 'average_im'
% by default average deformation is saved in the subdirectory 'average_xform'

if ~exist('inputfiles', 'var')
    inputfiles = [];
end

if ~exist('oref_name', 'var') || isempty(oref_name)
    oref_name = 'nsybIVA_1';
end

if ~exist('oImDir', 'var') || isempty(oImDir)
    oImDir = ['.', filesep, 'average_im'];
end

% hardcoded folder for average transformations
oDir = ['.', filesep, 'average_xform'];

if ~exist('oIMFormat', 'var') || isempty(oIMFormat)
    oIMFormat = '.nrrd';
end

if ~exist('numericType', 'var') || isempty(numericType)
    numericType = '';
end

if ~isempty(numericType)
   numericType = [numericType, ' '];
end

if exist(fullfile(oDir), 'dir') ~= 7
    mkdir(oDir);
end

if exist(fullfile(oImDir), 'dir')~=7
    mkdir(oImDir);
end

if contains(oref_name, oIMFormat)
   oref_name = strrep(oref_name, oIMFormat);
end

% hardcoded input transformations: warp .list folders (optionally filtered
%   by inputfiles) are the deformations that avg_adm will average
ixformdir = ['.', filesep, 'registration', filesep, 'warp'];
ixform = dir(ixformdir);
ixform = str2match('.list', ixform);
ixform = str2match(inputfiles, ixform);
ixform = {ixform.name};
ixformall = [];

fprintf(['Using #', num2str(numel(ixform)), ' images for average brain\n'])
display(ixform')

for i = 1:numel(ixform)
    ixformall = [ixformall, ' ', ...
        ixformdir, filesep, ixform{i}];
end

% build arguments
avg_arg = ['avg_adm --verbose --cubic ', numericType, ...
    '--auto-scale --no-ref-data --pad-out 0']; % --set-padding 0

% add output directory for average xform
command2run = [avg_arg, ' --output-warp ',  oDir, filesep, ...
    'xform_', oref_name];

% add output directory for average image
command2run = [command2run, ' -o NRRD:', oImDir, filesep, ...
    oref_name, oIMFormat];

% add all input xforms
command2run = [command2run, ' ', ixformall];

% display command to run
display(command2run)

% run if outputfile has not been generated
status = 0;

if ~exist([oImDir, filesep, oref_name, oIMFormat], 'file')
    tic
    status = coexecuter(command2run, 2);
    toc
else
    fprintf('*** File already generated *** \n');
end

if status == 0
	fprintf('File succesfully run \n');
else
	fprintf('File Failed \n');
end

end
