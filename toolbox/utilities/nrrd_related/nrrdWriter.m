function status_ = nrrdWriter(filename, matrix, pixelspacing, origin, encoding)
% nrrdWriter: function to write nrrd files
%
% Usage:
%   status_ = nrrdWriter(filename, matrix, pixelspacing, origin, encoding)
%
% Args:
%   filename: 'myimage.ext' - 'veins.nrrd'
%   matrix: data - Matlab matrix
%   pixelspacing: boxel size
%   origin: point from the image is generated
%   encoding: raw, ascii, gzip
%
% Returns:
%   status_
%
% Notes:
% Copied and edited from:
% https://www.mathworks.com/matlabcentral/fileexchange/48621-nrrdwriter-filename--matrix--pixelspacing--origin--encoding-

% This line gets the path, name and extension of our file:
% pathf = /home/mario/.../myfile.myext
% fname = myfile
% ext = .myext
[pathf, fname, ext] = fileparts(filename);

format=ext(2:end); % We remove the . from .ext
% so we extract the output format from the argument filename, instead of
% put two different arguments

matrix = permute(matrix, [2 1 3]); % so we undo permute of index in nrrdreader

dims=(size(matrix));    % matrix dimensions (size NxMxP)
ndims=length(dims);     % number of dimensions (dim n)

% =====================================================================
% Conditions to make sure our file is goint to be created succesfully.
% 
% First the code puts the argument 'encoding' in lowercase
encoding = lower(encoding);

encodingCond = isequal(encoding, 'ascii') || isequal(encoding, 'raw') || isequal(encoding, 'gzip');
assert(encodingCond, 'Unsupported encoding')

% The same with output format
format = lower(format);
formatCond = isequal(format,'nhdr') || isequal(format,'nrrd');
assert(formatCond, 'Unexpected format');

% ======================================================================
% Now, if our conditions are satisfied:
if (encodingCond && formatCond)
    
    % Header
    % Open, filename (which specifies output format) and write binary
    fid = fopen(filename, 'wb');
    fprintf(fid,'NRRD0004\n');      % NRRD type 4
    
    % Type of variable we're storing in our file
    mtype=class(matrix);
    outtype=setDatatype(mtype);
    fprintf(fid,['type: ', outtype, '\n']);    
    
    fprintf(fid,['encoding: ', encoding, '\n']);
    
    [~,~,endian] = computer();
    if (isequal(endian, 'B'))
        fprintf(fid,'endian: big\n');
    else
        fprintf(fid,'endian: little\n');
    end
    
    fprintf(fid,['dimension: ', num2str(ndims), '\n']);
    
    fprintf(fid,['sizes: ', num2str(dims), '\n']);

    fprintf(fid,['space dimension: ', num2str(ndims), '\n']);
    
    if isequal(ndims, 2)
        fprintf(fid,['space directions: (', num2str(pixelspacing(1)), ...
            ',0) (0,', num2str(pixelspacing(2)), ')\n']);
        %fprintf(fid,'kinds: domain domain\n');
        fprintf(fid,'space units: "microns" "microns"\n');
    elseif isequal (ndims, 3)
        fprintf(fid,['space directions: (', num2str(pixelspacing(1)), ...
            ',0,0) (0,', num2str(pixelspacing(2)), ',0) (0,0,', ...
            num2str(pixelspacing(3)), ')\n']);
        %fprintf(fid,'kinds: domain domain domain\n');
        fprintf(fid,'space units: "microns" "microns" "microns"\n');
    end
    
    %if isequal(ndims, 2)
    %    fprintf(fid,'space: left-posterior\n');
    %elseif isequal (ndims, 3)
    %    fprintf(fid,'space: left-posterior-superior\n');
    %end
    
    if isequal(ndims, 2)
        fprintf(fid,['space origin: (', num2str(origin(1)),',', num2str(origin(2)),')\n']);
    elseif isequal (ndims, 3)
        fprintf(fid,['space origin: (', num2str(origin(1)), ...
            ',',num2str(origin(2)),',', num2str(origin(3)),')\n']);
    end    
    
    if (isequal(format, 'nhdr')) 
        
        fprintf(fid, ['data file: ', [fname, '.', encoding], '\n']);
        fclose(fid);
        
        if isequal(length(pathf),0)
            fid = fopen([fname, '.', encoding], 'wb');
        else
            fid = fopen([pathf, filesep, fname, '.', encoding], 'wb');
        end
        
    else
        
        fprintf(fid,'\n');
        
    end
    
    status_ = writeData(fid, matrix, outtype, encoding);
    fclose(fid);
    
end

function datatype = setDatatype(metaType)
% setDatatype: Determine the datatype
%   From mtype (matlab) to outtype (NRRD)
%
% Usage:
%   datatype = setDatatype(metaType)
%
% Args:
%   metaType: matlab datatype
%
% Returns:
%   datatype: NRRD type

% Determine the datatype
switch (metaType)
    
     case {'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64',...
           'uint64', 'double'}
        datatype = metaType;
    case {'single'}
        datatype = 'float';
    otherwise
        assert(false, 'Unknown datatype')
  
end
   
function status_ = writeData(fidIn, matrix, datatype, encoding)
% setDatatype: Determine the datatype
% From mtype (matlab) to outtype (NRRD)
%
% Usage:
%   datatype = setDatatype(metaType)
%
% Args:
%   fidIn: is the open file we're overwriting
%   matrix: data that have to be written
%   datatype: type of data: int8, string, double ...
%   encoding: raw, gzip, ascii
%
% Returns:
%   status_

switch (encoding)
    case {'raw'}
        
        status_ = fwrite(fidIn, matrix(:), datatype);
        
    case {'gzip'}   
        
         % Store in a raw file before compressing
         tmpBase = tempname(pwd);
         tmpFile = [tmpBase '.gz'];
         fidTmpRaw = fopen(tmpBase, 'wb');
         assert(fidTmpRaw > 3, 'Could not open temporary file for GZIP compression');

         fwrite(fidTmpRaw, matrix(:), datatype);
         fclose(fidTmpRaw);

         % Now we gzip our raw file
         gzip(tmpBase);

         % Finally, we put this info into our nrrd file (fidIn)
         fidTmpRaw = fopen(tmpFile, 'rb');
         %tmp = fread(fidTmpRaw, inf, [datatype '=>' datatype]);
         tmp = fread(fidTmpRaw, inf, 'uint8=>uint8');
         % ok = fwrite(fidIn, tmp, datatype);
         status_ = fwrite(fidIn, tmp, 'uint8');

         fclose(fidTmpRaw);
         
         try
            system(['rm -f ' tmpFile]);
            system(['rm -f ' tmpBase]);
         catch
            system(['del -f ' tmpFile]);
            system(['del -f ' tmpBase]);             
         end
         
    case {'ascii'}
        
        status_ = fprintf(fidIn,'%u ',matrix(:));
        
    otherwise
        
        assert(false, 'Unsupported encoding')
        
end
