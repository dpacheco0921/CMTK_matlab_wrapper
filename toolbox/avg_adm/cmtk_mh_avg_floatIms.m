function cmtk_mh_avg_floatIms(fSuffix, fDir, avgName, eSuffix)
% cmtk_mh_avg_floatIms: it generate average image and 
%   matched-histogram average image of a group of floating
%   images using CMTK tools
%
% Usage:
%   cmtk_mh_avg_floatIms(fSuffix, fDir, avgName, eSuffix)
%
% Args:
%   fSuffix: suffix of floating images to use
%   fDir: directory of floating images
%   avgName: output name of average image
%   eSuffix: extra suffix to select floating images

if ~exist('eSuffix', 'var') || ...
        isempty(eSuffix)
    eSuffix = [];
end 

% 1) generate initial average image
cmtk_avgtool(fSuffix, fDir, avgName, [], [], eSuffix)
%cmtk_avgtool(iIm, iDir, oName, oDir, ...
%	oIm, eiIm, oIm_format)

% 2) match histograms of all floating images to average image
matchhistIm(fSuffix, [avgName, '.nrrd'], ...
    {'.nrrd', ['_', avgName, '_mh.nrrd']}, ...
    fDir, [], [], eSuffix)
%matchhistIm(floatIm, refIm, ...
%    nSuffix, fDir, rDir, padv, eFileName)

% 1) generate match histogram average image (and its std image too)
cmtk_avgtool(['_', avgName, '_mh.nrrd'], ...
    fDir, [avgName, '_mh'])
cmtk_avgtool(['_', avgName, '_mh.nrrd'], ...
    fDir, [avgName, '_mh_std'], [], '--stdev')

end
