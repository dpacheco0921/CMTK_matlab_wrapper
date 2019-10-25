function cmtk_avg_adm(refiter, inputfiles, refi, oImDir)
% cmtk_avg_adm: Generate an average-deformation average intensity image
%   based on a set of input xforms using CMTK function 'avg_adm'.
%
% Usage:
%   cmtk_avg_adm(refiter, inputfiles, refi, oImDir)
%
% Args:
%   refiter: interation number
%       (defines which seed reference brain will use for current averaging)
%   inputfiles: select files to be used as inputs
%       (otherwise it uses all files in the hardcoded input folder)
%		(basically all xforms within 'ixformdir')
%   refi: name of target reference image
%		(default, 'nsybIVA')
%   oImDir: output directory
%		(default, ['.', filesep, 'average_im'])
%
% Notes:
% home directory needs to be organized as follows:
% 	(subdirectory with raw input images: images)
% 	(subdirectory with transformations: registration)
%		(this in turn should have both 'affine' and 'warp' subdirectories)
%       (by default cmtk functions generate these subdirectories)
% inspired by https://github.com/jefferislab/MakeAverageBrain
% by default average intensity image is saved in the subdirectory 'average_im'
% by default average deformation is saved in the subdirectory 'average_xform'

if ~exist('inputfiles', 'var'); inputfiles = []; end
if ~exist('refi', 'var') || isempty(refi)
    refi = 'nsybIVA';
end
if ~exist('oImDir', 'var') || isempty(oImDir)
    oImDir = ['.', filesep, 'average_im'];
end
% hardcoded folder for average transformations
oDir = ['.', filesep, 'average_xform'];

if exist(fullfile(oDir), 'dir') ~= 7
    mkdir(oDir);
end

if exist(fullfile(oImDir), 'dir')~=7
    mkdir(oImDir);
end

% hardcoded input transformations
ixformdir = ['.', filesep, 'registration', filesep, 'warp'];
ixform = dir(ixformdir);
ixform = str2match('.list', ixform);
ixform = str2match(inputfiles, ixform);
ixform = {ixform.name};
ixformall = [];

for i = 1:numel(ixform)
    ixformall = [ixformall, ' ', ...
        ixformdir, filesep, ixform{i}];
end

% build arguments
avg_arg = ['avg_adm --verbose --cubic --ushort ', ...
    '--auto-scale --no-ref-data --pad-out 0'];

% add output directory for average xform
command2run = [avg_arg, ' --output-warp ',  oDir, filesep, ...
    'xformreference_', num2str(refiter)];

% add output directory for average image
command2run = [command2run, ' -o NRRD:', oImDir, filesep, ...
    refi, '_', num2str(refiter), '.nrrd'];

% add all input xforms
command2run = [command2run, ' ', ixformall];

% display command to run
display(command2run)

% run if outputfile has not been generated
if ~exist([oImDir, filesep, refi, '_', num2str(refiter), '.nrrd'], 'file')
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