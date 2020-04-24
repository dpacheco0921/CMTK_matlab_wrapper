function [rTime, cmtk_out_filename] = cmtk_getruntime(strpattern, txt2match)
% cmtk_getruntime: reads slurm output file 
%   and finds job duration (number after string 'Elapsed time is ')
%
% Usage:
%	[rTime, cmtk_out_filename] = ...
%       cmtk_getruntime(strpattern, txt2match)
%
% Args:
%   strpattern: string pattern to find *.slurm files
%   txt2match: pattern of characters to find within *.slurm files

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
       rTime(i, 1) = 0;
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
