function cmtk_avgtool(iIm, iDir, oName, oDir, ...
	oIm, eiIm, oIm_format)
% cmtk_avgtool: Generates average image (see oIm) of 
%   selected iIm using CMTK function 'average_images'.
%
% Usage:
%   cmtk_avgtool(iIm, iDir, oName, oDir, ...
%		oIm, eiIm, oIm_format)
%
% Args:
%   iIm: files to select as inputs
%   iDir: input directory
%       (default, '.')
%   oName: name of output image
%   oDir: output directory
%       (default, '.')
%   oIm: type of image to compute
% 		('--avg': average, default)
% 		('--var': variance)
% 		('--stdev': std image)
% 		('--zscore': z-score image)
% 		('--entropy': pixel-by-pixel population entropy image)
%   eiIm: extra string to select matching input files
%       (default, [])
% 	oIm_format
% 		('--float': single-precision float, default)
% 		('--double': double-precision float)
% 
% Notes:
% other preprocessing steps to add:
% '--log' '-l'
% '--abs' '-a'
% '--normalize-mean-stdev' or '-n'

% deafult params
if ~exist('iIm', 'var'); iIm = []; end

if ~exist('iDir', 'var') || isempty(iDir)
    iDir = '.';
end

if ~exist('oDir', 'var') || isempty(oDir)
    oDir = '.';
end

if ~exist('oIm', 'var') || isempty(oIm)
    oIm = '--avg';
end

if ~exist('oIm_format', 'var') || isempty(oIm_format)
    oIm_format = '--float';
end

% extra filter for iIm
if ~exist('eiIm', 'var') || isempty(eiIm); eiIm = []; end

% find input files
f2use = rdir([iDir, filesep, '*.nrrd']);
f2use = {f2use.name};
f2use = str2match(iIm, f2use);

if ~isempty(eiIm)
	f2use = str2match(eiIm, f2use);
end

% set main average arguments
st2execute = ['average_images -v ', oIm, ' ', oIm_format, ...
    ' -o ', [oDir, filesep], oName, '.nrrd'];

% add all input files used to generate oIm
for i = 1:numel(f2use)
	st2execute = [st2execute, ' ', f2use{i}];
end

% perform averaging using cmtk tool
coexecuter(st2execute);

fprintf('Done\n')

end
