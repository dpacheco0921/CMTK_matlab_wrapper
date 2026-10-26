function cmtk_mh_avg_floatIms(fSuffix, fDir, avgName, eSuffix)
% cmtk_mh_avg_floatIms: it generate average image and 
%   matched-histogram average image of a group of floating
%   images using CMTK tools
%
% Usage:
%   cmtk_mh_avg_floatIms(fSuffix, fDir, avgName, eSuffix)
%
% Args:
%   fSuffix: text to select floating images (matched anywhere in the path)
%   fDir: directory of floating images
%   avgName: output name of average image (written to the current folder)
%   eSuffix: extra text to select floating images
%       (default, [])
%
% Returns:
%   (none; writes avgName.nrrd, avgName_mh.nrrd, avgName_mh_std.nrrd and one
%   '_avgName_mh.nrrd' image per floating image)
%
% Notes:
% NOTE (known issue, not yet fixed): on a re-run, previous '_mh' images in
%   fDir may be picked up as floating images, and failures are not checked.

if ~exist('eSuffix', 'var') || ...
        isempty(eSuffix)
    eSuffix = [];
end 

% 1) generate initial average image
cmtk_avgtool(fSuffix, fDir, avgName, [], [], eSuffix)
%cmtk_avgtool(iIm, iDir, oName, oDir, ...
%	oIm, eiIm, oIm_format)

% 2) match histograms of all floating images to average image
% why: images with different brightness would bias the final average
matchhistIm(fSuffix, [avgName, '.nrrd'], ...
    {'.nrrd', ['_', avgName, '_mh.nrrd']}, ...
    fDir, [], [], eSuffix)
%matchhistIm(floatIm, refIm, ...
%    nSuffix, fDir, rDir, padv, eFileName)

% 3) generate match histogram average image (and its std image too)
cmtk_avgtool(['_', avgName, '_mh.nrrd'], ...
    fDir, [avgName, '_mh'])
cmtk_avgtool(['_', avgName, '_mh.nrrd'], ...
    fDir, [avgName, '_mh_std'], [], '--stdev')

end
