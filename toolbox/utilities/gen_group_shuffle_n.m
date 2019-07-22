function rperm_gIdx = gen_group_shuffle_n(t_n, t_group, perm_n)
% gen_group_shuffle_n: function that generates random combinations of numbers using
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
%
% Notes:
% unlike gen_group_shuffle, this keeps a constant output rperm_gIdx size,
% but can be slower because of while loop

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