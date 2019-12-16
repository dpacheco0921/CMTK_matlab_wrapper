function matchhistIm(floatIm, refIm, ...
    nSuffix, fDir, rDir, padv, eFileName)
% matchhistIm: match histograms of floating 
%   images to reference image using CMTK
%
% Usage:
%   matchhistIm(floatIm, refIm, ...
%       nSuffix, fDir, rDir, padv, eFileName)
%
% Args:
%   floatIm: floating images
%   refIm: reference image
%       (default, '.')
%   nSuffix: name of output image
%   fDir: directory of floating image
%   rDir: directory of reference image
%   padv: pad value
%   eFileName: extra suffix to use
%
% Notes
% replace CMTK function by matlab builtin
%   B = imhistmatchn(A,ref)

if ~exist('fDir', 'var') || ...
    isempty(fDir)
    fDir = '.';
end

if ~exist('rDir', 'var') || ...
        isempty(rDir)
    rDir = '.';
end

if ~exist('padv', 'var') || ...
        isempty(padv)
    padv = [];
end

if ~exist('eFileName', 'var') || ...
        isempty(eFileName)
    eFileName = [];
end

file2run = rdir([fDir, filesep, '*.nrrd']);
file2run = {file2run.name};
file2run = str2match(floatIm, file2run);
file2run = str2match(eFileName, file2run);

for i = 1:numel(file2run)
    
    if ~isempty(padv)
        
        st2execute = ['convertx --ushort --set-padding ', ...
            num2str(padv), ' --match-histograms ', ...
            [rDir, filesep, refIm], ' ', file2run{i}, ...
            ' ', strrep(file2run{i}, nSuffix{1}, nSuffix{2})];
    else
        
        st2execute = ['convertx --ushort --match-histograms ', ...
            [rDir, filesep, refIm], ' ', file2run{i}, ...
            ' ', strrep(file2run{i}, nSuffix{1}, nSuffix{2})];
    end
    
    coexecuter(st2execute)
    
end

end
