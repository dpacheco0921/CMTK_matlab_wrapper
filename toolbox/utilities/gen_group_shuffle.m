function [rperm_gIdx, rperm_gIdx_] = gen_group_shuffle(t_n, t_group, perm_n)
% gen_group_shuffle: function that generates random combinations of numbers using
%   the universe set: 1:t_n, and producing sets of size numel(t_group) it iterates perm_n times
%
% Usage:
%   rperm_gIdx = gen_group_shuffle(t_n, t_group, perm_n)
%
% Args:
%   t_n: 1:t_n, universe of numbers
%   t_group: subset size
%   perm_n: number of permutations
%
% Outputs:
%   rperm_gIdx: matrix of size [perm_n, numel(t_group)]

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

% remove random order that matches the original t_group
idx2del = ismember(rperm_gIdx(s_i, :), t_group, 'rows');
rperm_gIdx(idx2del, :) = [];
rperm_gIdx_(idx2del, :) = [];

end