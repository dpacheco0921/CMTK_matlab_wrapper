function [oFile, iDir] = split_path(iFile)
% split_path: split path(s) into file name and directory.
%   Input: path string or cell of paths. Output: file name(s) and directory(s).
% 
% Usage:
%   [oFile, iDir] = split_path(iFile)
%
% Args:
%   iFile: input files to chop
% 
% Returns:
%   oFile: file name(s) in cells
%   iDir: file directory(s) in cells
%
% NOTE (known issue, not yet fixed): the file name is found by removing
%   [directory, filesep] from the path, so a path written with the other
%   separator (e.g. '/' on Windows) or a root folder returns the whole path
%   as the file name. Empty input returns [] instead of an empty cell.

idelimiter = filesep;

if iscell(iFile)
    
    for i = 1:numel(iFile)
        
        [iDir{i, 1}, ~, ~] = fileparts(iFile{i});
        oFile{i, 1} = strrep(iFile{i}, [iDir{i, 1}, idelimiter], '');
        
    end
    
else
    
    [iDir, ~, ~] = fileparts(iFile);
    oFile = strrep(iFile, [iDir, idelimiter], '');
    
end

if isempty(iFile)
    iDir = [];
    oFile = [];
end

end
