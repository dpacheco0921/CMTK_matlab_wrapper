function xform = cmtk_findxform(target, source, ...
    transformation_dir, transform2ignore)
% cmtk_findxform: find the transformation folder (as a command-line string
%   for reformatx) given the target and source names, for transforming images
%
% Usage:
%   xform = cmtk_findxform(target, source, transformation_dir, transform2ignore)
%
% Args:
%   target: target atlas
%   source: source atlas
%   transformation_dir: transformation directory
%      (default, '.')
%   transform2ignore: string with pattern to ignore
%      (default, [])
%
% Returns:
%   xform: full path of transformation, with '--inverse ' in front when
%       only the opposite-direction folder exists ('' if none found)
%
% Notes:
% NOTE (known issue, not yet fixed): if several folders match the wildcard,
%   their names are concatenated into one invalid path. Also 'Yes-InDirect'
%   is printed even when the direct transformation was found.

if ~exist('transformation_dir', 'var')
    transformation_dir = '.';
end

if ~exist('transform2ignore', 'var')
    transform2ignore = [];
end

% case 1) when the source and target are atlases
fprintf('testing if source and target are atlases: ')
xform = [transformation_dir, filesep, target, '_', source, '.list'];

if ~exist(xform, 'dir')
    
    xform = ['--inverse ', transformation_dir, ...
        filesep, source, '_', target, '.list'];
    
else
    
    fprintf('Yes-Direct\n');
    
end

% case 2) when the source is not an atlas
if ~exist(strrep(xform, '--inverse ', ''), 'dir')
    
    fprintf('\n testing when source is not an atlas: ')
    
    % assume you have a direct transformation from source to atlas
    xform = dir([transformation_dir, filesep, target, '_', source, '*list']);
    xform = str2rm(transform2ignore, xform);

    if numel(xform) ~= 0
        
        xform = [transformation_dir, filesep, xform.name];
        fprintf('Yes-Direct\n');
        
    else
        
        xform = dir([transformation_dir, filesep, source, ...
            '_', target, '*.list']);
        xform = str2rm(transform2ignore, xform);

        if numel(xform) ~= 0
            
            xform = ['--inverse ', transformation_dir, filesep, xform.name];
            fprintf('Yes-Indirect\n');
            
        else
            
            xform = '';
            fprintf('No transformation exist\n');
            
        end
    end
else
    
   fprintf('Yes-InDirect\n');
   
end

end
