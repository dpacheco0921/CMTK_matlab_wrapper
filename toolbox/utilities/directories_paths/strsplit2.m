function tokens = strsplit2(string, delimiter)
% strsplit2: split a string into pieces using a delimiter.
%   Input: string, delimiter. Output: cell of pieces.
%
% Usage:
%   tokens = strsplit2(string, delimiter)
%
% Args:
%   string: input a string
%   delimiter: a character or a string of characters; the whole string is
%       the delimiter (not each character), and whitespace around it is removed
% 
% Returns:
%   tokens: split strings, cell
%
% NOTE (known issue, not yet fixed): only the first character of delimiter
%   is escaped for the regular expression, so letter delimiters change
%   meaning (e.g. 'd' becomes \d, a digit).

tokens = regexp(string, ['\s*\' delimiter '\s*'], 'split');

end
