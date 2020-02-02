function cmtk_dbm_parse_j_and_tval_and_tnull(inputfiles, iparams)
% cmtk_dbm_parse_j_and_tval_and_tnull(inputfiles, iparams): 
%   deformation-based morphometry, it loads jacobians from 'nrrd' files and
%   saves them in a memmap '.mat' file, calculates two-sample t-statistic,
%   and the null distribution of t-stat (same method as Cachero et al 2010).
%
% Usage:
%   cmtk_dbm_parse_j_and_tval_and_tnull(inputfiles, iparams)
%
% Args:
%   inputfiles: files to load per group (two groups), each group is collection of cells
%   iparams: parameters
%       (iDir: data input directory)
%           (default, pwd)
%       (oDir: output directory)
%           (default, pwd)
%       (redo: flag to redo)
%           (default, 0)
%       (fsuffix: input file suffix)
%           (default, '_j.nrrd')
%       (imaskDir: mask image directory)
%           (default, [])
%       (imaskIm: mask image)
%           (default, [])
%       ****** jacobian normalization ******
%       (stat2use: stat to use for jacobian denominator)
%           (1, mean, default)
%           (2, median)
%       (imask: name of binary 3D variable matrix, same size as reference image, 
%           that defines which pixels to use) 
%           (default, [])
%       ****** ttest-related ******
%       (vartype: variance type for ttest)
%           (default, 'equal')
%       (gidx: file indeces of groups to compare)
%           (default, [])
%       ****** permutation-related ******
%       (pern: number of permutations)
%           (default, 10^4)
%       (chunk_size: size of chunks);
%           (default, 1e6)
%       (corenum: number of cores to use)
%           (default, 4)
%       (serId: server ID)
%           ('int' | ispc or ismac, to run locally)
%           (otherwise assumes it is run on the server)
%       (ofname: name of output file)
%           (default, 'dbm_nj_tval')
%       (oRes: output resolution)
%           (default, [], same as original)
%
% Notes:
% inspired by Cachero et al 2010 (https://www.ncbi.nlm.nih.gov/pubmed/20832311)
% the calculation of the null distribution is computationally expensive
%   (depending on the image resolution it can take from tens of hours to days)
% see bibmem_ttest2 get_files2load_pergroup gen_group_shuffle 
% see also cmtk_dbm_parse_j_and_tval

% default params
dbm = [];
dbm.iDir = pwd;
dbm.oDir = pwd;
dbm.redo = 0;
dbm.fsuffix = '_j.nrrd';
dbm.imaskDir = [];
dbm.imaskIm = [];
dbm.stat2use = 1;
dbm.imask = [];
dbm.vartype = 'equal';
dbm.gidx = [];
dbm.pern = 10^4;
dbm.chunk_size = 1e6;
dbm.corenum = 4;
dbm.serId = 'int';
dbm.ofname = 'dbm_nj_tval';
dbm.oRes = [];

if ~exist('iparams', 'var'); iparams = []; end
dbm = loparam_updater(dbm, iparams);

% 1) Start paralel pool if not ready yet
ppobj = setup_parpool(dbm.serId, dbm.corenum);

% 2) load/create mem map object
dataObj = matfile([dbm.oDir, filesep, dbm.ofname, '.mat'], ...
    'Writable', true);

% 3) Get files and directories parsed per groups
[f2r_dir, f2r_im, dbm.gidx] = ...
    get_files2load_pergroup(inputfiles, dbm.iDir, dbm.fsuffix);

% reset dataObj.group_idx
if ~isprop(dataObj, 'group_idx') || dbm.redo
    dataObj.group_idx = dbm.gidx;
else
    fprintf('Already collected jacobians\n')
end

% 4) Load jacobian images per file and save them in dataObj

% load brain mask:
if ~isempty(dbm.imask) && ...
        ~isempty(dbm.imaskDir) && ~isempty(dbm.imaskIm)
    
    % use selected pixels
    bmask_int = load([dbm.imaskDir, filesep, ...
        strrep(dbm.imaskIm, '.nrrd', '.mat')], dbm.imask);
    bmask_int = bmask_int.(dbm.imask);
    
else
    
    % use all pixels
    bmask_int = nrrdread([f2r_dir{1}, filesep, f2r_im{1}]);
    bmask_int = true(size(bmask_int));
    
end

% change resolution
if ~isempty(dbm.oRes)
    
   [~, meta] = nrrdread([dbm.imaskDir, filesep, dbm.imaskIm, '.nrrd']);
   iRes = nrrdread_res(meta);
   bmask_int = interp3DxT(bmask_int, iRes, dbm.oRes, 3, 'nearest');
   
end

sizY_3d = size(bmask_int);

bmask_int = reshape(bmask_int, [prod(sizY_3d), 1]);
sizY_2d = size(bmask_int);

dataObj.pix2use = find(bmask_int == 1);

if ~isprop(dataObj, 'sizY') || dbm.redo
    
    load_jacobians(f2r_im, f2r_dir, sizY_2d, sizY_3d, ...
        bmask_int, dataObj, dbm.stat2use, iRes, dbm.oRes)
    
else
    
    fprintf('Already collected jacobians\n')
    
end

% 5) Calculate two-samplet-test
if ~isprop(dataObj, 't_val') || ...
        isempty(dataObj.t_val) || dbm.redo
    
    fprintf('Computing ttest\n')
    
    dataObj.t_val = [];
    tic
    dataObj.t_val = bibmem_ttest2(dataObj, dbm.gidx{1}, dbm.gidx{2}, ...
        dbm.vartype, dbm.chunk_size, dbm.corenum);
    toc
    
else
    
    fprintf('Already computed ttest\n')
    
end

% 6) Calculate distribution of extremes from random permutation
% permute group identity

fprintf('Computing ttest for random data\n')
pix2use = find(bmask_int == 1);
all_idx = 1:numel(f2r_im);
k = 1;

if ~isprop(dataObj, 'p_t_val') || ...
        isempty(dataObj.p_t_val) || dbm.redo
    
    dataObj.p_t_val = [];
    dataObj.p_t_val_b = [];
    
    group_idx_g1 = gen_group_shuffle_n(numel(all_idx), dbm.gidx{1}, (dbm.pern + 10^2));
    group_idx_g1 = unique(group_idx_g1, 'rows');
    group_idx_g1 = group_idx_g1(1:dbm.pern, :);
    dataObj.group_idx_g1 = group_idx_g1;
    
    for i = 1:size(group_idx_g1, 1)
        group_idx_g2(i, :) = setdiff(all_idx, group_idx_g1(i, :));
    end
    
    dataObj.group_idx_g2 = group_idx_g2;
    
else
    
    fprintf('Already calculated permutations\n')
    group_idx_g1 = dataObj.group_idx_g1;
    group_idx_g2 = dataObj.group_idx_g1;
    k = max([size(dataObj.p_t_val_b, 1), 1]);
    
end

% calculate extreme t-vals
for i = k:dbm.pern
    
    fprintf(['Running iteration #', num2str(i), '\n'])
    
    tic
    t_val = bibmem_ttest2(dataObj, group_idx_g1(i, :), group_idx_g2(i, :), ...
        dbm.vartype, dbm.chunk_size, dbm.corenum);
    dataObj.p_t_val(i, 1:2) = [min(t_val(:)) max(t_val(:))];
    dataObj.p_t_val_b(i, 1:2) = [min(t_val(pix2use)) max(t_val(pix2use))];
    toc
    
end

fprintf('Done\n')

end
