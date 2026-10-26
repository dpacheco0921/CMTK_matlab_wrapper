function delete_parpool(ppobj)
% delete_parpool: shut down a parallel pool.
%   Input: pool object (optional). Output: none.
%
% Usage:
%   delete_parpool(ppobj)
% 
% Args:
%   ppobj: parpool obj (optional; if empty the current pool, if any, is closed)
%
% Returns:
%   none
% 
% See also: parcluster parpool

if ~exist('ppobj', 'var') || isempty(ppobj)
    ppobj = [];
end

if ~exist('ppobj', 'var') || isempty(ppobj)
    delete(gcp('nocreate'));
else
    delete(ppobj);
end

end
