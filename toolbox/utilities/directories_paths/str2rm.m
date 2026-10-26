function i_file = str2rm(i_str, i_file)
% str2rm: remove the files whose names contain a pattern.
%   Input: pattern(s), file names (cell or dir/rdir struct).
%   Output: the files that do NOT contain any of the patterns.
%
% Usage:
%   i_file = str2rm(i_str, i_file)
%
% Args:
%   i_str: is a string or a cell of strings (pattern to remove)
%   i_file: is a string or a cell of strings (input files)
% 
% Returns:
%   i_file: subset of i_file that does not contain any pattern of i_str
%       (patterns are plain substrings, not regular expressions)

if ~isempty(i_str)
    
    if ~iscell(i_str)
        i_str = {i_str};
    end
    
    Strnum = numel(i_str);
    
    if isstruct(i_file)
        
        for i = 1:Strnum
            file2clear = strfind({i_file.name}, i_str{i});
            i_file(~cellfun(@isempty, file2clear)) = [];
            clear file2clear
        end
        
    else
        
        for i = 1:Strnum
            file2clear = strfind(i_file, i_str{i});
            i_file(~cellfun(@isempty, file2clear)) = [];
            clear file2clear
        end
        
    end
    
else
    
    %fprintf('no input str \n')
    
end

end
