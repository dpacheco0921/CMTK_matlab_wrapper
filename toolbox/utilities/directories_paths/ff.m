function varargout = ff(varargin)
% ff: build one full file path from path pieces (wrapper of fullfile).
%   Input: path pieces. Output: the joined path.
% Usage:
%   varargout = ff(varargin)
% 
% Args:
%   varargin: path pieces to join (as in fullfile)
%
% Returns:
%   varargout{1}: joined path (a single output, not one per input)
%
% NOTE (known issue, not yet fixed): asking for more than one output
%   (nargout > 1) errors, because the single result is assigned to
%   several outputs.
% 
% See also: fullfile

N = max(nargout,1);
varargout{1:N} = fullfile(varargin{:});

end
