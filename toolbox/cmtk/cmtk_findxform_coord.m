function xform = cmtk_findxform_coord(target, ...
    source, transformation_dir, extra_suffix)
% cmtk_findxform: find the folder with the 
%   transfomations given the target and source inputs 
%
% Usage:
%   xform = cmtk_findxform(target, ...
%       source, transformation_dir, extra_suffix)
%
% Args:
%   target: target atlas
%   source: source atlas
%   transformation_dir: transformation directory
%       (default, '.')
%   extra_suffix: extra suffix to select specific xforms
%       (default, '')   
%
% Returns:
%   xform: full path of transformations
%
% Notes:
% be aware that for coordinates the format is different than for reformatx
%   A*B*C is C^-1*B^-1*A^-1
% if reformatx gets: "a.xform b.xform c.xform"
%   then streamxform would need to get 
%   "--inverse c.xform --inverse b.xform --inverse a.xform"

if ~exist('transformation_dir', 'var')
    transformation_dir = '.';
end
if ~exist('extra_suffix', 'var')
    extra_suffix = '';
end

% case 1) when the source and target are atlases
fprintf('testing if source and target are atlases: ')
xform = [transformation_dir, filesep, target, ...
    '_', source, extra_suffix,  '.list'];

if exist(xform, 'dir')
    
    xform = ['--inverse ', xform];
    fprintf('Yes-Direct\n');

else

    xform = [transformation_dir, filesep, source, ...
        '_', target, extra_suffix,  '.list'];
    
end

% case 2) when the source is not an atlas
if ~exist(strrep(xform, '--inverse ', ''), 'dir')

    fprintf('\n testing when source is not an atlas: ')
    
    % first look for a direct transformation from source to atlas
    xform = dir([transformation_dir, filesep, target, ...
        '_', source, extra_suffix,  '*list']);

    if numel(xform) ~= 0

        xform = ['--inverse ', transformation_dir, filesep, xform.name];
        fprintf('Yes-Direct\n');
        
    else % second look for indirect transformation from source to atlas

        xform = dir([transformation_dir, filesep, source, ...
            '_', target, extra_suffix,  '*list']);

        if numel(xform) ~= 0
            
            xform = [transformation_dir, filesep, xform.name];
            fprintf('Yes-Indirect\n');
            
        else
            
            xform = '';
            fprintf('No transformation exist\n');
            
        end

    end
    
end

end
