function [rperm_gIdx, rperm_gIdx_] = gen_group_shuffle(t_n, t_group, perm_n)
% gen_group_shuffle: random group-1 / group-2 label shuffles for a permutation test.
%   Input: universe size, observed group-1 indices, number of shuffles.
%   Output: shuffled group-1 index matrix and matching group-2 matrix.
%   It draws perm_n random subsets of 1:t_n of size numel(t_group), and
%   drops those equal to the observed grouping.
%
% Usage:
%   [rperm_gIdx, rperm_gIdx_] = gen_group_shuffle(t_n, t_group, perm_n)
%
% Args:
%   t_n: 1:t_n, universe of numbers
%   t_group: row vector of the observed group-1 indices (its length sets the
%       subset size, and it is the grouping to exclude from the shuffles)
%   perm_n: number of permutations
%
% Outputs:
%   rperm_gIdx: group-1 indices per shuffle, matrix [<= perm_n, numel(t_group)]
%   rperm_gIdx_: complementary group-2 indices per shuffle,
%       matrix [<= perm_n, t_n - numel(t_group)]
%
% Notes:
% NOTE (known issue, not yet fixed): the final removal step only tests the
%   last shuffle (s_i) instead of every row, so the observed grouping can
%   stay in, and an unrelated row can be deleted.
% rng('shuffle') reseeds the global random generator on every call, so
%   results are not reproducible.

rng('shuffle');

t_n_all = 1:t_n;
t_group_n = numel(t_group);
t_group = sort(t_group);
rperm_gIdx = zeros(perm_n, t_group_n);
rperm_gIdx_= zeros(perm_n, t_n - t_group_n);

for s_i = 1:perm_n 
    
	rperm_gIdx(s_i, :) = sort(randperm(t_n, t_group_n));
    rperm_gIdx_(s_i, :) = setdiff(t_n_all, rperm_gIdx(s_i, :));
    
end

% remove random order that matches the original t_group, because the
%   observed grouping must not be part of the null (permuted) distribution
idx2del = ismember(rperm_gIdx(s_i, :), t_group, 'rows');
rperm_gIdx(idx2del, :) = [];
rperm_gIdx_(idx2del, :) = [];

end