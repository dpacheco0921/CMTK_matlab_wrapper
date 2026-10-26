function [i_file, sel_idx] = str2match(i_str, i_file, mtype)
% str2match: keep only the files whose names contain a pattern.
%   Input: pattern(s), file names (cell or dir/rdir struct), match mode.
%   Output: the matching subset and its logical selection index.
%
% Usage:
%   [i_file, sel_idx] = str2match(i_str, i_file, mtype)
%
% Args:
%   i_str: is a string or a cell of strings (pattern to look for)
%   i_file: is a string or a cell of strings (input files)
%   mtype: match mode
%       (1: case-insensitive match of the WHOLE name (strcmpi), not substring;
%           the struct input form does not compare the .name field)
%       (0: case-sensitive substring match (contains), default)
% 
% Returns:
%   i_file: subset of i_file that matches i_str
%   sel_idx: logical indices of selected i_file
%
% NOTE (known issue, not yet fixed): if no file matches, it prints
%   'No Match' and returns an empty i_file (and an empty sel_idx) without error.

if ~exist('mtype', 'var') || isempty(mtype); mtype = 0; end

if ~isempty(i_str)
    
    if ~iscell(i_str); i_str = {i_str}; end
    
    Strnum = numel(i_str);
    
    for Str_idx = 1:Strnum
        
        if iscell(i_file)
            
            if mtype
                BinM = strcmpi(i_file, i_str{Str_idx});
            else
                BinM = contains(i_file, i_str{Str_idx});
            end
            
        else
            
            if mtype
                BinM = strcmpi(i_file, i_str{Str_idx});
            else
                BinM = contains({i_file.name}, i_str{Str_idx});
            end
            
        end
        
        if sum(BinM) == 0
            fprintf('No Match\n');
        else
            f2keep(Str_idx, :) = BinM;
        end
        
    end
    
    if exist('f2keep', 'var')
        
        % keep a file if it matched at least one of the patterns
        %   (one row of f2keep per pattern, one column per file)
        sel_idx = sum(f2keep, 1) > 0;
        i_file(~sel_idx) = [];
        clear Str2Del
        
    else
        
        i_file(:) = [];
        sel_idx = true(numel(i_file), 1)';
        
    end
    
else
    
    sel_idx = true(numel(i_file), 1)';
    
end

end
