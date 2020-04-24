function [fileIdx, status, out_filename] = ...
    cmtk_read_slurm_out(strpattern, txt2match)
% cmtk_read_slurm_out: reads slurm output file 
%   and finds text matching 'txt2match'
%
% Usage:
%	[fileIdx, status, fileName] = ...
%       cmtk_read_slurm_out(strpattern, txt2match)
%
% Args:
%   strpattern: string pattern to find *.slurm files
%   txt2match: pattern of characters to find within *.slurm files

if ~exist('strpattern', 'var') || isempty(strpattern)
    strpattern = '*';
end

if ~exist('txt2match', 'var') || isempty(txt2match)
    txt2match = {'DUE TO TIME LIMIT', 'Elapsed time is '};
end

% find all the slurm files with this suffix
cmtk_out_filename = rdir(['.', filesep, strpattern, '.slurm']);
cmtk_out_filename = {cmtk_out_filename.name};
cmtk_out_filename = strrep(cmtk_out_filename, ['.', filesep], '');
if size(cmtk_out_filename, 2) > 1
   cmtk_out_filename = cmtk_out_filename'; 
end

fileIdx = zeros(numel(cmtk_out_filename), 1);
status = zeros(numel(cmtk_out_filename), 1);
out_filename = cell(numel(cmtk_out_filename), 1);

for i = 1:numel(cmtk_out_filename)
    
    fprintf('*')
    
    textall = textread(cmtk_out_filename{i}, ...
        '%s', 'whitespace', '', 'bufsize', 10^5);
    
    if isempty(textall)
        str_idx = 1;
    else
        str_idx = [~isempty(strfind(textall{1}, txt2match{1})) || ...
            isempty(strfind(textall{1}, txt2match{2}))];
    end
    
    % get file idx
    if ~isempty(strfind(cmtk_out_filename{i}, 'slurm'))
        idx = regexp(cmtk_out_filename{i}, '\_\w*\.', 'match');
        idx = idx{1}(2:end-1);
        idx = str2num(idx);
    else
        idx = strsplit2(cmtk_out_filename{i}, '.');
        idx = idx{end};
        idx = str2num(idx);
    end
    
    fileIdx(idx) = idx;
    out_filename{idx} = cmtk_out_filename{i};
    
    if str_idx
       status(idx) = 1;
    else
       status(idx) = 0;
    end
    
    clear textall str_idx
    
end

fprintf('\nindeces where txt2match was found\n\n')
fjobs = [];

for i = find(status == 1)'
    fjobs = [fjobs, ',', num2str(i)];
end

fprintf(fjobs)

end
