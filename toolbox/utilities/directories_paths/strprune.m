function newstr = strprune(string, delimiter, string2keep)
% strprune: split a string on a delimiter and rebuild it from some of the pieces.
%   Input: string, delimiter, pieces to keep. Output: rebuilt string.
%
% Usage:
%   newstr = strprune(string, delimiter, string2keep)
%
% Args:
%   string: input string
%   delimiter: delimiter pattern to split string
%   string2keep: number of string pieces to keep (scalar n keeps pieces 1:n),
%       or a vector of piece indices to keep
%
% Returns:
%   newstr: kept pieces joined again with delimiter
%
% Notes:
% Splitting also trims whitespace around the delimiter, and the first
%   character of delimiter is regex-escaped (see strsplit2).
 
tokens = regexp(string, ['\s*\' delimiter '\s*'], 'split');

if numel(string2keep) == 1
    string2keep = 1:string2keep;
end

newstr = [];

for i = string2keep
    
    if i < string2keep(end)
        newstr = [newstr, tokens{i}, delimiter];
    else
        newstr = [newstr, tokens{i}];
    end
    
end

end
