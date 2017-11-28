function [Head] = read_temper_header( fid )
%read_temper_header - Reads TEMPER .fld (all versions) & .spf (v3.1.2) header
%
%   Note that the file I/O pointer:
%
%       1) *must* be positioned at the beginning of the file upon input, and
%
%       2) will *not* be in the same place on output, it will be at beginning
%          of the first data record.
%
%
% USE: [Head] = read_temper_header( fid );
%
%   Input "fid" is an already-open TEMPER .fld or .spf binary file. File i/o
%   pointer must be positioned at the beginning of the file.
%
%   Output is a structure. Run help mode for more info.
%
%
% HELP MODE: read_temper_header -help
%
%
% ©2001-2015, Johns Hopkins University / Applied Physics Lab
% Last update: 2015-09-24


% Update list: (JZG unless noted)
% -----------
% 2001-01-18 Fixed error in "iter" (change 'uint' -> 'int')
% 2002-13-02 Added 'title' to structure
% 2004-02-29 ?
% 2008-11-09 Fixed conflict w/ local variable and Matlab's VER.M. Added new
% struct fields (date & time, which had always been in header but not output).
% Major revamping of the way code works - now driven by "headerInfoArray"
% instead of many individual lines of FREAD(...) code.
% 2010-07-29 Fixed bug in how v3.1.1 headers were read (80 vs 200 chars).
% 2013-03-14 Added help mode.
% 2013-12-09 Add version 3.2.0 inputs to header
% 2013-12-31 Update reading of Header for v3.2.0 inputs
% 2014-01-02 Remove numHeaderLines from header
% 2014-12-26 Minor changes, no impact to functionality.
% 2015-01-25 Undid recent changes that broken v3.2.0 functionality out into a
% different function, made changes in this code necessary to support all vers.
% 2015-02-04 Added in several forgotten fclose(fid) statements just prior to
% error() throws. Also made most likely error on cases of invalid input (i.e.,
% not a field file) more verbose/helpful.
% 2015-05-08 (kag) Remove duplicate entry for maximum range in the Header table
% 2015-05-28 Added handling for files that are empty or have corrupted headers,
% with verbose error messages.
% 2015-06-07 Fixed bug in 05-28 changes (unnecessarily threw errors for valid
% files with larger record lengths).
% 2015-09-24 Update osgSeed from uint to int (kag).


% TODO:
% ----
% - test mode
% - is there ever a big/little-endian issue that could be detected & handled 
%   here?
    

    % New, 2013-03-14
    isHelpMode = 0;
    if ( nargin == 0 )
        error('Must provide one input argument (fid)');
    elseif ischar(fid)
        if strcmpi(fid,'-help')
            isHelpMode = 1;
            % Note: cannot simply call disp_help_msg() because headerInfoArray
            % must first be defined, and before headerInfoArray can be defined,
            % we need to get past the charLen definition portion of the code.
        else
            error('First input should be an open fid (numeric), not a string');
        end
    end        
    
    if not( isHelpMode )

        % Get filename from "fid":
        [file,PERMISSION,MACHINEFORMAT] = fopen(fid);
        if isempty( file )
            try, fclose(fid); end
            error(['fid (',int2str(fid),') is not an open file id!']);
        end

        % First item in TEMPER file - all versions - is record length

        reclBytes = fread(fid,1,'int');
        check_rec_and_ver( 'record length', reclBytes, file, fid, 0, 1e14 ); % throws error if problem

        % Next item is version number.  In earlier versions of TEMPER, this
        % value was stored as 10*version (integer).  In versions 3.1.0-3.1.2 (and
        % maybe also 3.0.0???), this was changed to 100*version (integer). It was
        % again changed to 1e6*version (integer) at v3.1.4 and beyond.
        % Distiguish among those conventions here:
        verInt = fread(fid,1,'int');
        check_rec_and_ver( 'version #', verInt, file, fid, 0, 1e9 ); % throws error if problem
        
        verNum = verInt/10;
        
        % If version number is still > 10, it could be a 100*version file ...
        if ( verNum > 10 ), verNum = verInt/100; end
        
        % ... or it could be the newest 1e6*version file
        if ( verNum > 10 ), verNum = verInt/1e6; end
        
        % ... or code be a mistake (assuming verNum never > 10)
        if ( verNum > 10 )
            fclose(fid);
            errMsg = ['Version number could not be read from header.',...
                ' This could be a code bug in either TEMPER or Matlab'];
            [junk,junk,extn] = fileparts( file );
            if ~strcmpi( extn, '.fld' )
                errMsg = [errMsg, ...
                    '; however, this is most likely because the',...
                    ' specified file is not'];
            else
                errMsg = [errMsg,', or the input file may not be'];         
            end
            errMsg = [errMsg,' a valid field file: ',file];
            error( errMsg );
        end
        
        Head.file    = file;
        Head.version = verNum;
        Head.reclen  = reclBytes;

        % The title & name of restart field used to be limited to 80
        % characters, which caused errors.  After version 3.1.0, this problem
        % was fixed by using 200 characters for these header fields:
        if verNum >= 3.11 
            charLen = 200;
        else
            charLen = 80;
        end
        
    else
        
        charLen = NaN; % value doesn't matter, help message doesn't use it
        
    end
    
    % headerInfoArray:
    % --------------------------------------------------------------------------
    %   Col # 1    Col # 2  Col # 3     Col # 4                         Col #5 
    %   -------    -------  -------     -------                         ------
    %   Output     read #   read        first appeared in .fld header    /
    %   field:     values:  type:       for TEMPER version number:      /
    %   |               |   |           |                              /
    %   |               |   |           |       short description for help mode:
    %   |               |   |           |       |  (new column, 2013-03-14)
    headerInfoArray = { ...%|           |       |
        'compr',        1, 'int',       3.00,   'compression level'; ...
        'freq',         1, 'float',     3.00,   'frequency (Hz)'; ...
        'anthgt',       1, 'float',     3.00,   'antenna height'; ...
        'ipat',         1, 'uint',      3.00,   'source/pattern flag'; ...
        'beamwidth',    1, 'float',     3.00,   'fwhm 3db width (sinc only)'; ...
        'beampoint',    1, 'float',     3.00,   'pattern pointing angle (deg)'; ...
        'probangle',    1, 'float',     3.00,   'actual/adjusted problem angle (deg)'; ...
        'transfsize',   1, 'uint',      3.00,   'log2 of FFT transform size'; ...
        'pol',          1, 'uint',      3.00,   'polarization flag (0=V, 1=H)'; ...
        'complex',      1, 'uint',      3.00,   'out type (0=magnitude, 1=complex)'; ...
        'zmin',         1, 'float',     3.00,   'minimum output height'; ...
        'zmax',         1, 'float',     3.00,   'maximum output height'; ...
        'zinc',         1, 'float',     3.00,   'actual/adjusted height increment'; ...
        'nz',           1, 'uint',      3.00,   '# of height samples output'; ...
        'rmin',         1, 'float',     3.00,   'minimum output range'; ...
        'rmax',         1, 'float',     3.00,   'maximum output range'; ...
        'rinc',         1, 'float',     3.00,   'range increment'; ...
        'nr',           1, 'uint',      3.00,   '# of range samples output'; ...
        'units',        1, 'uint',      3.00,   'units flag (0=ft/nmi, 1=m/km)'; ...
        'iter',         1, 'int',       3.00,   'terrain method flag'; ...
        'teroff',       1, 'float',     3.00,   'terrain offset'; ...
        'usetag',       1, 'uint',      3.00,   'user-provided file ID / tag'; ...
        'date',         8, 'char',      3.00,   'ignore for v3.2.0; previously calculation/output date'; ...
        'time',        10, 'char',      3.00,   'ignore for v3.2.0; previously calculation/output time'; ...
        'title',  charLen, 'char',      3.00,   'user-provided title/comment'; ...
        'restart',charLen, 'char',      3.00,   'restarted-from .rsf file'; ...
        'terH_at_0',    1, 'float',     3.00,   'terrain height at zero range'; ...
        'perm',         1, 'float',     3.12,   'permittivity (if constant)'; ...
        'cond',         1, 'float',     3.12,   'conductivity in S/m (if constant)'; ...
        'roughness',    1, 'float',     3.12,   'rms roughness (if constant)'; ...
        'srffile',charLen, 'char',      3.12,   'terrain/.srf file used'; ...  
        'tlat',         1, 'float',     3.12,   'latitude from .srf file'; ...
        'tlon',         1, 'float',     3.12,   'longitude from .srf file'; ...
        'osgTimeOff',   1, 'float',     3.200007, 'time offset in sec for OSG'; ...
        'fldRngThin',   1, 'uint',      3.200007, '.fld range thinning factor'; ...
        'refExtBelow',  1, 'uint',      3.200007, 'refractivity extend-below option'; ...
        'osgSeed',      1, 'int',       3.200007, 'random seed used for OSG'; ...
        'osgOutput',    1, 'uint',      3.200007, 'OSG .wsp file output flag'; ...
        'antRef',       1, 'uint',      3.200007, 'antenna reference option (0=AGL, 1=MSL)'; ...
        'fldFormat',    1, 'uint',      3.200007, '.fld file format (0=fixed, 1=stream)'};
    %
    % Note that it was only in TEMPER version 3.0 and later that files included 
    % a comprehensive header record.  
    %
    % Also, for > v3.0 all of the above "headerInfoArray" entries should
    % correspond to a value in the list of header quantities written out by the
    % TEMPER code. A snippet of that FORTRAN code is listed here:
    %    
    %     write(io_fld) fldMaxRng,wgTimeOff, 
    %  &                    spfRngThin,fldRngThin,refExt,wgSeed,wgOutput,antRef, 
    %  &                    wgFile
    %
    % --------------------------------------------------------------------------

    
    if not( isHelpMode ) && ( verNum > 3.20 & verNum < 3.200020 )
        
        % Some special handling is required for some of the pre-beta-release
        % 3.2.0 versions, as the header was in flux at that time.
        
        temp = headerInfoArray(:,4);
        headerInfoArrayVerNums = [temp{:}]; % cell 2 num
        
        if ( verNum < 3.200005 )
            % Still had the v3.1.2 header in place
            iRem = find( headerInfoArrayVerNums > 3.12 );
            headerInfoArray(iRem,:) = [];
        elseif any( abs( verNum - [3.200005,3.200006] ) < 1e-12 ) % == w/ 1e-12 tol
            % v3.2.0.0005 & v3.2.0.0006 not supported
            fclose(fid);
            error('This pre-beta version of TEMPER v3.2.0 is not supported');
        elseif ( verNum > 3.200006 ) & ( verNum < 3.200020 )
            % Between v3.2.0.0007 & v3.2.0.0019 there were two extra .spf-file
            % related entries which were removed before beta release
            iLon = strmatch( 'tlon', headerInfoArray(:,1) );
            if length( iLon ) ~= 1
                fclose(fid);
                error('Code bug detected attempting to parse headerInfoArray');
            end
            headerInfoArray = [...
                headerInfoArray(1:iLon,:);...
              { 'spfMinHgt',  1, 'float', 3.200007, 'Min height above surface in .spf file'; ...
                'spfMaxHgt',  1, 'float', 3.200007, 'Max height above surface in .spf file'  };...
                headerInfoArray(iLon+1,:);...
                headerInfoArray(iLon+2,:);...
              { 'spfRngThin', 1, 'uint',  3.200007, '.spf range thinning factor' };...
                headerInfoArray(iLon+3:end,:)...
                               ];
        end
    
    end
    
    if isHelpMode
        disp_help_msg( headerInfoArray );
        return
    end    
    
    for iRead = 1:size(headerInfoArray,1)

        thisFld  = headerInfoArray{iRead,1};
        thisN    = headerInfoArray{iRead,2};
        thisType = headerInfoArray{iRead,3};
        incInVer = headerInfoArray{iRead,4};

        isChar = strcmpi( thisType, 'char' );

        if ( verNum >= incInVer*(1-eps) ) % *(1-eps) is a tolerance for roundoff errors

            [thisVal,count] = fread( fid, thisN, thisType );
            
            if ( count ~= thisN ) % new, 2015-05-28
                fclose(fid);
                errMsg = ['Corrupt, incomplete or invalid field file.',...
                    ' Failed to read header value "',thisFld,'".'];
                error( errMsg );
                % Note that, even though the error message does not indicate
                % this possibility, the error could also be caused if "thisN"
                % were incorrect (e.g., for updated/changed field header).
            end
                
            % Convert chars to strings
            if ( isChar )
                thisVal = reshape( thisVal, 1, length(thisVal) );
                thisVal = deblank(char(thisVal));
            end

        else

            if ( isChar )
                thisVal = '';
            else
                thisVal = [];
            end

        end        

        Head.(thisFld) = thisVal;
    end
	
return





function check_rec_and_ver( what, val, file, fid, minVal, maxVal )
% new, 2015-05-28
    errMsg = '';
    if isempty( val )
        N = dir(file);
        if N.bytes > 0
            errMsg = 'File is not empty but value read is empty.';
        else
            errMsg = 'File is empty.';
        end
    elseif ( val > maxVal ) | ( val < minVal )
        errMsg = 'Value is out of expected range, this is probably not a TEMPER output file.';
    end
    if ~isempty( errMsg )
        errMsg = ['Could not read ',what,' from header of ',file,...
            sprintf('\n'),errMsg];
        fclose(fid);
        error( errMsg );
    end            
return





function disp_help_msg( headerInfoArray )

    %          name of struct field, description,          version
    msgInfo = [headerInfoArray(:,1), headerInfoArray(:,5), headerInfoArray(:,4)];

    msgInfo = transpose( msgInfo ); % Matlab column/row-ordering quirk
    
    maxFieldnameLen = size(char(headerInfoArray(:,1)),2);
    fldFmtStr = ['%-',int2str(maxFieldnameLen),'s'];
    
    msg = sprintf( ['\nS.',fldFmtStr,' -> %s (TEMPER v%0.6f & later)'],...
                    msgInfo{:} );
                
    msg = strrep( msg, '3.000000', '3.0.0' );
    msg = strrep( msg, '3.120000', '3.1.2' );

	disp( ['Output of ',mfilename,'.m is a structure "S" with fields:',msg] );
    
return