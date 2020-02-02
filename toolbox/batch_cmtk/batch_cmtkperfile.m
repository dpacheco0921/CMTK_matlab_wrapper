function batch_cmtkperfile(rIm2sel, serverid, regparams, ...
    fIm2sel, memreq, jobtime, regparams_edits)
% batch_cmtkperfile: Running registration Using MatLab
%
% Usage:
%   batch_cmtkperfile(rIm2sel, serverid, regparams, ...
%       fIm2sel, memreq, jobtime, regparams_edits)
%
% Args:
%   rIm2sel: index of reference image to use
%   serverid: server ID 'int', 'spock', 'della'
%       (deafult, 'spock')
%   regparams: string defining script to generate 
%       registration parameters
%       **deprecated, this varaible used to go from 0-7**
%       (deafult, [], default registration parameters *0*)
%       (refgen_params, specific for ref generation *1*)
%       (seg2fly_params, specific for segment to whole fly registration *3*)
%       (fly2ref_params, specific for whole fly to atlas registration *4*)
%       (ref2ref_params, specific for atals to atlas registration *5*)
%       (float2fixref_params, any im to fixed ref (general) *6*)
%       (fly2ref_multi_params, fly2ref registration for im and mirror im 
%           (reformats 2nd channel and generates jacobian by default) *7*)
%   fIm2sel: index of floating image to use
%   memreq: memory requested per job
%   jobtime: time requested per job
%   regparams_edits: edit certain registration steps
%       ({1} = edits finer registration parameters, while {2} edits
%       registration steps)
%   regparams_edits{1}: string that defines steps of registration
%       to run (see cmtk_editparams)
%   regparams_edits{2}: string that defines steps of registration
%       to run (see cmtk_editsteps)
%           ('a', do affine)
%           ('~a', do not affine)
%           ('a', do affine)
%           ('~a', do not affine)
%           ('ia', do intial affine)
%           ('w', do warp)
%           ('~w', do not warp)
%           ('j', generate jacobian image)
%           ('~j', do not generate jacobian image)
%           ('rch_2', register channel 2, in )
%           ('rch_3', register channel 3)
%           ('rch_4', register channel 4)
%           ('redo', redo)
%           ('ar', do affine variant)
% internal variable with important parameters
%   p (controls which files to load, details of server usage, etc)
%         %%%%%% directory related %%%%%%
%        (cDir: current directory)
%           (deafult, 'pwd')
%        (redo: redo)
%           (deafult, 0)
%        (floatiDir: default floating image directory)
%           (deafult, ['.', filesep, 'images'])
%        (floatiDir_2: default floating image_ch2 directory)
%           (deafult, ['.', filesep, 'images_ch2'])
%        (floatImSu: floating image suffix)
%           (deafult, [])
%        (float2reject: floating image to reject)
%           (deafult, [])
%        (refiDir: default reference directory)
%           (deafult, '.')
%        (refImSu: reference image suffix)
%           (deafult, [])
%         %%%%%% function related %%%%%%
%        (wgate: gate to do warping)
%           (deafult, 0)
%        (agate: gate to do affine)
%           (deafult, 1)
%        (jgate: gate to get jacobian)
%           (deafult, 0)
%        (rgate_ch2: gate to reformat additional channel)
%           (deafult, 0)
%        (ragate: gate to do affine refinement)
%           (deafult, 0)
%        (ref2refreg: gate to register the reference image to itself too)
%           (deafult, 0)
%        (ch2chSu: different suffix for channels, {2} and replaces {1})
%           (deafult, {'_01.nrrd', '_02.nrrd'})
%        (refcha: reference channel: 1 red; 2 green)
%           (deafult, 1)
%        (ar: reformat image after affine registration)
%           (deafult, 1)
% 
% Notes:
%
% it requires that the script is run in the main data folder
% it requires CMKT binaries to be installed as a module in the server or computer independently
% for installation steps see:
%   http://www.nitrc.org/projects/cmtk/
%   https://github.com/dpacheco0921/CMTK_matlab_wrapper (dependencies)
% for usage within cluster (spock della) use:
%   https://github.com/dpacheco0921/pu_cluster_interface, to submit jobs
%
% p.rgate_ch2 & p.floatiDir_2 are passed to iparams within cmtk_perfile.m
% internal scripts modifying params: cmtk_editparams, cmtk_editsteps

% default params
p = [];
p.cDir = pwd;
p.redo = 0;
p.floatiDir = ['.', filesep, 'images'];
p.floatiDir_2 = ['.', filesep, 'images_ch2'];
p.floatImSu = [];
p.float2reject = [];
p.refiDir = '.';
p.refImSu = [];
p.wgate = 0;
p.agate = 1;
p.jgate = 0;
p.rgate_ch2 = 0;
p.ragate = 0;
p.ref2refreg = 0;
p.ch2chSu = {'_01.nrrd', '_02.nrrd'};
p.refcha = 1;
p.ar = 1;

if ~exist('rIm2sel', 'var') || ...
        isempty(rIm2sel)
   rIm2sel = [];
end

if ~exist('fIm2sel', 'var') || ...
        isempty(fIm2sel)
   fIm2sel = [];
end

if ~exist('serverid', 'var') || ...
        isempty(serverid)
    serverid = 'spock';
end

if ~exist('jobtime', 'var') || ...
        isempty(jobtime)
   jobtime = [];
end

if ~exist('memreq', 'var') || ...
        isempty(memreq)
    memreq = 12;
end

if ~exist('regparams', 'var') || ...
        isempty(regparams)
    regparams = [];
end

if ~exist('regparams_edits', 'var') || ...
        isempty(regparams_edits)
    regparams_edits = {[], []};
end

if ispc || ismac
    % running locally
    ppobj = parcluster('local');
    corenum = ppobj.NumWorkers;
    clear ppobj
else
    corenum = 4;
end

% get scratch (temporary) and bucket (permanent) directories
[~, username, ~, temporary_dir, ~, userdomain] = ...
    user_defined_directories(serverid);
if ~exist([temporary_dir, 'jobsub', filesep, 'regrel'], 'dir')
    mkdir([temporary_dir, 'jobsub', filesep, 'regrel']);
end
tDir = [temporary_dir, 'jobsub', filesep, 'regrel'];

% get registration parameters
% load default parameters
iparams = cmtk_paramgen;

% update registration parameters
if ~isempty(regparams)
    eval(['run ' regparams])
end

% modify registration parameters on the go
%   encoded on the decimals of regparams_edits{1}
[p, iparams] = ...
    cmtk_editparams(regparams_edits{1}, p, iparams);

% edit steps to run:
%   encoded as string characters in regparams_edits{2}
[p, iparamscell] = ...
    cmtk_editsteps(regparams_edits{2}, p, iparams);
iparamscell

% Determining how many input files will be run from FolderName
[floatIm, floatFol, refIm, refFol] = ...
    getinputfiles(fIm2sel, rIm2sel, p.floatiDir, p.floatImSu, ...
    p.refiDir, p.refImSu, p.float2reject);
p
cd(tDir)

% generate mat and executable file name
param_file = sprintf('%02d', round(clock'));
param_file = [param_file(3:8), '_', param_file(9:14)];
save([param_file, '_cmtk.mat'], ...
    'floatIm', 'floatFol', ...
    'refIm', 'refFol', 'p', ...
    'iparamscell')

% update fIm2sel based on the final number of floatIm
numT = max([numel(floatIm), numel(refIm)]);

% Executing File
submitjob(param_file, tDir, ...
    username, corenum, serverid, ...
    numT, memreq, p.agate, p.wgate, ...
    userdomain, jobtime)

% Go back to original folder
cd(p.cDir)

end

function [floatIm, floatFol, refIm, refFol] = ...
    getinputfiles(fIm2sel, rIm2sel, floatiDir, floatImSu, ...
    refiDir, refImSu, float2reject)
% getinputfiles: get all files to run
%
% Usage:
%   [floatIm, floatFol, refIm, refFol] = ...
%       getinputfiles(fIm2sel, rIm2sel, floatiDir, floatImSu, ...
%       refiDir, refImSu)
%
% Args:
%   fIm2sel: indeces of floating images to use
%   rIm2sel: indeces of reference image to use (if more than one is available)
%   floatiDir: floating image directory
%   floatImSu: floating image suffix
%   refiDir: reference image directory
%   refImSu: reference image suffix
%   float2reject: floating images to reject

% get floatIm for the default folder organization
floatIm = rdir([floatiDir, filesep, '*.nrrd']);
floatIm = str2match(floatImSu, floatIm);
floatIm = str2rm(float2reject, floatIm);
floatIm = {floatIm.name}';
[floatIm, floatFol] = split_path(floatIm);

% only run files defined by fIm2sel if not empty
if ~isempty(fIm2sel)
    
    if ischar(fIm2sel)
        fIm2sel = str2double(fIm2sel);
    end
    
    fprintf(['Only processing the following floatIms: ', ...
        num2str(fIm2sel), '\n'])
    floatIm = floatIm(fIm2sel);
    floatFol = floatFol(fIm2sel);
    
end

if ~isempty(floatIm)
    
    fprintf(['Files to preprocess: ', ...
        num2str(numel(floatIm)), '\n'])
    
    for f_Num = 1:numel(floatIm)
        
        fprintf([floatFol{f_Num}, ' ', ...
            floatIm{f_Num}, '\n'])
        clear TempS
        
    end
    
else
    
    fprintf('No files to preprocess\n');
    
end

% get refIm for the default folder organization
refIm = rdir([refiDir, filesep, '*.nrrd']);
refIm = str2match(refImSu, refIm);
refIm = {refIm.name}';
[refIm, refFol] = split_path(refIm);

if ~isempty(rIm2sel)
    
    if ischar(rIm2sel)
        rIm2sel = str2double(rIm2sel);
    end
    
    fprintf(['Only processing the following refIms: ', ...
        num2str(rIm2sel), '\n'])
    refIm = refIm(rIm2sel);
    refFol = refFol(rIm2sel);
    
end

if ~isempty(refIm)
    
    fprintf(['References to use: ', ...
        num2str(numel(refIm)), '\n'])
    
    for f_Num = 1:numel(refIm)
        
        fprintf([strrep(refFol{f_Num}, ...
            filesep, ' '), ' ', refIm{f_Num}, '\n'])
        clear TempS
        
    end
    
else
    
    fprintf('No Reference image\n');
    
end

fprintf('Done\n')

end

function submitjob(name, tDir, ...
    username, corenum, serverid, ...
    numT, memreq, agate, wgate, ...
    userdomain, jobtime)
% submitjob: submit jobs to rondo/spock/della
%
% Usage:
%   submitjob(name, tDir, ...
%       username, corenum, serverid, ...
%       numT, memreq, agate, wgate, ...
%       userdomain, jobtime)
%
% Args:
%   name: name of matfile with parameters to use
%   tDir: target directory
%   username: used to update directories to use
%   corenum: maximun number of cores to use per task
%   serverid: server ID 'int', 'spock', 'della'
%       (deafult, 'spock')
%   numT: number of jobs
%   memreq: RAM memory to request
%       (deafult, 12)
%   agate: gate for affine
%   wgate: gate for warping
%   userdomain: domain to use for username
%   jobtime: time requested per job

functype = {'cmtk_perfile.m'};

if isempty(jobtime)
    % controlling jobtime depending on tipe of job sent
    if wgate == 1 && agate == 0
        jobtime = 12;
    elseif agate == 0 && wgate == 0
        jobtime = 2;
    else
        jobtime = 5;
    end
end

switch serverid
           
    case {'spock', 'della'}
        
        eval(['username = username.', serverid, ';']);
        
        % run on cluster
        % write a slurm file
        LogFileName = fullfile([name, '.slurm']);
        if exist(LogFileName, 'file')
            delete(LogFileName)
        end
        
        % open/create log file
        fid = fopen(LogFileName, 'a+');
        fprintf(fid, '#!/bin/bash\n\n');
        fprintf(fid, ['#SBATCH --cpus-per-task=', num2str(corenum), '\n']);
        fprintf(fid, ['#SBATCH --time=', num2str(jobtime), ':00:00\n']);
        fprintf(fid, ['#SBATCH --mem=', num2str(memreq), '000\n']);
        fprintf(fid, '#SBATCH --mail-type=END\n');
        fprintf(fid, ['#SBATCH --mail-user=', username, userdomain, '\n']);
        fprintf(fid, ['#SBATCH --array=1-', num2str(numT), '\n\n']);

        fprintf(fid, 'module load cmtk/3.3.1\n');
        fprintf(fid, 'module load matlab/R2018b\n');
        fprintf(fid, '# Create a local work directory\n');
        fprintf(fid, 'mkdir -p /tmp/$USER-$SLURM_JOB_ID\n');
        fprintf(fid, ['matlab -nodesktop -nodisplay -nosplash -r "', ...
            functype(1:end-2),'(''', name, ''',''', serverid, ''')"\n']);
        fprintf(fid, '# Cleanup local work directory\n');
        fprintf(fid, 'rm -rf /tmp/$USER-$SLURM_JOB_ID\n');
        
        % close log file
        fclose(fid);
        
    otherwise % internal run
        
        cd(tDir)
        for f_run = 1:numT
            cmtk_perfile(name, serverid, f_run);
            fprintf('\n\n **************************************************** \n\n')
            cd(tDir)
        end

end

end
