function out = cmtk_intfunc(func2use, redo, iIm, oIm, ...
    refIm, xform, oDir, refDir, iDir, aDir, xDir, iparams)
% cmtk_intfunc: function executes registration, warp and reformat function
% from CMTK.
%
% Usage:
%   out = cmtk_intfunc(func2use, redo, iIm, oIm, ...
%       refIm, xform, oDir, refDir, iDir, aDir, xDir, iparams)
%
% Args:
%   func2use: CMTK function to use
%       ('ia', initial affine)
%       ('a', regular affine)
%       ('w', warp)
%       ('r', reformat)
%       ('rj', generate jacobian)
%   redo: redo
%   iIm: input floating image
%   oIm: output image
%   refIm: reference image
%   xform: transformation
%   oDir: output directory
%   refDir: refIm directory
%   iDir: iIm directory
%   aDir: affine directory
%   xDir: xform directory
%   iparams: registration parameters
%
% Returns:
%   out: suffices of both affine or warp transformations
%
% Notes:
% inspired by https://github.com/jefferis/AnalysisSuiteBin/blob/master/munger.pl

if ~exist('iparams', 'var') || isempty(iparams)
    fprintf('generating iparams from default settings\n')
    iparams = [];
    iparams = cmtk_paramgen(iparams);
    % details on paramters refer to cmtk_paramgen
    % generate default params for registration
else
    intregpar = iparams;
end

dirpar.fisuffix = '.nrrd';
dirpar.intfunc = {'registrationx', 'warpx', 'reformatx'};

if exist('redo', 'var') && ~isempty(redo)
    dirpar.redo = redo;
else
    dirpar.redo = 0;
end

% generate deafult directories or pass inputed ones
gendefaultdir(func2use, oDir, refDir, ...
    iDir, aDir, xDir, dirpar, intregpar)

switch func2use
    case {'a', 'ia'}
        if intregpar.verb
            fprintf('\n ***** Running Affine registration *****\n');
        end
        RunAffine(func2use, iIm, oIm, ...
            refIm, dirpar, intregpar);
    case 'w'
        if intregpar.verb
            fprintf('\n ***** Running Warping *****\n');
        end
        RunWarp(iIm, oIm, refIm, ...
            dirpar, intregpar);
    case {'r', 'rj'}
        if intregpar.verb
            fprintf('\n ***** Running Reformatx *****\n');
        end
        jgate = numel(strfind(func2use, 'j'));
        Runreformat(iIm, oIm, refIm, ...
            xform, jgate, dirpar, intregpar);
end

if intregpar.verb; fprintf('******** Done ********\n'); end

% pass suffices generated
out{1} = a_suffix_gen(intregpar);
out{2} = w_suffix_gen(intregpar);

end

% %%%%%%%% Main functions %%%%%%%%

function RunAffine(func2use, iIm, oIm, ...
    refIm, dirpar, intregpar)
% RunAffine: generate linear transformations
%
% Usage:
%   RunAffine(func2use, iIm, oIm, refIm)
%
% Args:
%   func2use: function to use, initial affine or regular affine
%   iIm: input image
%   oIm: output image
%   refIm: reference image
%   dirpar: directory structure
%   intregpar: registration parameters

% initAffine arguments
affine_arg = [' -v ', intregpar.aM];

if ~intregpar.initf2use
    if intregpar.regf2use
        affine_arg = [affine_arg, ' ', intregpar.inittype_reg]; 
    else
        affine_arg = [affine_arg, ' --initxlate'];
    end 
end

if intregpar.aSym && intregpar.regf2use
    affine_arg = [affine_arg, ' --symmetric '];
end

if intregpar.padref
    affine_arg = [affine_arg, ' --pad-ref ', num2str(intregpar.padval(1))];
end

if intregpar.padfloat
    affine_arg = [affine_arg, ' --pad-flt ', num2str(intregpar.padval(2))];
end

if intregpar.amatchHist
    affine_arg = [affine_arg, ' --match-histograms'];
end

if intregpar.regf2use
    affine_arg = [affine_arg, ' --max-stepsize ', num2str(intregpar.aX)];
else
    affine_arg = [affine_arg, ' -e ', num2str(intregpar.aX)];
end

affine_arg = [affine_arg, ' --coarsest ', num2str(intregpar.aC)];
affine_arg = [affine_arg, ' ', intregpar.affineDOF];

if intregpar.regf2use && ~isempty(intregpar.aAccu)
    affine_arg = [affine_arg, ' --min-stepsize ', num2str(intregpar.aAccu)];
elseif ~intregpar.regf2use && ~isempty(intregpar.aAccu)
    affine_arg = [affine_arg, ' -a ', num2str(intregpar.aAccu)];
end

% alternative initialization
paStr = ['pa.list', filesep, 'registration'];

if intregpar.initf2use
    
    % generate default init-affine output name:
    % ref-file_float-file_pa.list/registration
    oIm_ia = [strrep(refIm, dirpar.fisuffix, ''), ...
        '_', strrep(iIm, dirpar.fisuffix, ''), '_', paStr];
    command2run = ['make_initial_affine -v ', ...
        intregpar.inittype_mia, ' ', dirpar.refDir, filesep, refIm];
    command2run = [command2run, ' ', dirpar.iDir, ...
        filesep, iIm, ' ', dirpar.oDir, filesep, oIm_ia];
    disp(['Running initial affine with command: ', command2run])
    commandexecuter(command2run, [dirpar.oDir, filesep, oIm_ia], ...
        dirpar.redo, intregpar.verb)
    
end

switch func2use
    case 'a'
        
        % generate output file name
        if isempty(oIm)
            % generate default output name:
            % ref-file_float-file_pa.list/registration
            oIm = [strrep(refIm, dirpar.fisuffix, ''), '_', ...
                strrep(iIm, dirpar.fisuffix, ''), '_', a_suffix_gen(intregpar)];
        end

        % run command
        command2run = dirpar.intfunc{1};
        
        if ~intregpar.regf2use; command2run = strrep(command2run, 'x', ''); end
        command2run = [command2run, affine_arg];
        
        if intregpar.initf2use
            command2run = [command2run, ' --initial ', dirpar.oDir, filesep, oIm_ia];
        end
        
        command2run = [command2run, ' -o ', dirpar.oDir, filesep, oIm, ' ', ...
            dirpar.refDir, filesep, refIm,' ', dirpar.iDir, filesep, iIm];

        display(['Running affine with command: ', command2run])
        commandexecuter(command2run, [dirpar.oDir, filesep, oIm], ...
            dirpar.redo, intregpar.verb)
        
end

end

function RunWarp(iIm, oIm, ...
    refIm, dirpar, intregpar)
% RunWarp: generate non-linear transformations
%
% Usage:
%   RunWarp(iIm, oIm, refIm)
%
% Args:
%   iIm: input image
%   oIm: output image
%   refIm: reference image
%   dirpar: directory structure
%   intregpar: registration parameters

% initAffine arguments
warp_arg = [' -v ', intregpar.wM];

if intregpar.padref
    warp_arg = [warp_arg, ' --pad-ref ', num2str(intregpar.padval(1))];
end

if intregpar.padfloat
    warp_arg = [warp_arg, ' --pad-flt ', num2str(intregpar.padval(2))];
end

if intregpar.warpf2use
    warp_arg = [warp_arg, ' --jacobian-constraint-weight ', intregpar.J, ...
        ' --max-stepsize ', num2str(intregpar.wX), ' --grid-spacing ', intregpar.G, ...
        ' --smoothness-constraint-weight ', intregpar.E, ' --grid-refine ', ...
        intregpar.R, ' --coarsest ', num2str(intregpar.wC), ...
        ' --inverse-consistency-weight ', intregpar.I]; %' --output-intermediate'    
else
    warp_arg = [warp_arg, ' --jacobian-weight ', intregpar.J, ...
        ' -e ', num2str(intregpar.wX), ' --grid-spacing ', intregpar.G, ...
        ' --energy-weight ', intregpar.E, ' --refine ', ...
        intregpar.R, ' --coarsest ', num2str(intregpar.wC), ...
        ' --ic-weight ', intregpar.I]; %' --output-intermediate'    
end

if intregpar.warpf2use && ~isempty(intregpar.wAccu)
    warp_arg = [warp_arg, ' --min-stepsize ', num2str(intregpar.wAccu)];
elseif ~intregpar.warpf2use && ~isempty(intregpar.wAccu)
    warp_arg = [warp_arg, ' -a ', num2str(intregpar.wAccu)];
end

if intregpar.wmatchHist
    warp_arg = [warp_arg, ' --match-histograms'];
end

if intregpar.wSpeed
    warp_arg = [warp_arg, ' --accurate'];
else
    warp_arg = [warp_arg, ' --fast'];
end

if intregpar.rToUnfold
    warp_arg = [warp_arg, ' --relax-to-unfold'];
end

% generate output file name
if isempty(oIm)
    oIm = [strrep(refIm, dirpar.fisuffix, ''), '_', ...
        strrep(iIm, dirpar.fisuffix, ''), '_', ...
        a_suffix_gen(intregpar, 0), '_', w_suffix_gen(intregpar)]; 
end

if intregpar.a
    initialxform = [dirpar.aDir, filesep, strrep(refIm, dirpar.fisuffix, ''), ...
        '_', strrep(iIm, dirpar.fisuffix, ''), '_', a_suffix_gen(intregpar)];
end

% run command
command2run = dirpar.intfunc{2};

if ~intregpar.warpf2use; command2run = strrep(command2run, 'x', ''); end
command2run = [command2run, warp_arg, ' -o ', dirpar.oDir, filesep, oIm, ...
    ' ', dirpar.refDir, filesep, refIm,' ', dirpar.iDir, filesep, iIm];

if intregpar.a && (exist(fullfile([initialxform, filesep, 'registration']), 'file') == 2)
    command2run = [command2run, ' ', initialxform];
end

if intregpar.a && ~(exist(fullfile([initialxform, filesep, 'registration']), 'file') == 2)
    
    fprintf('Initialxform does not exists \n');
    disp([initialxform, filesep, 'registration'])
    
else
    
    display(['Running warp with command: ', command2run])
    commandexecuter(command2run, [dirpar.oDir, filesep, oIm], ...
        dirpar.redo, intregpar.verb)
    
end

end

function Runreformat(iIm, oIm, ...
    refIm, xform, jgate, dirpar, intregpar)
% Runreformat: generate reformatted images
%
% Usage:
%   Runreformat(iIm, oIm, refIm, xform, jgate)
%
% Args:
%   iIm: input image
%   oIm: output image
%   refIm: reference image
%   xform: input xform
%   jgate: gate to get jacobian
%   dirpar: directory structure
%   intregpar: registration parameters

% initAffine arguments
reformat_arg = [' -v ', intregpar.rM];

if isfield(intregpar, 'rMotype') && ~isempty(intregpar.rMotype)
    reformat_arg = [reformat_arg, ' ', intregpar.rMotype];
end

if intregpar.padout
    reformat_arg = [reformat_arg, ' --pad-out ', num2str(intregpar.padval(3))];
end

% generate output and xform file name
% Note: for registration and warp xforms it just require the folder
% directory, but for init_affine xform it needs the actual file path
if isempty(xform)
    if strcmp(intregpar.rLevel, 'ia') % init affine
        xform = [strrep(refIm, dirpar.fisuffix, ''), '_', ...
            strrep(iIm, dirpar.fisuffix, ''), '_pa.list', filesep, 'registration'];
    elseif strcmp(intregpar.rLevel, 'a') % affine
        xform = [strrep(refIm, dirpar.fisuffix, ''), '_', ...
            strrep(iIm, dirpar.fisuffix, ''), '_', a_suffix_gen(intregpar)];
    elseif strcmp(intregpar.rLevel, 'w') && intregpar.a % affine and warp
        xform = [strrep(refIm, dirpar.fisuffix, ''), '_', ...
            strrep(iIm, dirpar.fisuffix, ''), '_', a_suffix_gen(intregpar, 0), ...
            '_', w_suffix_gen(intregpar)];
    elseif strcmp(intregpar.rLevel, 'w') && ~intregpar.a % warp only
        xform = [strrep(refIm, dirpar.fisuffix, ''), '_', ...
            strrep(iIm, dirpar.fisuffix, ''), '_', w_suffix_gen];
    else
        fprintf('Error rLevel unknown\n'); return;
    end
end

% add jacobian suffix
extrasuf = '';
if jgate
    extrasuf = '_j';
end

% reformat another channel
if isfield(intregpar, 'rgate_ch2') && intregpar.rgate_ch2
    iIm = strrep(iIm, ...
        intregpar.ch2chSu{1}, intregpar.ch2chSu{2});
end

if isempty(oIm)
    if strcmp(intregpar.rLevel, 'ia') % init affine
        oIm = [strrep(refIm, dirpar.fisuffix, ''), ...
            '_', strrep(iIm, dirpar.fisuffix, ''), '_', ...
            strrep(xform, ['.list', filesep, 'registration'], ''), ...
            extrasuf, '.', intregpar.rFormat];
    else
        oIm = [strrep(refIm, dirpar.fisuffix, ''), ...
            '_', strrep(iIm, dirpar.fisuffix, ''), '_', ...
            strrep(xform, '.list', ''), extrasuf, '.', ...
            intregpar.rFormat];        
    end
end

% run command
if jgate
    command2run = [dirpar.intfunc{3}, reformat_arg, ...
        ' -o ', dirpar.oDir, filesep, oIm, ...
    ' ', dirpar.refDir, filesep, refIm, ' --jacobian'];
else
   command2run = [dirpar.intfunc{3}, reformat_arg, ...
       ' -o ', dirpar.oDir, filesep, oIm, ...
        ' --floating ', dirpar.iDir, filesep, iIm, ...
        ' ', dirpar.refDir, filesep, refIm];
end

command2run = add_xform(command2run, xform, dirpar.xDir);

if exist_xform(xform, intregpar.rLevel, dirpar.xDir)
    
    if intregpar.verb
        display(['Running reformat with command: ', command2run]);
    end
    
    commandexecuter(command2run, [dirpar.oDir, filesep, oIm], ...
        dirpar.redo, intregpar.verb)
    
else
    
    fprintf('xform files not found \n')
    display(command2run);
    display(dirpar.xDir);
    display(xform)
    
end

end

% %%%%%%%% Sub-functions %%%%%%%%

function gendefaultdir(func2use, oDir, refDir, ...
    iDir, aDir, xDir, dirpar, intregpar)
% gendefaultdir: generate default directories
%
% Usage:
%   gendefaultdir(func2use, oDir, refDir, ...
%       iDir, aDir, xDir, dirpar, intregpar)
%
% Args:
%   func2use: functions to use
%   oDir: output data directory
%   refDir: reference directory
%   iDir: input data directory
%   aDir: affine directory
%   xDir: xform directory
%   dirpar: directory structure
%   intregpar: registration parameters

% oDir
if isempty(oDir)
    % generate defult output directories
    switch func2use
        case {'a', 'ia'}
            dirpar.oDir = ['.', filesep, 'registration', filesep, 'affine'];
        case 'w'
            dirpar.oDir = ['.', filesep, 'registration', filesep, 'warp'];
        case 'r'
            if isfield(intregpar, 'rgate_ch2') && intregpar.rgate_ch2
                dirpar.oDir = ['.', filesep, 'reformatted_', ...
                    strrep(iDir, ['.', filesep, 'images_'], '')];
            else
                dirpar.oDir = ['.', filesep, 'reformatted'];
            end
    end
    if exist(fullfile(dirpar.oDir), 'dir')~=7; mkdir(dirpar.oDir); end
else
    dirpar.oDir = oDir;
end

% refDir
if isempty(refDir); dirpar.refDir = '.'; else; dirpar.refDir = refDir; end

% aDir
if isempty(aDir)
    dirpar.aDir = ['.', filesep, 'registration', filesep, 'affine'];
else
    dirpar.aDir = aDir;
end

% xDir
if isempty(xDir)
    itype = intregpar.rLevel;
    switch itype
        case {'ia', 'a'}
            dirpar.xDir = ['.', filesep, 'registration', filesep, 'affine'];
        case 'w'
            dirpar.xDir = ['.', filesep, 'registration', filesep, 'warp'];
    end
else
    dirpar.xDir = xDir;
end

% pass iDir
if isempty(iDir)
    dirpar.iDir = ['.', filesep, 'images'];
else
    dirpar.iDir = iDir;
end

end

function commandexecuter(command2run, oIm, redo, verbose)
% commandexecuter: executes commands from terminal, (PC/linux/Mac compatible)
%
% Usage:
%   status = coexecuter(CommandStr)
%
% Args:
%   command2run: command string
%   oIm: expected output file to write
%   redo: redo
%   verbose: verbose

status = 0;

if ~(exist(oIm, 'file') || exist(strrep(oIm, 'j0', ''), 'file')) || redo
    
    if verbose
        status = coexecuter(command2run, 3);
    else
        status = coexecuter(command2run, 0);
    end
    
else
    fprintf('*** File already generated *** \n');
end

if status == 0
    if verbose
        fprintf('File succesfully run \n');
    end
else
    fprintf('File Failed \n');
end

end

function affine_suffix = a_suffix_gen(intregpar, suffixgate)
% affine_suffix: generates default affine suffix (if 0, excludes .list)
%
% Usage:
%   affine_suffix = a_suffix_gen(intregpar, suffixgate)
%
% Args:
%   intregpar: main registration parameters
%   suffixgate: (if 0, excludes .list)

if ~exist('suffixgate', 'var') || isempty(suffixgate); suffixgate = 1; end

affine_suffix = ['m', intregpar.aM, 'e', num2str(intregpar.aX), 'dof', ...
    strrep(strrep(intregpar.affineDOF, '--dofs', ''), ' ', ''), ...
    'c', num2str(intregpar.aC)];

if ~intregpar.initf2use
    
    if intregpar.regf2use
        affine_suffix = [affine_suffix, 'i', strrep(intregpar.inittype_reg, '--', '')];
        % consider adding another label: 
        % affine_suffix = [affine_suffix, 'ix', strrep(intregpar.inittype_reg, '--', '')];
    else
        affine_suffix = [affine_suffix, 'initfov'];
    end
    
else
    
    if strcmp(intregpar.inittype_mia, '--direction-vectors')
        short_suffix = 'dv';
    elseif strcmp(intregpar.inittype_mia, '--centers-of-mass')
        short_suffix = 'com';
    elseif strcmp(intregpar.inittype_mia, '--principal-axes')
        short_suffix = 'pax';
    elseif strcmp(intregpar.inittype_mia, '--identity')
        short_suffix = 'id';
    end
    
    affine_suffix = [affine_suffix, 'init', short_suffix];
    
end

if intregpar.padref  
    affine_suffix = [affine_suffix, 'pr'];
end

if intregpar.padfloat
    affine_suffix = [affine_suffix, 'pf'];
end

if intregpar.amatchHist; affine_suffix = [affine_suffix, '_mh']; end

if suffixgate
    affine_suffix = [affine_suffix, '.list'];
end

end

function warp_suffix = w_suffix_gen(intregpar, suffixgate)
% w_suffix_gen: generates default warp suffix (if 0, excludes .list)
%
% Usage:
%   warp_suffix = w_suffix_gen(intregpar, suffixgate)
%
% Args:
%   intregpar: main registration parameters
%   suffixgate: (if 0, excludes .list)

if ~exist('suffixgate', 'var') || isempty(suffixgate); suffixgate = 1; end
warp_suffix = 'warp';

if intregpar.warpf2use
    warp_suffix = [warp_suffix, 'x'];
end

warp_suffix = [warp_suffix, '_m', intregpar.wM, 'g', intregpar.G, 'c',...
    num2str(intregpar.wC), 'e', intregpar.E, 'x', num2str(intregpar.wX), ...
    'r', intregpar.R];

if ~strcmp(intregpar.J, '0')
    warp_suffix = [warp_suffix, 'j', intregpar.J];
end

if intregpar.padref    
    warp_suffix = [warp_suffix, 'pr'];
end

if intregpar.padfloat
    warp_suffix = [warp_suffix, 'pf'];
end

if intregpar.wmatchHist; warp_suffix = [warp_suffix, '_mh']; end
if intregpar.rToUnfold; warp_suffix = [warp_suffix, '_r2unf']; end

if suffixgate
    warp_suffix = [warp_suffix, '.list'];
end

end

function command2run = add_xform(command2run, xform, xDir)
% add_xform: basically adds many xforms for reformatting (if xform is a cell or not)
%
% Usage:
%   command2run = add_xform(command2run, xform)
%
% Args:
%   command2run: command string
%   xform: all xforms to use
%   xDir: xform directori(es)

if iscell(xform)
    
    for i = 1:numel(xform)
        if iscell(xDir)
            command2run = [command2run, ' ', xDir{i}, filesep, xform{i}];
        else
            command2run = [command2run, ' ', xDir, filesep, xform{i}];
        end
    end
    
else
    command2run = [command2run, ' ', xDir, filesep, xform];
end

end

function igate = exist_xform(xform, reformat_level, xDir)
% exist_xform: basically checks if xform files exist
%
% Usage:
%   igate = exist_xform(xform, reformat_level, cp)
%
% Args:
%   xform: Folder name to load
%   reformat_level: which reformat level (initial affine, affine, warp)
%   xDir: xform directori(es)

if iscell(xform)
    
    for i = 1:numel(xform)
        if iscell(xDir)
            igate(i) = exist(fullfile(xDir{i}, filesep, xform{i}, filesep, 'registration'), 'file') == 2 || ...
            exist(fullfile(xDir{i}, filesep, xform{i}, filesep, 'registration.gz'), 'file') == 2 || ...
            exist(fullfile(xDir{i}, filesep, strrep(xform{i}, 'j0', ''), filesep, 'registration'), 'file') == 2 || ...
            exist(fullfile(xDir{i}, filesep, strrep(xform{i}, 'j0', ''), filesep, 'registration.gz'), 'file') == 2;
        else
            igate(i) = exist(fullfile(xDir, filesep, xform{i}, filesep, 'registration'), 'file') == 2 || ...
            exist(fullfile(xDir, filesep, xform{i}, filesep, 'registration.gz'), 'file') == 2 || ...
            exist(fullfile(xDir, filesep, strrep(xform{i}, 'j0', ''), filesep, 'registration'), 'file') == 2 || ...
            exist(fullfile(xDir, filesep, strrep(xform{i}, 'j0', ''), filesep, 'registration.gz'), 'file') == 2;
        end
    end
    
else
    
    if strcmp(reformat_level, 'ia') % it is already a file, not a dir
        igate = exist(fullfile(xDir, filesep, xform), 'file') == 2;
    else
        igate = exist(fullfile(xDir, filesep, xform, filesep, 'registration'), 'file') == 2 || ...
        exist(fullfile(xDir, filesep, xform, filesep, 'registration.gz'), 'file') == 2 || ...
        exist(fullfile(xDir, filesep, strrep(xform, 'j0', ''), filesep, 'registration'), 'file') == 2 || ...
        exist(fullfile(xDir, filesep, strrep(xform, 'j0', ''), filesep, 'registration.gz'), 'file') == 2;
    end
    
end

end