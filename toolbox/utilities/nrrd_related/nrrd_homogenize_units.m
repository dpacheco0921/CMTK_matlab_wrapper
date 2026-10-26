function meta = nrrd_homogenize_units(meta)
% nrrd_homogenize_units: write micron units in one standard form.
%   Input: nrrd metadata struct. Output: the struct with spaceunits updated.
%
% Usage:
%   meta = nrrd_homogenize_units(meta)
%
% Args:
%   meta: nrrd metadata as output from nrrdread.m
%
% Returns:
%   meta: updated meta (unrecognized units are only reported, not changed)
%
% Notes:
% NOTE (known issue, not yet fixed): the micro sign in the source line is a
%   single non-UTF-8 byte, so the match depends on MATLAB's file encoding.

if contains(meta.spaceunits, 'µm') || ...
        contains(meta.spaceunits, 'microns')
    meta.spaceunits = '"microns" "microns" "microns"';
else
    fprintf(['found other units', meta.spaceunits, '\n'])
end

end