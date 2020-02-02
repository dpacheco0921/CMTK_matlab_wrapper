% copy, edit and save this function as 'regrelated_directories.m'
% go through each directory variable and provide the right directory per
%   system (PC, mac, or cluster)

function [refDir, RegRepoDirs, fijiDirs] = ...
    regrelated_directories
% regrelated_directories: function that provides default registration
%   related directories (refence brain directory, 
%   registration repositories (from natverse), and fiji directories)
%
% Usage:
%   [refDir, RegRepoDirs, fijiDirs] = ...
%       regrelated_directories
%
% Output:
%   refDir: directory were all nnrd and related files of reference brains 
%       are stored
%   RegRepoDirs: directories of repositories registration-related
%   fijiDirs: fiji-related directory
% 
% Notes:

% directory were all nnrd and related files of reference brains 
%   are stored
if isunix
    
    if ismac
        refDir = ['*'];
    else
        % server (linux)
        refDir = ['*'];
    end
    
elseif ispc
    
    refDir = ['*'];
    
end

% directories of repositories registration-related
RegRepoDirs{1} = ['*', filesep, 'DrosAdultBRAINdomains'];
% Reference Domains: https://github.com/VirtualFlyBrain/DrosAdultBRAINdomains
RegRepoDirs{2} = ['*', filesep, 'DrosAdultHalfBRAINdomains'];
% Reference Domains: https://github.com/VirtualFlyBrain/DrosAdultHalfBRAINdomains
RegRepoDirs{3} = ['*', filesep, 'BridgingRegistrations'];
% Reference Domains: https://github.com/jefferislab/BridgingRegistrations
RegRepoDirs{4} = ['*', filesep, 'MirrorRegistrations'];
% Reference Domains: https://github.com/jefferislab/MirrorRegistrations
RegRepoDirs{5} = ['*', filesep, 'DrosophilidBridgingRegistrations'];
% Reference Domains: https://github.com/jefferislab/DrosophilidBridgingRegistrations

% fiji-related directory
fijiDirs = [];

if ispc
    fijiDirs = 'C:\Users\*\Fiji.app\ImageJ-win64.exe';
elseif ismac
    fijiDirs = '/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx';
end

end
