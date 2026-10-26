function [ppobj, ppprofile] = setup_parpool(deviceID, corenum)
% setup_parpool: start a local parallel pool unless one is already running.
%   Input: device name, number of workers. Output: pool object and profile
%   (both [] if a pool already existed).
% 
% Usage:
%   [ppobj, ppprofile] = setup_parpool(deviceID, corenum)
%
% Args:
%   deviceID: 'int', internal, 'spock' or 
%       'della' or other names it assumes they are clusters
%   corenum: number of workers
% 
% Returns:
%   ppobj: parpool obj
%   ppprofile: parpool profile
%
% Notes:
% Requires Parallel Computing Toolbox. On Linux/cluster (not pc, not mac, not
%   'int') job files go to /tmp/<USER>-<SLURM_JOB_ID>.
% NOTE (known issue, not yet fixed): on Linux with deviceID empty the
%   contains() call errors (deviceID defaults to [] instead of '').
% 
% See also: parcluster parpool

if ~exist('deviceID', 'var') || isempty(deviceID)
    deviceID = [];
end

if ~exist('corenum', 'var') || isempty(corenum)
    corenum = 1;
end

ppobj = [];
ppprofile = [];

if ispc || ismac || contains(deviceID, 'int')
    
    if isempty(gcp('nocreate'))
        ppprofile = parcluster('local');
        ppobj = parpool(ppprofile, corenum);
    end
    
else
    
    if isempty(gcp('nocreate'))
        ppprofile = parcluster('local');

        % use temporary folder
        ppprofile.JobStorageLocation = ...
            strcat('/tmp/', getenv('USER'), ...
            '-', getenv('SLURM_JOB_ID'));

        ppobj = parpool(ppprofile, corenum);
    end
    
end

end
