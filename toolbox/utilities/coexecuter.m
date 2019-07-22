function status_ = coexecuter(command2run, verbose)
% coexecuter: executes commands from terminal
%
% Usage:
%   coexecuter(command2run, verbose)
%
% Args:
%   command2run: command to run, can be a string or cell, 
%       if cell it executes each cell separately (PC/linux/Mac compatible)
%   verbose: verbose options
%       (0 = no verbose)
%       (1 = verbose after it is done)
%       (2 = verbose as it runs)
%       (3 = verbose as it runs)
%
% Returns:
%   status_: command exit status
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