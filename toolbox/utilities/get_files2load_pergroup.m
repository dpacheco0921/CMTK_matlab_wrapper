function [f2r_dir, f2r_im, group_idx] = ...
    get_files2load_pergroup(inputfiles, iDir, fsuffix)
% get_files2load_pergroup: list the files that belong to each group.
%   Input: cell of per-group name patterns, directory, file suffix.
%   Output: file directories, file names (one list for all groups) and the
%   indices of each group within that list.
%
% Usage:
%   [f2r_dir, f2r_im, group_idx] = ...
%       get_files2load_pergroup(inputfiles, iDir, fsuffix)
%
% Args:
%   inputfiles: cell with one entry per group (e.g. two groups); each entry is
%       a string or cell of strings, matched as substrings of the file names
%   iDir: input directory
%   fsuffix: suffix of files to find
%
% Returns:
%   f2r_dir: file directories, cell [n_all_files, 1] (groups stacked in order)
%   f2r_im: file names, cell [n_all_files, 1]
%   group_idx: cell {1, n_groups}; each holds the row indices of that group
%       within f2r_dir / f2r_im
%
% Notes:
% NOTE (known issue, not yet fixed): if a group matches no file, the
%   function errors at idx_vect(end) with an unhelpful message. Patterns
%   are substring matches, so 'a1' also matches 'a10' and a file can end
%   up in two groups; this is not checked.

f2r_dir = [];
f2r_im = [];
k = 0;

for i = 1:numel(inputfiles)
    
    % get directories and names of all files per group
    f2r = rdir([iDir, filesep, '*', fsuffix]); 
    f2r = str2match(inputfiles{i}, f2r);
    f2r = {f2r.name}';
    [f_im, f_dir] = split_path(f2r);
    clear f2r
    
    % compile directories and names per group
    f2r_dir = [f2r_dir; f_dir];
    f2r_im = [f2r_im; f_im];
    idx_vect = (1:numel(f_dir)) + k;
    group_idx{i} = idx_vect;
    
    k = idx_vect(end);
    
    clear idx_vect f_dir f_im
    
end

end
