function Srf = read_srf( fileName )
%read_srf - Reads data out of a TEMPER .srf input file
%
% USE: [Srf] = read_srf;            <- graphical file selection
%  OR: [...] = read_srf( fileName );
%
%   Output "Srf" will be a struct with fields:
%
%    .comment: string from first line of file
%      .units: range\height units flag [0=ft/nmi|1=m/km] 
%    .pcunits: Ground param units flag [0=perm/cond|1=Re(eps)/Im(eps)]
%   .position: [lat,lon] of file's zero range point (empty if info not in file)
%      .range: [vector] range in units specified by .units
%     .height: [vector] range-dependent terrain height " " " "
%       .perm: [vector] range-dependent permittivity or Real(eps)
%       .cond: [vector] range-dependent conductivity or Imag(eps)
%      .rough: [vector] range-dependent rms roughness in .units
%       .file: [string] full path\fileName of .srf file
%
%   Additionally, the output structure will have another field if the file
%   contains more than 5 columns. This is a step towards forward compatibility
%   with potential format changes in future versions of TEMPER:
%
%     .other : [array] any additional columns in file, beyond col #5
%
%   Note, however, that anything more than 5 columns is not a standard TEMPER
%   format as of (and prior to) TEMPER v3.2.0.
%
%
% ©1999-2015, Johns Hopkins University / Applied Physics Lab
% Last update: 2015-02-22


% Update list: (all JZG)
% -----------
% 1999-10-13: Completed initial version
% 2001-11-09: Added .position handling
% 2007-11-05: Updated structure fields, got rid of "Big_Other" options, and
% replaced  EVAL/TEXTREAD approach for reading data array with faster FSCANF
% calls. Restructured much of the code.
% 2015-02-22: Minor fix, added fclose() before throwing format errors.


    if ( nargin == 0 ), fileName = []; end
    
    if isempty( fileName )
       [f,p] = uigetfile('*.srf');
       if isnumeric(f), Srf = []; return; end
       fileName = fullfile(p,f);
    end

    nHeaderLines = 4;
    
    % Read in header and first data line
    fid = fopen(fileName,'rt');
    for i = 1:nHeaderLines+1
        line{i} = fgetl(fid); 
    end
    
    % Reposition I/O to beginning of first data line
    frewind( fid );
    for i = 1:nHeaderLines
        fgetl(fid); % skip
    end
    
    % Read eader values from text into structure
    Srf.comment  = line{1};
    Srf.units    = sscanf(line{2},'%d',1); % reads from line #2
    Srf.pcunits  = sscanf(line{3},'%d',1); % reads from line #3
    Srf.position = get_position( line{4} ); % calls subroutine

    %this command determines how many columns are in the file's data-list
    nDataCols  = length( str2num(line{5}) );
    
    if ( nDataCols < 2 )
        fclose( fid );
        error('File does not contain the correct data');
    elseif ( nDataCols == 3 )
        fclose( fid );
        error('File contains three columns - cannot specify perm w/o cond!');
    end
    
    [dataArray,count] = fscanf( fid, '%f', [nDataCols,inf] );
    fclose(fid);
    
    dataArray = dataArray.';
    
    Srf.range  = dataArray(:,1);
    Srf.height = dataArray(:,2);
    
    if ( nDataCols >= 4 )
        Srf.perm = dataArray(:,3);
        Srf.cond = dataArray(:,4);
    else
        Srf.perm = [];
        Srf.cond = [];
    end
    
    if ( nDataCols >= 5 )
        Srf.rough = dataArray(:,5);
    else
        Srf.rough = [];
    end
    
    if ( nDataCols >= 6 )
        nExtraCols = nDataCols - 5;
        warning(['Non-standard format, ',int2str(nExtraCols),' extra',...
                 ' column(s) in file (see .other field of output struct)']);
        Srf.other = dataArray(:,6:end);
    else
        Srf.other = [];
    end
    
    % Return the called fileName as well:
    Srf.file = fileName;
    
return





function pos = get_position( str )

    try
        
        str = upper(str);
        isSouth = ~isempty(findstr(str,'°S'));
        isWest  = ~isempty(findstr(str,'°W'));
        repList = {'°','N','S','E','W'};
        for i = 1:length(repList), str=strrep(str,repList{i},''); end
        pos = sscanf(str,'%f%*[ ,]', [1,2]);
        if length(pos) ~= 2
            error('no position info detected in file - intentional error to break TRY CATCH');
        end
        if ( isSouth ), pos(1) = -pos(1); end
        if ( isWest  ), pos(2) = -pos(2); end
        
    catch
        
        pos = [];   
        
    end
    
return

