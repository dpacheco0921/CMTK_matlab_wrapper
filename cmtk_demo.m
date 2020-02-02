%% Move to folder and Download demo data

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
