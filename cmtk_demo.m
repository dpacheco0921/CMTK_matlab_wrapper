% cmtk_demo: demo script (run section by section); downloads demo data, runs affine and
%   affine + warp registration locally with batch_cmtkperfile, then shows the cluster helpers.
%   Inputs: none (needs internet). Outputs: ./demodata/{registration,reformatted} folders.
% REQUIREMENT: the repo (including ./toolbox and its subfolders) and the
%   dependencies in README.md (CMTK, pu_cluster_interface, ...) must be on the
%   MATLAB path before running, e.g. addpath(genpath(<repo folder>)). This script does not add them.
% NOTE: user_defined_directories (from pu_cluster_interface) must also work for serverid 'int'.

%% Move to folder and Download demo data
% Expected output: a ./demodata folder inside the repo containing demodata.zip, the reference
%   image 'nsybIVAidownsampled.nrrd' and an 'images' folder with the floating images.
% NOTE: the script stays in ./demodata afterwards, and re-downloads the zip every time it runs.
% NOTE: README.md calls the reference 'nsybIVAidownsample.nrrd' but the actual (and
%   reg_params_demo.m) name is 'nsybIVAidownsampled.nrrd'.

% move to repo directory
tDir = strrep(which('cmtk_demo'), 'cmtk_demo.m', '');
cd(tDir)

% download demo data
url = 'https://www.dropbox.com/s/6bmtpxkp6rc1v5q/demodata.zip?dl=1';
filename = 'demodata.zip';

if ~exist('demodata', 'dir')
    mkdir('demodata')
end
cd demodata

outfilename = websave(filename, url);
unzip(outfilename);
clear url outfilename

%% Test batch_cmtkperfile
% Expected output: with serverid 'int' each floating image is registered one after another on
%   this computer; progress text is printed, and the transforms appear in
%   ./registration/affine (step 1) and ./registration/warp (step 2), with reformatted images
%   in ./reformatted. A job .mat file is written to <temporary_dir>/jobsub/regrel.

% define the registration parameter script to use to edit the default
%   parameters (there are many example that I have used before with 
%   some comments at ./toolbox/cmtk_parameters)
reg_params_in = 'reg_params_demo.m';

% main batch function: 'batch_cmtkperfile'
%batch_cmtkperfile(rIm2sel, serverid, regparams, ...
%    fIm2sel, memreq, jobtime, regparams_edits)
% 
% to run locally (as oppose to submit to a cluster) yuo only need to
% provide:
serverid = 'int';
% select the indeces of files to use (in case you dont want to use all within the main directory)
refenceImages2use = [];
floatingImages2use = [];
% make some edits to registration parameters defined by 'reg_params_demo'
%   ({1} numeric codes for cmtk_editparams, {2} step codes for cmtk_editsteps)
%   (this line is overwritten by the 'a_~w' / 'a_w' assignments below)
regparams_edits = {[], []};
% memreq and jobtime are necessary only if submitting to a cluster.

% 1) run affine
regparams_edits = {[], 'a_~w'};
batch_cmtkperfile(refenceImages2use, serverid, ...
    reg_params_in, floatingImages2use, ...
    [], [], regparams_edits)

% 2) run affine + warping
regparams_edits = {[], 'a_w'};
batch_cmtkperfile(refenceImages2use, serverid, ...
    reg_params_in, floatingImages2use, ...
    [], [], regparams_edits)

%% When using a cluster/server
% Expected output: fileIdx/status say which *.slurm output files finished (or hit the time
%   limit); run_time lists the 'Elapsed time is' value from each *.slurm output file.
% NOTE: the job id '18663522*' below is from the author's cluster; replace it with your own
%   or this section finds no files (and may error), so do not run it with 'Run All'.
% find jobs that finished:
slurmfile = '18663522*';
[fileIdx, status, slurmfile_name] = cmtk_read_slurm_out(slurmfile);

% find out what was the running time for each *slurm file
slurmfile = '18663522*';
[run_time, slurmfile_name] = cmtk_getruntime(slurmfile);
fprintf('Time elapsed\n')
run_time
