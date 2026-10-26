function iObject = updObj_xyz(iObject, i_xyz)
% updObj_xyz: replace XYZ coordinates of a tree, matrix, or mesh.
%   Input: object, new [n, 3] coordinates. Output: the updated object.
% 
% Usage:
%   iObject = updObj_xyz(iObject, i_xyz)
%
% Args:
%   iObject: tree/matrix/mesh obj
%   i_xyz: input coordinates
% 
% Returns:
%   iObject: updated tree/matrix/mesh obj
%
% Notes:
% compatible with tree format from https://github.com/cuntzlab/treestoolbox
% Only single objects are handled (not the cell of traces that getObj_xyz
%   can return); for non-struct input the object is simply replaced by i_xyz.

if isstruct(iObject)
    
    fieldlist = fieldnames(iObject);
    
    if sum(contains(fieldlist, 'X'))
        
       iObject.X = i_xyz(:, 1);
       iObject.Y = i_xyz(:, 2);
       iObject.Z = i_xyz(:, 3);
       
    elseif sum(contains(fieldlist, 'vertices'))
        
       iObject.vertices = i_xyz;
       
    end
    
else
    
   iObject = i_xyz;
   
end

end