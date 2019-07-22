function iObject = updObj_xyz(iObject, i_xyz)
% updObj_xyz: function that updates XYZ coordinates 
%   from tree/matrix/mesh
% 
% Usage:
%   updObj_xyz(iObject, i_xyz)
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