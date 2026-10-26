function [rTime, cmtk_out_filename] = cmtk_getruntime(strpattern, txt2match)
% cmtk_getruntime: reads slurm output file
%   and finds job duration (number after string 'Elapsed time is ')
%
% Usage:
%	[rTime, cmtk_out_filename] = ...
%       cmtk_getruntime(strpattern, txt2match)
%
% Args:
%   strpattern: text that must appear in the output file names
%       (default, [], every file in the current folder)
%   txt2match: text printed right before the run time
%       (default, 'Elapsed time is ')
%
% Returns:
%   rTime: run time in whole seconds per file (NaN if the text was not
%       found exactly once), sorted by the job number in the file name
%   cmtk_out_filename: file names, in the same sorted order as rTime
%
% Notes:
% NOTE (known issue, not yet fixed): the default pattern also lists folders
%   and non-slurm files, an empty file makes the function error, and job
%   numbers are parsed with the same fragile rule as cmtk_read_slurm_out.

if ~exist('strpattern', 'var') || isempty(strpattern)
    strpattern = [];
end

if ~exist('txt2match', 'var') || isempty(txt2match)
    txt2match = 'Elapsed time is ';
end

cmtk_out_filename = rdir(['.', filesep, '*', strpattern, '*']);
cmtk_out_filename = {cmtk_out_filename.name};
cmtk_out_filename = strrep(cmtk_out_filename, ['.', filesep], '');
if size(cmtk_out_filename, 2) > 1
   cmtk_out_filename = cmtk_out_filename'; 
end

rTime = zeros(numel(cmtk_out_filename), 1);
fileIdx = zeros(numel(cmtk_out_filename), 1);
for i = 1:numel(cmtk_out_filename)
    
    fprintf('*')
    
    % read text file
    textall = textread(cmtk_out_filename{i}, ...
        '%s', 'whitespace', '', 'bufsize', 10^5);
    textsplit = regexp(textall{1}, txt2match, 'split');
    clear textall
    
    % get run time
    if ~isempty(textsplit) && numel(textsplit) == 2
       preTime = num2str(strrep(textsplit{2}, ' seconds.', ''));
       preTime = strsplit2(preTime, '.');
       rTime(i, 1) = str2double(preTime{1});
    else
       rTime(i, 1) = nan;
    end
    
    % get Idx
    if ~isempty(strfind(cmtk_out_filename{i}, 'slurm'))
        idx = regexp(cmtk_out_filename{i}, '\_\w*\.', 'match');
        idx = idx{1}(2:end-1);
        idx = str2num(idx);
    else
        preidx = strsplit2(cmtk_out_filename{i}, '.');
        idx = str2num(preidx{end});
    end
    
    fileIdx(i, 1) = idx;
    clear textall str_idx idx
    
end

[~, idx] = sort(fileIdx);
rTime = rTime(idx, 1);
cmtk_out_filename = cmtk_out_filename(idx, 1);

end
