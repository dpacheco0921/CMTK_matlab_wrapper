function i_str = addsuffix(i_str, i_suffix)
% addsuffix: add a suffix at the end of a string (or of each string in a cell).
%   Input: string or cell of strings, suffix. Output: same type with the suffix added.
%
% Usage:
%   i_str = addsuffix(i_str, i_suffix)
%
% Args:
%   i_str: is a string or a cell composed by strings
%   i_suffix: suffix string
%
% Returns:
%   i_str: input with i_suffix appended (same type as the input, unchanged if empty)

if ~isempty(i_str)
    
    if iscell(i_str)
        
        for i = 1:numel(i_str)
            i_str{i} = [i_str{i}, i_suffix];
        end
        
    else
        i_str = [i_str, i_suffix];
    end
    
end

end