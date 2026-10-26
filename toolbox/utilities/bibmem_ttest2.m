function t_val = bibmem_ttest2(Y, gIdx_1, gIdx_2, ...
    vartype, chunk_size, corenum)
% bibmem_ttest2: two-sample t-test per row of a big on-disk matrix, run in
%   chunks across parallel workers. Input: matfile object Y plus two group
%   index vectors. Output: column vector of t-statistics (one per row).
%
% Usage:
%   t_val = bibmem_ttest2(Y, gIdx_1, gIdx_2, ...
%       vartype, chunk_size, corenum)
%
% Args:
%   Y: matfile object (e.g. from load_jacobians) with fields
%       Y.Y (rows = voxels, columns = samples) and Y.sizY ([n_rows, n_samples])
%   gIdx_1: indeces of group 1
%   gIdx_2: indeces of group 2
%   vartype: variance type for ttest)
%       (default, 'equal')
%   chunk_size: size of chunks);
%       (default, 1e6)
%   corenum: number of cores to use)
%       (default, 4)
% 
% Returns:
%   t_val: t-statistics, column vector [n_rows, 1]
%
% Notes:
% Requires Statistics and Machine Learning Toolbox (ttest2) and
%   Parallel Computing Toolbox (parfor); uses ppool_makechunks.
% NOTE (known issue, not yet fixed): the defaults listed above for vartype,
%   chunk_size and corenum are not applied in the code, so all six
%   arguments must be passed.

% Rows are processed in chunks of chunk_size rows, corenum chunks at a time
%   in parallel, because the full matrix does not fit in memory.
sizY = Y.sizY;
t_val = zeros(sizY(1), 1);

[~, ~, chunk_idx] = ...
    ppool_makechunks(chunk_size, corenum, sizY(1));

for i = 1:numel(chunk_idx)
    
    % takes like ~20 sec per chunk of 10^6
    
    batch2run = chunk_idx{i};
    
    parfor ii = 1:numel(batch2run)
        
        t_idx{ii, 1} = (batch2run(ii):min(batch2run(ii) + chunk_size - 1, sizY(1)))';
        Ytemp = Y.Y(t_idx{ii, 1}, :); 
        [~, ~, ~, stats] = ttest2(Ytemp(:, gIdx_1)', Ytemp(:, gIdx_2)', ...
            'Vartype', vartype);
        t_val_t{ii, 1} = stats.tstat';
        
    end
    
    t_val(cell2mat(t_idx), 1) = cell2mat(t_val_t);
    clear t_val_t t_idx
    
    if mod(i, 10) == 0
        fprintf('%2.1f%% of chunks completed \n', i*100/numel(chunk_idx));
    end
    
end

clear chunks nchunks chunk_idx

end
