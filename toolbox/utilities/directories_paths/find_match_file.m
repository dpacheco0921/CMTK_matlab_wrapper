function [exist_index] = find_match_file(filename, suffix)
% find_match_file: check which file names (plus a suffix) exist on disk.
%   Input: cell of file names, suffix. Output: logical vector, true if it exists.
%
% Usage:
%   find_match_file(filename, suffix)
%
% Args:
%   filename: cell array of filenames
%   suffix: string to add at the end of filename
%
% Returns:
%   exist_index: logical column vector [numel(filename), 1], true where
%       filename{i} + suffix exists (note: exist also searches the MATLAB path)

exist_index = false(numel(filename), 1);

for i = 1:numel(filename)
    exist_index(i) = exist([filename{i}, suffix], 'file');
end

end