function [f2r_dir, f2r_im, group_idx] = ...
    get_files2load_pergroup(inputfiles, iDir, fsuffix)
% get_files2load_pergroup: get a cell [n + m, 1] of files and directories
%   per group, and group indeces
%
% Usage:
%   [f2r_dir, f2r_im, group_idx] = ...
%       get_files2load_pergroup(inputfiles, iDir, fsuffix)
%
% Args:
%   inputfiles: files to load per group (two groups), each group is collection of cells
%   iDir: input directory
%   fsuffix: suffix of files to find
%
% Returns:
%   f2r_dir: file diretories
%   f2r_im: file names
%   group_idx: group indeces

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
