function rperm_gIdx = gen_group_shuffle_n(t_n, t_group, perm_n)
% gen_group_shuffle_n: random group-1 label shuffles for a permutation test.
%   Input: universe size, observed group-1 indices, number of shuffles.
%   Output: perm_n x numel(t_group) matrix of shuffled group-1 indices, none
%   equal to the observed grouping.
%
% Usage:
%   rperm_gIdx = gen_group_shuffle_n(t_n, t_group, perm_n)
%
% Args:
%   t_n: 1:t_n, universe of numbers
%   t_group: row vector of the observed group-1 indices (its length sets the
%       subset size, and it is the grouping to exclude from the shuffles)
%   perm_n: number of permutations
%
% Outputs:
%   rperm_gIdx: matrix of size [perm_n, numel(t_group)]
%
% Notes:
% unlike gen_group_shuffle, this keeps a constant output rperm_gIdx size,
% but can be slower because of while loop
% rng('shuffle') reseeds the global random generator on every call, so
%   results are not reproducible.
% NOTE (known issue, not yet fixed): the while loop never ends if the
%   only possible subset is the observed one (e.g. t_n == numel(t_group)).
%   Rows may repeat across shuffles (callers apply unique(..., 'rows')).

rng('shuffle');

t_group_n = numel(t_group);
t_group = sort(t_group);
rperm_gIdx = zeros(perm_n, t_group_n);

for s_i = 1:perm_n 
    
    i_gate = 0;
    
    while i_gate == 0
        
        rperm_gIdx(s_i, :) = sort(randperm(t_n, t_group_n));
        
        % remove random order that matches the original t_group
        if ~ismember(rperm_gIdx(s_i, :), t_group, 'rows')
            i_gate = 1;
        end
        
    end
    
end

end