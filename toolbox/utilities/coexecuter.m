function status_ = coexecuter(command2run, verbose)
% coexecuter: runs a system command (or each command in a cell) in the OS shell.
%   Input: command string or cell of strings, verbose level. Output: exit status.
%
% Usage:
%   coexecuter(command2run, verbose)
%
% Args:
%   command2run: command to run, can be a string or cell, 
%       if cell it executes each cell separately (PC/linux/Mac compatible)
%   verbose: verbose options (default, 1)
%       (0 = no verbose)
%       (1 = show output after it is done)
%       (2 = show output as it runs, exit status is NOT captured)
%       (3 = show output as it runs, exit status is captured)
%
% Returns:
%   status_: command exit status (0 = success), one value per command
%       when command2run is a cell
%
% NOTE (known issue, not yet fixed): with verbose = 2 the returned status
%   is always 1 (even on success) and 'successful' is not printed, because
%   the status is not captured; use verbose = 3 if the status is needed.
%   If command2run is empty, status_ is never assigned.
%
% Notes:
% see unix, dos

if ~exist('verbose', 'var')
    verbose = 1;
end

if ~isempty(command2run)
    
    if iscell(command2run)
        
        status_ = zeros(numel(command2run), 1);
        
        for i = 1:numel(command2run)
            status_(i) = execute_each(command2run{i}, verbose);
        end
        
    else
        
        [status_, ~] = execute_each(command2run, verbose);
        
    end
    
end

end

function [status_, cout] = execute_each(command2run, verbose)

status_ = 1;
cout = [];

% execute and decide if showing verbose as it runs or later
if ispc
    
    if verbose == 2
        dos(command2run);
    elseif verbose == 3
        status_ = dos(command2run);
    else
        [status_, cout] = dos(command2run);
    end
    
else
    
    if verbose == 2
        unix(command2run);
    elseif verbose == 3
        status_ = unix(command2run);
    else
        [status_, cout] = unix(command2run);
    end
    
end

if verbose == 1
    display(cout);
end

if verbose ~= 0 && status_ == 0
    fprintf('successful\n');
end

end