function xyz = getObj_xyz(iObject)
% getObj_xyz: function that extracts XYZ coordinates
%   from tree/matrix/mesh
%
% Usage:
%   getObj_xyz(iObject)
%
% Args:
%   iObject: tree/matrix/mesh obj
% 
% Returns:
%   xyz: XYZ coordinate matrix
%
% Notes:
% compatible with tree format from https://github.com/cuntzlab/treestoolbox

if isstruct(iObject)
    
    fieldlist = fieldnames(iObject);
    
    if sum(contains(fieldlist, 'X'))
        
    if numel(iObject) == 1
        
        % single trace
        xyz = [iObject.X, iObject.Y, iObject.Z];
        
    else
        
        % group of traces
        for i = 1:numel(iObject)
            xyz{i, 1} = [iObject(i).X, iObject(i).Y, iObject(i).Z];
        end
        
    end
       
    elseif sum(contains(fieldlist, 'vertices'))
        
        % single trace
        xyz = iObject.vertices;
        
    end
    
elseif iscell(iObject)
    
    if numel(iObject) == 1
        
        xyz = iObject{1};

        if size(xyz, 2) ~= 3

            xyz = xyz';

        end
        
    else
        
        fprintf('cell with multiple traces\n');
        xyz = iObject;
        
    end
    
else
    
    if size(iObject, 2) ~= 3
        
        xyz = iObject';
        
    elseif size(iObject, 2) == 3
        
        xyz = iObject;
        
    else
        
        fprintf('Error in iObject');
        xyz = [];
        
    end
    
end

end
