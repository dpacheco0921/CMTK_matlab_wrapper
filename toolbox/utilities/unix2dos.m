function unix2dos(filein, dos2unix)
% unix2dos: converts text file FILEIN from unix LF format to DOS CRLF format
%   if the optional DOS2UNIX parameter is set to true, the conversion is 
%   done the other way, i.e. DOS to UNIX format
%
% Usage:
%   unix2dos(filein, dos2unix)
%
% Args:
%   filein: text file name (full path)
%   dos2unix: direction of conversion
%       (0 = UNIX2DOS)
%       (1 = DOS2UNIX)
%
% example
% unix2dos('c:\temp\myfile.txt',true)
% converts the file myfile.txt in the directory c:\temp\ from DOS (CR/LF) to UNIX (LF)
% 
% unix2dos('c:\temp\myfile.txt')
% converts the file myfile.txt in the directory c:\temp\ from UNIX (LF) to DOS (CR/LF)

if nargin<2
    dos2unix = false;
end

LF = char(10);
CR = char(13);
[fid, fm] = fopen(filein, 'r');

if fid<0
    error([fm ' Could not open file ' filein ...
        '. Does not exist, is in use, or is read-only.'])
end

fcontent=fread(fid, 'uint8');
fcontent(fcontent == CR) = []; % remove CRs if present
if ~dos2unix
    fcontent = strrep(char(row(fcontent)), LF, [CR LF]); % replace LF with CR,LF
end    
fclose(fid);

% don't use frewind here because new write may be smaller and don't want to leave stuff at the end
[fid,fm] = fopen(filein, 'w');

if fid<0
    error([fm ' Could not open file ' filein ...
        '. Does not exist, is in use, or is read-only.'])
end

fwrite(fid, fcontent, 'uint8');
fclose(fid);

end

function y = row(x)
% row: Converts an array into a row vector
%
% Usage:
%   y = row(x)
%
%   converts x into a row vector

y = x(:).';

end
