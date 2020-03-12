function cmtk_perfile(paramfile, serverid, IntID)
% cmtk_perfile: function that runs runs cmtk (using cmtk_intfunc)
%   on a given folder (all files within 'images folder + reference image')
%
% Usage:
%   cmtk_perfile(paramfile, serverid, IntID)
%
% Args:
%   paramfile: mat file with all registration parameters
%   serverid: server id
%   IntID: job index manually inserted
%
% Notes:
% 1) this function: 
%   1.1) does initial affine, affine, and warping of floating images to
%   reference image (defined in iparamscell).
%   1.2) for each step it also generates refformated images (applies transforms to floating images)
%   1.3) in additions, a variant of the affine registration is (set p.ragate ~= 0):
%       register reference images to get
%       a first approximation, applies a mask (to remove brain parts to not
%       consider for registration), and then registerts again.
%       this requires 2 fields in p
%       p.iFloat: mask image (in reference coordinates usually a brain
%       region), example 'nsybIVAi_cbrain_dil'
%       p.iFloat_dir: directory of p.iFloat.
% 2) to reformat another channel:
%   set p.rgate_ch2 to 1
%   define the channel suffix to replace p.ch2chSu ({2} replaces {1});
% 3) to generate jacobian:
%   set p.jgate to 1 (used for dbm, see nsybIVAi_dbm.m)
% 4) to register refIm to refIm:
%   set p.refgate to 1 (used when generating atlases)

timeint = tic;
fprintf('\nRunning registration of volumes using CMTK\n');

% Default parameters
global sep

osDir = pwd; % jobfile directory
sep = filesep;

if exist('IntID', 'var')
    
    taskID = IntID;
    load(['.', sep, paramfile, '_cmtk.mat'], ...
        'floatIm', 'floatFol', 'refIm', 'refFol', 'p', 'iparamscell')
    
else
    
    [~, ~, ~, tempfiledir, ~] = ...
        user_defined_directories(serverid);
    tDir = [tempfiledir, sep, 'jobsub', sep, 'regrel'];
    load([tDir, sep, paramfile, '_cmtk.mat'], ...
        'floatIm', 'floatFol', 'refIm', 'refFol', 'p', 'iparamscell')
    % p.Cdir is updated to the one saved in the _impre.mat file
    taskID = getclus_taskid(serverid);
    
end

% Decide if it runs ref2ref reg on this job,
%   only does it on the last job per array of jobs
refgate = (taskID == numel(floatIm)) & p.ref2refreg;
if refgate
    fprintf('\n*** Running also ref2ref registration ***\n');
else
    fprintf('\n*** Not Running ref2ref registration ***\n');    
end
    
% Selecting file to run and the parameters
fprintf('\nStep (1): Move to data folder and run selected file\n')

% move to raw data folder
if ~exist(p.cDir, 'dir')
    warning(['p.cDir does not exist, ', ...
        '*_cmtk.mat file was generated in different computer or cluster'])
    warning('run batch_cmtkperfile locally')
end
cd(p.cDir)

% pick selected file depending on taskID or IntID
[floatIm, iDir, refIm, rfDir, iparams] = ...
    select_files_dirs(taskID, floatIm, ...
    floatFol, refIm, refFol, iparamscell);
fprintf(['floating image : ', floatIm,'\n'])
fprintf(['refIm : ', refIm,' \n'])
fprintf('parameters to use: \n')

iparams
p

% run CMTK (using cmtk_intfunc)
% cmtk_intfunc(func2use, redo, iIm, oIm, ...
%       refIm, xform, oDir, refDir, iDir, aDir, xDir, iparams)
fprintf('\nStep (2): running cmtk functions\n')

% run just external initial affine (make_initial_affine)
cmtk_intfunc('ia',  p.redo, floatIm, [], refIm, ...
    [], [], rfDir, iDir, [], [], iparams);

% retrieve initial affine reg
if iparams.initf2use
    iparams.rLevel = 'ia'; 
    cmtk_intfunc('r', p.redo, floatIm, [], refIm, ...
        [], [], rfDir, iDir, [], [], iparams);
end

% run affine and initial affine (using a option from registration(x) functions)
if p.agate == 1
    
    out_aff1 = cmtk_intfunc('a',  p.redo, floatIm, [], refIm, ...
        [], [], rfDir, iDir, [], [], iparams);
    iparams.rLevel = 'a';
    
    % retrieve affine reg
    if p.ar == 1
        cmtk_intfunc('r', p.redo, floatIm, [], refIm, ...
            [], [], rfDir, iDir, [], [], iparams);
    end
    
end

% run affine refinement (so far works for all w or wm images)
if p.ragate ~= 0 && ...
        ~isempty(p.iFloat) && ~isempty(p.iFloat_dir)
    
    % default params (may pass to batch_cmtk)
    fprintf('***** Running Affine-refine with mask registration *****\n')
    refIm_ = strrep(refIm, '.nrrd', '');
    floatIm_ = strrep(floatIm, '.nrrd', '');
    tsuff = '_wcb';
    xDir = ['registration', filesep, 'affine'];
    newfloatIm = strrep(floatIm_, '_w', tsuff);
    rparams.iFloat_dir = p.iFloat_dir;
    rparams.refo_dir = iDir;
    rparams.oFloat_dir = iDir;
    rparams.transform_dir = ['.', filesep, xDir];
    rparams.xform = ['--inverse ', rparams.transform_dir, ...
        filesep, refIm_, '_', floatIm_, '_', out_aff1{1}];
    
    % reformat mask to floatIm coordinates
    if ~exist([rparams.oFloat_dir, filesep, ...
            newfloatIm, '.nrrd'], 'file')
        cmtk_xform_im(refIm_, floatIm_, ...
            p.iFloat, strrep(floatIm_, '_w', tsuff), rparams)
        % use mask to make a masked-image
        operationIm2Im(floatIm_, newfloatIm, ...
            newfloatIm, [], 3, iDir, iDir, iDir);
    end
    
    % copy registration to initial affine
    if ~exist([xDir, filesep, refIm_, '_', ...
            newfloatIm, '_pa.list'], 'dir')
        %xDir_ = dir([xDir, filesep, refIm_, '_', floatIm_, '*.list']);
        regparams = cmtk_read_registration(...
            [strrep(rparams.xform, '--inverse ', ''), ...
            filesep, 'registration']);
        cmtk_write_init_affine(regparams, [xDir, filesep, ...
            refIm_, '_', newfloatIm, '_pa.list'])
    end
    
    % generate affine with new float image
    if ~exist([xDir, filesep, refIm_, '_', ...
            newfloatIm, '_', strrep(out_aff1{1}, ...
            '9icom', '9initcom')], 'dir')
        
        iparams_ = iparams; iparams_.initf2use = 1;
        out_aff2 = cmtk_intfunc('a', p.redo, ...
            [newfloatIm, '.nrrd'], [], refIm, ...
            [], [], rfDir, iDir, [], [], iparams_);
        iparams.rLevel = 'a';
        
        % retrieve affine reg
        if p.ar == 1
            cmtk_intfunc('r', p.redo, ...
                [newfloatIm, '.nrrd'], [], refIm, ...
                [], [], rfDir, iDir, [], [], iparams_);
        end
        
        % replace affine
        if p.ragate == 1
            
            fprintf('***** Replace old affine registration *****\n')
            axform2copy = dir([xDir, filesep, ...
                refIm_, '_', newfloatIm, '*', out_aff2{1}]);
            axform2copy = [xDir, filesep, ...
                axform2copy.name, filesep, 'registration'];
            axform2rep = dir([xDir, filesep, ...
                refIm_, '_', floatIm_, '*', out_aff1{1}]);
            axform2rep = [xDir, filesep, ...
                axform2rep.name, filesep, 'registration'];
            copyfile(axform2copy, axform2rep)
            
            % retrieve affine reg
            if p.ar == 1
                cmtk_intfunc('r', 1, floatIm, [], refIm, ...
                    [], [], rfDir, iDir, [], [], iparams);
            end
            
        else
            
            % continue with the new image and
            floatIm = [newfloatIm, '.nrrd'];
            iparams.initf2use = 1;
            
        end
        
    end
end

% run warp
if p.wgate == 1
    
    iparams.rLevel = 'w';
    cmtk_intfunc('w', p.redo, floatIm, [], refIm, ...
        [], [], rfDir, iDir, [], [], iparams);
    
    % retrieve warp reg
    cmtk_intfunc('r', p.redo, floatIm, [], refIm, ...
        [], [], rfDir, iDir, [], [], iparams);
    
end

% run jacobian (after rigid and non-rigid)
if p.jgate == 1
    % retrieve jacobian
    cmtk_intfunc('rj', p.redo, floatIm, [], refIm, ...
        [], [], rfDir, iDir, [], [], iparams);
end

% run reformatting of extra channel
% requires images to be in images_ch2
if p.rgate_ch2 == 1
    
    iDir_ch2 = strrep(iDir, p.floatiDir, p.floatiDir_2);
    iparams.rgate_ch2 = p.rgate_ch2;
    iparams.ch2chSu = p.ch2chSu;
    
    % retrieve affine reg
    if p.agate == 1 && p.wgate == 0
        iparams.rLevel = 'a';
        cmtk_intfunc('r', p.redo, floatIm, [], refIm, ...
            [], [], rfDir, iDir_ch2, [], [], iparams) 
    end
    
    % retrieve warp reg
    if p.wgate == 1
        iparams.rLevel = 'w';
        cmtk_intfunc('r', p.redo, floatIm, [], refIm, ...
            [], [], rfDir, iDir_ch2, [], [], iparams) 
    end
    
end

% register reference image too
if refgate
    
    % run affine
    cmtk_intfunc('a', p.redo, refIm, [], refIm, ...
        [], [], rfDir, rfDir, [], [], iparams);
    
    % run warp
    cmtk_intfunc('w', p.redo, refIm, [], refIm, ...
    [], [], rfDir, rfDir, [], [], iparams);
    
    % retrieve warp reg
    iparams.rLevel = 'w';
    cmtk_intfunc('r', p.redo, refIm, [], refIm, ...
    [], [], rfDir, rfDir, [], [], iparams);

end

cd(osDir);
toc(timeint);

end

function [floatIm, iDir, refIm, rfDir, iparams] = ...
    select_files_dirs(taskID, floatIm, floatFol, ...
    refIm, refFol, iparamscell)
% select_files_dirs: to select directories, files & iparams per taskID
%
% Usage:
%   [floatIm, iDir, refIm, rfDir, iparams] = ...
%       select_files_dirs(taskID, floatIm, floatFol, ...
%       refIm, refFol, iparamscell)
%
% Args:
%   taskID: index (from cluster or manual)
%   floatIm: set of floating images (cell)
%   floatFol: floating image folders (cell)
%   refIm: set of reference images (cell)
%   refFol: reference image folders (cell)
%   iparamscell: set of iparams (cell)

iDir = [];
rfDir = [];

% select ref image and its directory
if iscell(refIm)
    if numel(refIm) == numel(floatIm)
        refIm = refIm{taskID};
        rfDir = refFol{taskID};
    elseif numel(refIm) > numel(floatIm) && numel(floatIm) == 1
        refIm = refIm{taskID};
        rfDir = refFol{taskID};
    elseif numel(refIm) == 1 || numel(refIm) < numel(floatIm)
        refIm = refIm{1};
        rfDir = refFol{1};
    end
end

% select float image and its directory
if numel(floatIm) == 1
    floatIm = floatIm{1};
    iDir = floatFol{1};
else
    floatIm = floatIm{taskID};
    iDir = floatFol{taskID};
end

% select set of parameters
if iscell(iparamscell)
    iparams = iparamscell{taskID};
else
    iparams = iparamscell;
end

end
