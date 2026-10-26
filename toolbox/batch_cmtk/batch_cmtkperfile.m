function batch_cmtkperfile(rIm2sel, serverid, regparams, ...
    fIm2sel, memreq, jobtime, regparams_edits, corenum)
% batch_cmtkperfile: build a registration job from a params script plus edits and run it locally or write a SLURM file.
%   Inputs: the args below. Outputs: no return values; writes <date>_<time>_cmtk.mat
%   (and a .slurm file for 'spock'/'della') into <temporary_dir>/jobsub/regrel.
%
% IMPORTANT: for 'spock'/'della' this function only WRITES the .slurm file.
%   It does not call sbatch, so you must cd to <temporary_dir>/jobsub/regrel
%   and run sbatch on that file yourself.
% IMPORTANT: run it from the main data folder (the folder that contains
%   'images'); that folder is saved as p.cDir and files are searched from it.
%
% Usage:
%   batch_cmtkperfile(rIm2sel, serverid, regparams, ...
%       fIm2sel, memreq, jobtime, regparams_edits, corenum)
%
% Args:
%   rIm2sel: index of reference image to use
%   serverid: server ID 'int', 'spock', 'della'
%       (default, 'spock')
%   regparams: string defining script to generate 
%       registration parameters
%       **deprecated, this variable used to go from 0-7**
%       (default, [], default registration parameters *0*)
%       (refgen_params, specific for ref generation *1*)
%       (seg2fly_params, specific for segment to whole fly registration *3*)
%       (fly2ref_params, specific for whole fly to atlas registration *4*)
%       (ref2ref_params, specific for atals to atlas registration *5*)
%       (float2fixref_params, any im to fixed ref (general) *6*)
%       (fly2ref_multi_params, fly2ref registration for im and mirror im *7*)
%           NOTE: despite older docs, this script sets p.jgate = 0 and
%           p.rgate_ch2 = 0, so it does NOT reformat channel 2 or generate
%           the jacobian by default (use the 'j' and 'rch2' edits).
%   fIm2sel: index of floating image to use
%   memreq: memory requested per job
%   jobtime: time requested per job
%   regparams_edits: edit certain registration steps
%       ({1} = edits finer registration parameters, while {2} edits
%       registration steps)
%   regparams_edits{1}: number (or vector) that defines steps of registration
%       to run (see cmtk_editparams)
%   regparams_edits{2}: string that defines steps of registration
%       to run (see cmtk_editsteps)
%           ('a', do affine)
%           ('~a', do not affine)
%           ('ia', do initial affine)
%           ('w', do warp)
%           ('~w', do not warp)
%           ('j', generate jacobian image)
%           ('~j', do not generate jacobian image)
%           ('rch2', reformat channel 2, from images_ch2)
%           ('rch3', reformat channel 3, from images_ch3)
%           ('rch4', reformat channel 4, from images_ch4)
%           ('~rch2', '~rch3' or '~rch4', reformat channel 1 only)
%           ('redo', redo)
%           ('ar', do affine variant and replace the old affine)
%           ('ar2', do affine variant but keep the old affine)
%           ('~ar', do not do the affine variant)
%           (steps can be combined in one string, e.g. 'a_~w' or 'a_w')
%           NOTE (known issue, not yet fixed): steps are matched by
%           substring, so 'ia' and 'ar' also contain 'a' and also turn
%           p.agate on.
%   corenum: number of cores to request
%   	(default: 4)
% internal variable with important parameters
%   p (controls which files to load, details of server usage, etc)
%         %%%%%% directory related %%%%%%
%        (cDir: current directory)
%           (default, 'pwd')
%        (redo: redo flag)
%           (default, 0)
%        (floatiDir: default floating image directory)
%           (default, ['.', filesep, 'images'])
%        (floatiDir_2: default floating image_ch2 directory)
%           (default, ['.', filesep, 'images_ch2'])
%        (floatImSu: floating image suffix)
%           (default, [])
%        (float2reject: floating image to reject)
%           (default, [])
%        (refiDir: default reference directory)
%           (default, '.')
%        (refImSu: reference image suffix)
%           (default, [])
%         %%%%%% function related %%%%%%
%        (wgate: gate to do warping)
%           (default, 0)
%        (agate: gate to do affine)
%           (default, 1)
%        (jgate: gate to get jacobian)
%           (default, 0)
%        (rgate_ch2: gate to reformat additional channel)
%           (default, 0)
%        (ragate: gate to do affine refinement)
%           (default, 0)
%        (ref2refreg: gate to register the reference image to itself too)
%           (default, 0)
%        (ch2chSu: different suffix for channels, {2} and replaces {1})
%           (default, {'_01.nrrd', '_02.nrrd'})
%        (refcha: reference channel: 1 red; 2 green)
%           (default, 1)
%        (ar: reformat image after each registration stage (affine, warp),
%           so the registered image can be inspected as soon as that stage
%           finishes, not only at the end)
%           (default, 1)
%        (iFloat: mask image used by the affine-refine variant (p.ragate ~= 0),
%           in reference coordinates; only set by fly2ref_params.m)
%           (no default)
%        (iFloat_dir: directory of iFloat)
%           (no default)
%        NOTE (known issue, not yet fixed): p.iFloat and p.iFloat_dir have no
%           default, so the 'ar' edit with a params script that does not define
%           them errors in cmtk_perfile.m.
%        (ref2refreg: gate to register the reference image to itself too,
%           done only by the last job of the array; used to build atlases)
%           (default, 0)
%        (agate/wgate/jgate/rgate_ch2/ragate: see 'function related' above)
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

% NOTE (known issue, not yet fixed): on Windows/Mac the corenum argument is
%   always overwritten by the local worker count (needs the Parallel
%   Computing Toolbox), even when serverid is 'spock' or 'della', so the
%   --cpus-per-task written to the .slurm file is the laptop core count.
if ispc || ismac

    % running locally
    ppobj = parcluster('local');
    corenum = ppobj.NumWorkers;
    clear ppobj
    
else
    
    if ~exist('corenum', 'var') || ...
        isempty(corenum)
        corenum = 4;
    end
    
end

% get scratch (temporary) and bucket (permanent) directories
[~, username, ~, temporary_dir, ~, userdomain] = ...
    user_defined_directories(serverid);

if ~exist(temporary_dir, 'dir')
    
    repo_temp_folder = strrep(which('server_interface'), ...
        'server_interface.m', '');
    disp([temporary_dir, ' directory does not exist using pu_cluster_interface repo folder ', ...
        repo_temp_folder, ' instead'])
    temporary_dir = repo_temp_folder;
    
end
    
if ~exist([temporary_dir, 'jobsub', filesep, 'regrel'], 'dir')
    mkdir([temporary_dir, 'jobsub', filesep, 'regrel']);
end
tDir = [temporary_dir, 'jobsub', filesep, 'regrel'];

% get registration parameters
% load default parameters
iparams = cmtk_paramgen;

% update registration parameters
% the params script (see ./toolbox/cmtk_parameters) runs in this workspace and
%   edits the variables 'p' and 'iparams' defined above.
% NOTE (known issue, not yet fixed): most params scripts start with
%   'global p', which conflicts with the local 'p' defined above (only
%   reg_params_demo, float2fixref_params and refgen_params_newfotb do not);
%   'eval' of 'run <name>' also breaks if the script path contains spaces.
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
% NOTE (known issue, not yet fixed): if no floating or reference image was
%   found, the code still saves the mat file and submits (for a cluster this
%   writes '--array=1-0', which sbatch rejects; locally nothing runs).

% move to the job folder (jobsub/regrel) so the parameter mat file and the
%   .slurm file are written there; cmtk_perfile later loads the mat file
%   from this folder and moves back to p.cDir to find the images.
cd(tDir)

% generate mat and executable file name
param_file = sprintf('%02d', round(clock'));
param_file = [param_file(3:8), '_', param_file(9:14)];
save([param_file, '_cmtk.mat'], ...
    'floatIm', 'floatFol', ...
    'refIm', 'refFol', 'p', ...
    'iparamscell')

% numT = number of jobs (one per SLURM array task / one per local loop
%   iteration); task number taskID (1..numT) picks which floating image
%   (and reference image) cmtk_perfile runs. It is the larger of the two
%   counts so one reference with many floats, or many references with one
%   float, both work.
% NOTE (known issue, not yet fixed): if there are several references and a
%   different number (>1) of floating images, the task indexing in
%   cmtk_perfile (select_files_dirs) fails.
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
%       refiDir, refImSu, float2reject)
%
% Outputs: cell arrays of file names and folders for floating and reference images.
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
%       (default, 'spock')
%   numT: number of jobs
%   memreq: RAM memory to request
%       (default, 12)
%   agate: gate for affine
%   wgate: gate for warping
%   userdomain: domain to use for username
%   jobtime: time requested per job

% NOTE: this function only writes the .slurm file for 'spock'/'della'; it
%   never calls sbatch. Submit it by hand from the folder it was written to.
% NOTE (known issue, not yet fixed): the matlab command written below has no
%   '; exit', so a finished or failed job may keep MATLAB open until the
%   SLURM time limit.
functype = 'cmtk_perfile';

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
        fprintf(fid, 'module load matlab/R2019b\n');
        fprintf(fid, '# Create a local work directory\n');
        fprintf(fid, 'mkdir -p /tmp/$USER-$SLURM_JOB_ID\n');
        fprintf(fid, ['matlab -nodesktop -nodisplay -nosplash -r "', ...
            functype, '(''', name, ''',''', serverid, ''')"\n']);
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
