%% Move to folder and Download demo data
tDir = strrep(which('cmtk_demo'), 'cmtk_demo.m', '');
cd(tDir)

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

% run affine
reg_params_in = 'reg_params_demo.m';
batch_cmtkperfile([], 'int', reg_params_in, [], [], [], {[], 'a_~w'})

% run affine + warping
batch_cmtkperfile([], 'int', reg_params_in, [], [], [], {[], 'a_w'})

