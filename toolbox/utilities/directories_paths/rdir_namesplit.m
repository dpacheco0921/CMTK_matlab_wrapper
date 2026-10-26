function [animalname, animalnum, repnum, str_length] = ...
    rdir_namesplit(basename, suffixend, ...
    fisuffix, fi2reject, fi2match, nametype)
% rdir_namesplit: list files in the current directory (recursively) and split
%   each name on '_' into parts. Input: name filters and name type.
%   Output: animal names, animal numbers, repetition numbers, part lengths.
%
% Usage:
%   [animalname, animalnum, repnum, str_length] = ...
%      rdir_namesplit(basename, suffixend, ...
%      fisuffix, fi2reject, fi2match, nametype)
%
% Args:
%   basename: file name pattern (required)
%   suffixend: file format (optional, default '.tif')
%   fisuffix: extra pattern to attach to suffixend (optional)
%   fi2reject: pattern to reject files (required in practice, use [] for none)
%   fi2match: pattern to accept files (optional)
%   nametype: type of animalname to output (optional, default 0)
%       (0: animalname, animalnum, repnum from parts 1, 2, 3)
%       (1: animalname = part1_part2, repnum from part 3)
%       (2: animalname = part1_part2_part3, no numbers)
%       (3: animalname, animalnum from parts 1, 2; repnum from part 4)
%
% Returns:
%   animalname: animal name
%   animalnum: animal number
%   repnum: repetition number
%   str_length: string length of each part, one row per file
%
% Notes:
% Assumes files names have the following struture:
%   (year|month|day)_(animalnum)_(trialnum/repnum)
% Searches the current directory ('.'), so run it from the folder of interest.
% NOTE (known issue, not yet fixed): files with fewer '_' parts than the
%   chosen nametype expects, or a mix of 3 and 4 parts with nametype 1,
%   make it error.

if ~exist('suffixend', 'var') || isempty(suffixend)
    suffixend = '.tif';
end

if ~exist('nametype', 'var') || isempty(nametype)
    nametype = 0;
end

if exist('fisuffix', 'var') && ~isempty(fisuffix)
    suffixend = [fisuffix, suffixend];
end

str_length = [];

f2run = rdir(['.', filesep, '*', suffixend]);
f2run = str2rm(fi2reject, f2run);

if exist('fi2match', 'var')  && ~isempty(fi2match)
    f2run = str2match(fi2match, f2run); 
end

f2run = str2match(basename, f2run);
f2run = {f2run.name};

% remove dir preffix
f2run = strrep(f2run, ['.', filesep], '');

% initialize output params
animalname = cell(1, numel(f2run));
animalnum = zeros(1, numel(f2run));
repnum = zeros(1, numel(f2run));

for FNum = 1:numel(f2run)
    
    TempS = strsplit2(f2run{FNum}, '_');
    
    if nametype == 0 
        
        % split string into: animalname , animalnum , reps
        animalname{1, FNum} = TempS{1};
        animalnum(1, FNum) = str2double(TempS{2});
        repnum(1, FNum) = str2double(TempS{3});
        
        str_length(FNum, :) = ...
            [length(TempS{1}), ...
            length(TempS{2}), ...
            length(TempS{3}), ...
            length(strrep(TempS{4}, suffixend, ''))];
        
    elseif nametype == 1
        
        % split string into: animalname + animalnum , reps
        animalname{1, FNum} = [TempS{1}, '_', TempS{2}];
        repnum(1, FNum) = str2double(TempS{3});
        
        if length(TempS) == 4
            str_length(FNum, :) = ...
                [length(animalname{1, FNum}), ...
                length(TempS{3}), ...
                length(strrep(TempS{4}, suffixend, ''))];
        else
            str_length(FNum, :) = ...
                [length(animalname{1, FNum}), ...
                length(TempS{3})];           
        end
        
    elseif nametype == 2 
        
        % does not split: animalname + animalnum + reps
        animalname{1, FNum} = [TempS{1}, '_', TempS{2}, '_', TempS{3}];
        
        str_length(FNum, :) = ...
            [length(animalname{1, FNum}), ...
            length(strrep(TempS{4}, suffixend, ''))];
        
    elseif nametype == 3
        
        % split string into: animalname , animalnum , reps
        animalname{1, FNum} = TempS{1};
        animalnum(1, FNum) = str2double(TempS{2});
        repnum(1, FNum) = str2double(TempS{4});
        
        str_length(FNum, :) = ...
            [length(TempS{1}), ...
            length(TempS{2}), ...
            length(TempS{4}), ...
            length(strrep(TempS{5}, suffixend, ''))];
        
    end
    
end

end
