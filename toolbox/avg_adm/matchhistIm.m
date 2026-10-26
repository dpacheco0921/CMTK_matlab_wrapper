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
%   floatIm: text to select floating images (matched anywhere in the path
%       of the .nrrd files in fDir)
%   refIm: file name of reference image
%   nSuffix: cell {old_text, new_text}; in each floating image path
%       old_text is replaced by new_text to name the output image
%       (required, e.g. {'.nrrd', '_mh.nrrd'})
%   fDir: directory of floating image
%       (default, '.')
%   rDir: directory of reference image
%       (default, '.')
%   padv: pad value
%       (default, [], no padding)
%   eFileName: extra text to further select floating images
%       (default, [])
%
% Returns:
%   (none; writes one histogram-matched .ushort image per floating image)
%
% Notes
% NOTE (known issue, not yet fixed): the status of convertx is ignored, and
%   on a re-run previous outputs may be matched as floating images.
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
