function [Out, tha, thr, isPartialFld] = ...
    tdata31( file, tha, thr, hdr, altLim, altUnits, rngLim, rngUnits, ...
             partialFldMode )
%tdata31 - Read TEMPER field file, v3.0 & later, w/ handling for memory errors
%
%    The primary output of TEMPER v3.0+ is a Fortran Direct-Access, Unformatted
%    binary "field file" with extension .fld. This routine reads both the header
%    and data arrays from a .fld file. For very large field files, this routine
%    provides thinning options that can avert Matlab out-of-memory errors.
%    Range and altitude thinning factors can either be specified, or
%    automatically computed based on a maximum # of array points.
%
%
% USE: T = tdata31;
%  OR: T = tdata31( file );
%
%   If a field-file name "file" is not input, the program will prompt for
%   graphical file selection. An empty input for "file" in this or any other
%   input mode will also trigger graphical file selection. The output structure 
%   "T" is described below. All data-record and header-record info from the 
%   specified field file will be loaded into this structure. 
%
%
% USE: Head = tdata31( file, 1, 1, 1 );
%
%   Only the header info is loaded. This mode is useful for quickly examining
%   the parameters used to create a field file without having to read all the
%   data records from disk into memory.
%
%
% USE: T = tdata31( file, tha, thr, 0 );
%
%   Normal thinning mode.  Reads in header and data arrays from file, thinning
%   by specific factors in  altitude and range (e.g., when entire array is too
%   big for Matlab memory). Note that a thinning factor of 1 = no thinning, 2 =
%   load every other data point, 3 = load every 3rd data point, ..., etc.
%
%       tha -> Altitude thinning factor (1 = no thinning in altitude)
%       thr -> Range thinning factor (1 = no thinning in range)
%
%
% USE: [T,tha,thr] = tdata31( file, -nma, -nmr, 0 );
%
%   Input negative values to signify a max # of points in that dimension, rather
%   than an integer thinning factor:
%
%       if nma < 0, abs(nma) -> max # of points to load in altitude
%       if nrm < 0, abs(nmr) -> max # of points to load in range
%
%   On output, "tha" and "thr" hold the automatically-selected altitude &
%   range thinning factors.
%
%
% USE: [T,tha,thr] = tdata31( file, nmax, 'A', 0 );
%  OR: [T,tha,thr] = tdata31( file, nmax, 'R', 0 );
%
%   Autothinning mode #2 -> "nmax" is maximum total # of elements in output
%   range/height array. Typically, both range & altitude are thinned equally,
%   but in some cases one dimension will be thinned by +1 over the other
%   dimension; the third input determines which dimension should be thinned by
%   +1 over the other ('A' = thin +1 in altitude, 'R' = thin +1 in range).
%
%
% USE: T = tdata31( file, tha, thr, 0, altLim, altUnits, rngLim, rngUnits );
%
%   Prop. factor data are only read for a rectangular region given by the altLim
%   and rngLim inputs. Unit strings (altUnits & rngUnits) must also be given,
%   for more info run >> help convert_length. These units inputs may also be
%   empty [] and the code will assume that user means "same units as file".
%
%   This mode is useful for quickly extracting areas of interest out of very
%   large .fld files, without encountering out-of-memory problems.
%
%
% USE: T = tdata31( file, arg2, arg3, -1, ... );
%
%   "Raw" output mode. If you have tdata31_raw2f.m, see that function's help
%   comments for more info. This mode is not yet vetted for general use.
%
%
% USE: [Head,tha,thr] = tdata31( file, arg2, arg3, 1, ... );
%
%   For any of the autothinning modes described above, input 1 for the 4th
%   argument to find out the automatically-determined thinning factors without
%   actually reading in data from file.  See comments below for a description of
%   the "Head" header-structure fields.
%
%
%
% USE: [T,tha,thr,isPartialFld] = tdata31( ..., partialFldMode );
%
%   Optional 9th input argument "partialFldMode" is a string dictating behavior
%   for partially written .fld files. Optional 4th output is a logical flag
%   indicating whether the code detected a partially written .fld file. This can
%   happen if TEMPER is still in the process of running the calculation when
%   tdata31 is called, or when TEMPER crashes or gets terminated mid-run.
%
%   The partialFldMode strings trigger the following behavior when a partially
%   written .fld file is encountered:
%
%       'error'   - throws error; this is the default when < 4 output arguments
%       'warning' - issues warning and continues; this is default when 4 outputs
%       'quiet'   - supresses warning message and continues; never the default
%       
%   Note that, regardless of this input, tdata31 will always throw an error for
%   partially written .fld files with less than 2 full data/range records. Also
%   note that the output "isPartialFld" has no meaning for hdr == 1 mode, its
%   output value will always be 0. Furthermore a user-specified rngLim will
%   prevent detection of early .fld-file termination when rngLim(2) is less than
%   the range at which the .fld file prematurely terminates.
%
%   Examples for calling tdata31 with "normal" settings on other inputs follow:
%
%       % Warn, but continue, if file was not fully written (prompt for file)
%       T = tdata31([], 1, 1, 0, [-Inf,Inf], '', [-Inf,Inf], '', 'warning' );
%       f = T.file;
%
%       % No warning and continue, up to user to check "isPartialFld":
%       [T,~,~,isPartialFld] = ...
%           tdata31( f, 1, 1, 0, [-Inf,Inf], '', [-Inf,Inf], '', 'quiet' )
%
%       % Throw an error; this is also the default behavior:
%       T = tdata31( f, 1, 1, 0, [-Inf,Inf], '', [-Inf,Inf], '', 'error' );
%
%
% OUTPUT STRUCTURE "T":
%
%   "T" is a structure with fields:
%       .ptitle : 200-character (at most) title/comment string from header
%       .r      : Range vector
%       .h      : Height vector
%       .g      : Grazing angle vector; all zeros if not calculated by TEMPER
%       .t      : Terrain height vector; all zeros if not present in TEMPER
%       .f      : "F", where abs(F)^2 is 1-way propagation factor, linear scale
%       .fdb    : 10*log10( abs( T.f ) ), set to NaN below terrain height
%       .head   : Structure holding header info, see below for more info.
%       .file   : Name of field file read into this structure by tdata31.m
%
%   T.head is a structure, for more info run:
%       >> read_temper_header -help
%
%   In addition to the struct fields generated by read_temper_header.m,
%   tdata31.m adds the following info to T.head:
%       .head.thinned_zinc : Post-tdata31-thinning altitude increment
%       .head.thinned_nz   : Post-tdata31-thinning # of altitude samples
%       .head.thinned_rinc : Post-tdata31-thinning range increment
%       .head.thinned_nr   : Post-tdata31-thinning # of range samples
%
%
% (c)1999-2016, Johns Hopkins University / Applied Physics Lab
% Contact: apl.temper@jhuapl.edu
% Last update: 2016-01-09


% Update list: (all J.Z.Gehman unless noted)
% -----------
% 2007-09-18 - Changed from 10*log10() to X2DB.M to work around memory problems
% using X2DB's inherent "chunking" capability for large arrays.
% 2007-10-19 - Changed "file doesn't end in .fld" from warning to warndlg
% (common mistake). Added missing fclose in two error-catch branches.
% 2007-10-31 - Undid a past "fix" to terrain heights and added comments to
% bottom of this file to help prevent future confusion related terrain offset.
% (note: those comments have since been moved out into tdata31_terrain_notes.m)
% 2008-02-06 - Fixed bug (.f & .fdb sizes differed if T.t > max .fld hgt).
% 2008-02-20 - Output for v3.0-fld-file terrain heights now has terrain offset
% properly added in.
% 2008-10-20 - Fixed bug for non-auto thr inputs > # ranges in file.
% 2008-10-28 - Moved unit-test subroutine out into tdata31_test.m.
% 2008-11-09 - Removed header vector from output, and made changes to function
% that reads header, read_temper_header.m.
% 2009-05-18 - Minor fix, code now throws error message for thinning==0.
% 2011-03-14 - (TRH) Added altLim and rngLim capability. Changed the read-in
% code to remove the 'for' loop over number of range steps. Added hdr = -1 for
% returning raw data format to save memory & runtime. Eliminated an extra step
% in linear->dB conversion in complex/compressed cases.
% 2012-03-28 - Updated convert -> convert_length.
% 2013-12-16 - (KAG) Merge with TRH changes from 2011 in private folder.
% 2014-01-02 - (KAG) Addedd code to handle new stream format in fld file .
% 2015-01-22 - (KAG) Bug fix to insertion of NaNs for terrain in field array.
% 2015-01-25 - Bug fixes: added missing cases to switch statement from TRH
% updates, suppressed a disp statement in quiet mode. Also cleaned up comments.
% 2015-02-08 - Bug fix to user-cancel at file prompt. Made the error on partial
% file read just a warning to faciliate reading/plotting of in-progress TEMPER
% runs (only an error if tdata31 can't read at least 1 full data record).
% 2015-07-29 - (KAG) Fix serious bug in T.f for compression levels 1 & 2 (values
% below highest terrain had been set to 0), and vectorized new code for speed.
% 2015-10-01 - Clarified header comments, trimmed down update log, renamed
% "info" input to "hdr", added auto/native units (empty trigger), made code more
% readable, fixed 2 bugs in thinning: mixed +/- tha & thr; and heavy thinning
% using 'R'/'A' mode. Slight changes to auto-thin differs by +/-1 vs. old code.
% Made .raw substructure have consistent output fields across fld-file formats.
% Added code_bug() subroutine as a single place for APL contact/email address.
% 2016-01-09 - Added isPartialFld output & partialFldMode input. Note that
% today's change alters default behavior for partial files. Before 2015-02-08
% and after today code defaults to an error. For the ~year in between it
% defaulted to issuing a warning and continuing on partial .fld files.


% Validation log:
% --------------
% 2015-10-01 - (JZG)
%  - used dbstop_everywhere to check coverage
%  - ran tdata31_test.m, which does not cover rng/alt lim
%  - ran custom set of tests that provided 100% coverage for code
%  - still have not tested v3.2.0 stream format files, nor a full-coverage test
%    using v3.2.0 field files
%  - tested .raw using tdata31_raw2f.m


% -------------------------------------------------------------------------
% Suggestions for future improvemnts -> see TODO: comments throughout file
% -------------------------------------------------------------------------


% Hardcoded settings that impact code behavior. Do not change.
quiet       = 1;  % 1 = don't print header info to screen
computePLdB = 0;  % 0 = don't compute propagation loss (saves time & memory)

% Set default for new output (2016-01-09)
isPartialFld = not(1); % false

% Check for test-mode trigger >> tdata31('test');
if ( nargin == 1 )
    if ischar( file )
        if strcmpi( file, '-test' )
            disp(['Running internal test of ',mfilename,...
                ' code - please wait...']);
            eval('tdata31_test(0)'); % using EVAL to trick jzg_depfun.m
            return % <- quit after running test
        end
    end
end


% Allow invocation as:
%   >> tdata31
%   >> tdata31( file )
%   >> tdata31( file, tha, thr, hdr )
%   >> tdata31( file, tha, thr, hdr, altLim, altUnits, rngLim, rngUnits )
%   >> tdata31( file, tha, thr, hdr, altLim, altUnits, rngLim, rngUnits, partialFldMode )
if all( nargin ~= [0,1,4,8,9] )
    error(['Wrong number of input arguments.  Type "help ', mfilename,...
        '" for more info.']);
end

if ( nargin < 1 )
    file = []; % set file to empty to trigger UIGETFILE
end

if ( nargin < 2 )% set defaults for three omitted inputs
    hdr = 0;
    tha = 1;
    thr = 1;
end

if ( nargin < 8 )% set defaults for last four omitted inputs
    isLoadRngAltLimited = 0;
    altLim    = [-inf,inf];
    altUnits  = ''; % empty means "use native units"
    rngLim    = [-inf,inf];
    rngUnits  = ''; % empty means "use native units"
else
    isLoadRngAltLimited = 1;
    if ~isempty(altUnits) && ~ischar(altUnits)
        error(['Altitude-limit units must be a string',...
            ' (see >> help convert_length)']);
    elseif ~isempty(rngUnits) && ~ischar(rngUnits)
        error(['Range-limit units must be a string',...
            ' (see >> help convert_length)']);
    elseif length(altLim) ~= 2 || ~isnumeric(altLim) ...
        error('Altitude limits must a 1x2 numeric vector: [min,max]');            
    elseif length(rngLim) ~= 2 || ~isnumeric(rngLim)
        error('Range limits must a 1x2 numeric vector: [min,max]');
    end
end

% New, 2016-01-09
if ( nargin < 9 )
    partialFldMode = ''; % treat empty as default
end
if isempty( partialFldMode )
    if ( nargout < 4 )
        partialFldMode = 'error';
    else
        partialFldMode = 'warning';
    end        
end
if ~ismember( lower(partialFldMode), {'error','warning','quiet'} )
    error(['''',partialFldMode,''' is not a valid partialFldMode string']);
end  
% End new, 2016-01-09

if isempty(file)
    [f,p] = uigetfile('*.fld','select a TEMPER field file');
    if isnumeric(f)
        Out = struct([]); 
        tha = NaN; thr = NaN;
        return; % quit if user canceled
    end
    file = fullfile(p,f);
    disp('Changing current directory to selected file''s directory');
    cd(p); % often convenient to CD in prep. for next file
else
    % 2004-08-17 change -> most reliable Matlab check for existence:
    isBadFilename = not( exist(file,'file') == 2 );
    if ( isBadFilename )
        error(['Specified file does not exist (',file,')']);
    end
    % 2004-08-17 -> check for non-.fld extension
    [fPath,fName,fExtn] = fileparts(file);
    if ~strcmpi( fExtn, '.fld' )
        warndlg('Input file does not end in .fld!');
    end
end


% Open file.  Alternate FOPENs are commented out.  Use them if reading a
% field file that was created with a different format that this machine.  If
% FID = -1, the file could not be opened

fid = fopen( file, 'r' );          % default machine format (usually works)
%fid = fopen(file,'r','ieee-le');  % DOS/Windows machine format
%fid = fopen(file,'r','ieee-be');  % UNIX machine format

if ( fid == -1 )
    error( ['File "',file,'" could not be opened - check file read/write',...
        ' permissions & make sure file isn''t read-protected'] );
end

%PRE: [Header,headerVector] = read_temper_header_OLD( fid, quiet );
Head = read_temper_header( fid );
if not( quiet )
    disp(Head);
end

if ( Head.version < 3.0 )
    disp('Wrong field file version');
    fclose(fid);
    return
end

% New "autothinning" input conventions added by JZG.  The block of code
% below merely detects these calling conventions and does some error
% checking on the inputs.  The actual autothinning code responsible for
% setting "tha" and "thr" is found lower down in this routine.
isAutoTha    = ( tha < 0 );
isAutoThr    = ( thr < 0 );
isAutoNmax   = ( tha > 1 ) & ischar(thr);
isAutoThinOn = ( isAutoTha | isAutoThr | isAutoNmax );


% ----------------------- Added 2011-03-14 (TRH) ----------------------
if ( isLoadRngAltLimited )
    
    % Only look for chunk of data indices if necessary
    
    % Adjust rmin, rmax, zmin, zmax and teroff to be rounded versions of the 
    % single-point values ...
    
    % ... calculate precision tolerance scale factor
    rmintol = 10^ceil(log10(double(eps(single( Head.rmin   )))));
    rmaxtol = 10^ceil(log10(double(eps(single( Head.rmax   )))));
    zmintol = 10^ceil(log10(double(eps(single( Head.zmin   )))));
    zmaxtol = 10^ceil(log10(double(eps(single( Head.zmax   )))));
    tertol  = 10^ceil(log10(double(eps(single( Head.teroff )))));
    
    % ... apply tolerances to certain header values
    Head.rmin   = round( Head.rmin   /rmintol)*rmintol;
    Head.rmax   = round( Head.rmax   /rmaxtol)*rmaxtol;
    Head.zmin   = round( Head.zmin   /zmintol)*zmintol;
    Head.zmax   = round( Head.zmax   /zmaxtol)*zmaxtol;
    Head.teroff = round( Head.teroff /tertol )*tertol;   
    
    % Pre-compute range and alitude vectors 
    rngVec = linspace( Head.rmin, Head.rmax, Head.nr );
    hgtVec = linspace( Head.zmin, Head.zmax, Head.nz ) + Head.teroff;
    indexAllHgts = [1:length(hgtVec)];
    indexAllRngs = [1:length(rngVec)];
    
    % Convert input alt/rng limits to native units.
    % Also handle empty inputs for units (means "assume native units")
    if ( Head.units == 0 ) % ft/nmi
        if isempty( altUnits )
            altUnits = 'ft';
            rngUnits = 'nmi';
        end
        altLimConverted = convert_length( altLim, altUnits, 'ft');
        rngLimConverted = convert_length( rngLim, rngUnits, 'nmi');
    else
        if isempty( altUnits )
            altUnits = 'm';
            rngUnits = 'km';
        end
        altLimConverted = convert_length( altLim, altUnits, 'm');
        rngLimConverted = convert_length( rngLim, rngUnits, 'km');    
     end
    
    % find desired altitude data
    indexLimHgts = indexAllHgts( altLimConverted(1) - zmintol<=hgtVec & ...
                                 altLimConverted(2) + zmaxtol>=hgtVec );
    % find desired range data
    indexLimRngs = indexAllRngs( rngLimConverted(1) - rmintol<=rngVec & ...
                                 rngLimConverted(2) + rmaxtol>=rngVec );
                               
    numAltUnthinned = length(indexLimHgts); 
    numRngUnthinned = length(indexLimRngs); 
    if numAltUnthinned == 0
        errMsg = sprintf('No data in .fld file between altitudes %g & %g %s',...
            altLim(1), altLim(2), altUnits );
        error(errMsg);
    end
    if numRngUnthinned == 0
        errMsg = sprintf('No data in .fld file between ranges %g & %g %s',...
            rngLim(1), rngLim(2), rngUnits );
        error(errMsg);
    end
    
    hgtStart   = hgtVec(indexLimHgts(1));
    iHgtStart  = indexLimHgts(1);
    iRngStart  = indexLimRngs(1);
    clear('indexLimHgts','indexLimRngs');
    
else   % Read entire range and altitude extent of prop factor matrix
    
    numAltUnthinned = Head.nz;
    numRngUnthinned = Head.nr;
    hgtStart   = Head.teroff + Head.zmin;
    iHgtStart  = 1;
    iRngStart  = 1;
    
end
% ------------------------------------------------------------------------

% Handle thinning

if ( thr == 0 | tha == 0 )
    error('Invalid input: no thinning input can ever be zero');
end

if ( isAutoNmax )
    
    [tha,thr] = autonmax_thin_factors(tha,thr,numAltUnthinned,numRngUnthinned);
    
else % not isAutoNmax
    
    if ( isAutoTha )
        nMaxInAlt = abs(tha); % nMax value input as -nMax
        tha = max( ceil( numAltUnthinned / nMaxInAlt ), 1 );
    elseif ( tha > numAltUnthinned )
        tha = numAltUnthinned;
    end
    
    if ( isAutoThr )
        nMaxInRng = abs(thr); % nMax value input as -nMax
        thr = max( ceil( numRngUnthinned / nMaxInRng ), 1 );        
    elseif ( thr > numRngUnthinned )
        thr = numRngUnthinned;
    end
    
end % of if ( isAutoNmax )

if not(quiet) && ( isAutoThinOn ) && (( tha > 1 )|( thr > 1 ))
    % Let user know the auto-determined thin factors if they are not output
    thinMsg = sprintf('Auto-thinning by %d in altitude & %d in range',tha,thr);
    disp(thinMsg); 
end

% If only looking at header, quit
% (2005-03-23: moved this below autothinning so that user can figure out
% autothinning factors w/out having to read whole file, and to accomodate tests)
if ( hdr == 1 )
    fclose(fid);
    Out = Head;
    return
end

% Calculate thinned array sizes:
numRngOut = floor(  numRngUnthinned  /thr);
numHgtOut = floor((numAltUnthinned-1)/tha) + 1;
% Adjust constants to reflect thinning:
Head.thinned_zinc = Head.zinc * tha;
Head.thinned_nz   = numHgtOut;
Head.thinned_rinc = Head.rinc * thr;
Head.thinned_nr   = numRngOut;
height = hgtStart + Head.thinned_zinc * [0:numHgtOut-1]';

% Initialize arrays and constants

isComplex = ( Head.complex==1 );
if ( isComplex )
    nPfDataPerRec = 2 * numAltUnthinned;
    nPfDataHgtOut = 2 * numHgtOut;
else
    nPfDataPerRec = numAltUnthinned;
    nPfDataHgtOut = numHgtOut;
end

switch ( Head.compr )
    case 0
        freadType       = 'single';  % changed from 'float' to accomdate pf zero declaration matrix
        phaseQuanta     = 1/(2 * pi); % radians - added to accomodate hdr = -1 cases
        magnitudeQuanta = 1; % dB - added to accomodate hdr = -1 cases
        magnitudeOffset = 0; % dB - added to accomodate hdr = -1 cases       
    case 1
        freadType       = 'int16';
        phaseQuanta     = 1/(2 * 32768); % radians
        magnitudeQuanta = 0.005;     % dB
        magnitudeOffset = -138.84;   % dB
    case 2
        freadType       = 'int8';
        phaseQuanta     = 1/(2 * 128);   % radians
        magnitudeQuanta = 0.25;      % dB
        magnitudeOffset = -18;       % dB
    otherwise
        fclose(fid);
        code_bug('Unexpected header compression flag');
end

try
    if (hdr == -1)
        pf = zeros( nPfDataHgtOut, numRngOut, freadType );
    else
        pf = zeros( nPfDataHgtOut, numRngOut ); % <- out-of-memory errors don't
        % *always* occur here, but this ZEROS command is the most likely culprit
    end
    thisRecPf = zeros( nPfDataPerRec, numRngOut, freadType );
catch
    errMsg = lasterr;
    if ~isempty(findstr( 'memory', lower(errMsg) ))
        errMsg = sprintf('\n%s', errMsg, ' ',...
            'Try tdata31 thinning or rng/alt limits to load this file.',...
            'For more info, run >> help tdata31;');
    end
    fclose(fid);
    error( errMsg );
end

% Read in data (Used to be "for i = 1:numRngOut", but now reads in entire
% area of interest at once).  Reads in only the thinned range values of
% interest, but the entire range of altitudes of interest, which are then
% thinned afterward.

% Add (kag) 1/2/14 -- determine fld file format based on header information
isFixedFormat = true;
if(~isempty(Head.fldFormat))
    if(Head.fldFormat == 1)
        isFixedFormat = false;
    end
end

% Compute starting record # within physical file:
iRec = thr + iRngStart; % +1 for header record taken into account from indexGoodRngs   
% Add (kag) 1/2/14 -- if/else block to handle fixed format or stream format
% Only difference is number of bytest per range step
if (isFixedFormat)    
    % Compute number of bytes to skip to get to starting range step
    bytesPerRngStep = Head.reclen;
    %Compute starting point. Note iRec accounts for Header.
    startPoint = (iRec-1)*bytesPerRngStep;
else
   % Compute number of bytes to skip to get to starting range step
    bytesPerRngStep = Head.nz*2^(2-Head.compr+Head.complex) + 12;
    %Compute starting point. Note iRec assumes header is included so
    %subtract off 2 here.
    startPoint = Head.reclen +(iRec-2)*bytesPerRngStep;
end

% Seek to beginning of starting record & read terrain, grazing, and range values first:
stat = fseek(fid, startPoint , 'bof');
[thisRecExtra,count3x] = fread( fid, [3,numRngOut], '3*float', thr*bytesPerRngStep-12 );

% Rewind to beginning of starting record & read pf matrix
bottom_skip_bytes = (iHgtStart-1)*2^(2-Head.compr+Head.complex)+12;
top_skip_bytes = bytesPerRngStep - (nPfDataPerRec*2^(2-Head.compr)+bottom_skip_bytes);
stat2 = fseek(fid, startPoint+bottom_skip_bytes, 'bof');
[thisRecPf,   countN] = fread( fid, [nPfDataPerRec,numRngOut], ...
    [num2str(nPfDataPerRec) '*' freadType '=>' freadType], ...
    (thr-1)*bytesPerRngStep+bottom_skip_bytes+top_skip_bytes);

% Finished reading from the file - the rest is all data manipulation in Matlab
fclose( fid );

isPartialFld = ( stat ~= 0 ) || ( stat2 ~= 0 ) || ( count3x ~= 3*numRngOut ) ...
                             || ( countN ~= nPfDataPerRec*numRngOut );
                         
if ( isPartialFld ) 
    
    % 2015-05-21 change made w/in this if-block (previously the displayed 
    % message was not quite correct w.r.t. amount of data read before fail)
    
    nRangesRead = floor( count3x/3 ); % could also use countN
    
    msg = ['Incomplete: currently running, or corrupt field file - FREAD',...
            ' failed after reading ~',int2str(nRangesRead),' range',...
            ' records (',file,')'];
        
    if ( stat == 0 ) && ( stat2 == 0 ) && ( count3x > 3*2 ) && ...
       ( countN > nPfDataPerRec*2 )
         
        % As of 2016-01-09, user can control behavior in cases when at least 2
        % data records can be successfully read from a partial .fld file:
        switch lower(partialFldMode)
            case 'error'
                error( msg );
            case 'warning'
                warning( msg );
            case 'quiet'
                % do nothing
            otherwise
                error('Code bug detected (switch on partialFldMode)'); 
                % errant strings should have been caught at input handling
        end        
        
        thisRecExtra(:,end:numRngOut) = NaN;
        thisRecPf(:,end:numRngOut)    = NaN;
        
        % Hack for range, so that plotters still work:
        % fill out the rest of the range data (via 1st column of the
        % "thisRecExtra" array) by linearly extrapolating from the last-read
        % range to the header-reported max range value in the file.
        if isfield( Head, 'fldMaxRng' ) && Head.fldMaxRng > 0
            rMaxTemp = Head.fldMaxRng;
        else
            rMaxTemp = Head.rmax;
        end
        
        iStart = max(find(~isnan(thisRecExtra(1,:))));
        lastReadRng = thisRecExtra(1,iStart);
        thisRecExtra(1,iStart:end) = linspace( lastReadRng, rMaxTemp, ...
                                        length(thisRecExtra(1,iStart:end)) );
                                    
    else
        
        error( msg );
        
    end
    
end % if ( isPartialFld )

% Thin out the record to the requested output altitude sampling:
% TODO: Adjust this indexing operation so that 0.0 altitude is always included,
% provided it's in the .fld file, regardless of tdata31 input options?
if ( isComplex )
    pf(1:2:end,:) = thisRecPf(1:2*tha:end,:);
    pf(2:2:end,:) = thisRecPf(2:2*tha:end,:);
else
    pf(1:end,  :) = thisRecPf(1:tha:end,:);
end

% Place range, terrain height and grazing angle in arrays
range(:,1)   = thisRecExtra(1,:);
terrain(:,1) = thisRecExtra(2,:);
grazing(:,1) = thisRecExtra(3,:);
clear('thisRecPf','thisRecExtra');

if ( isComplex )
    rowStride = 2;
else
    rowStride = 1;
end
iOut = [1:rowStride:size(pf,1)];

isUncompressed = ( Head.compr == 0 );

if (hdr == -1)  % Fill output struct and return if only native format requested
    
    if ( Head.iter ~= 0 )
        warning('Raw data below terrain has not been properly zeroed'); 
    end
    
    % WARNING! This is a copy-and-paste from code below
    Out.ptitle  = Head.title;
    Out.header  = 'header vector is obsolete - please use .head struct instead';
    Out.r       = range;        clear range;
    Out.h       = height;       clear height;
    Out.g       = grazing;      clear grazing;
    Out.t       = terrain;      clear terrain;
    Out.f       = [];
    Out.fdb     = [];
    Out.head    = Head;
    Out.file    = file;
    % END COPY-AND-PASTE
    
    if ( isUncompressed )
        
        if ( isComplex )
            Out.raw.real = pf(iOut,:);
            Out.raw.imag = pf(iOut+1,:);
            Out.raw.info = ...
                'linear prop factor array = complex(.raw.real,.raw.imag)';
        else
            Out.raw.mag  = pf;
            Out.raw.info = ...
                '.raw.mag is the linear prop factor array in single precision';
        end
        
    else
        
        if (Head.version < 3.1)
            Out.raw.magscale = magnitudeQuanta/2;
            Out.raw.offset   = magnitudeOffset/2;
        else
            Out.raw.magscale = magnitudeQuanta;
            Out.raw.offset   = magnitudeOffset;
        end
        
        if ( isComplex )
            Out.raw.mag = pf(iOut,:);
            Out.raw.phs = pf(iOut+1,:);
            Out.raw.infomag = ...
                ['.raw.mag is the compressed dB prop factor array magnitude',...
                ' (fdb = magscale * mag + offset)'];
            Out.raw.infophase = ...
                ['.raw.phs is the compressed radian prop factor array phase',...
                ' (phase = phsscale * phs * 2*pi)'];
            Out.raw.phsscale = phaseQuanta;
        else
            Out.raw.mag = pf;
            Out.raw.info = ...
                ['.raw.mag is the compressed dB prop factor array (fdb =',...
                ' magscale * mag + offset)'];
        end
                
    end
    
    allRawFlds = {'real','imag','info','mag','offset','magscale','infomag',...
        'phs','phsscale','infophase'}; % order matters -> see orderfields()
    
    currentFlds = fieldnames( Out.raw );
    
    extraFlds   = setdiff( currentFlds, allRawFlds );
    if ~isempty(extraFlds)
        code_bug('.raw "extraFlds" is not empty');
    end
    
    missingFlds = setdiff( allRawFlds, currentFlds );
    for iFld = 1:length(missingFlds)
       Out.raw.(missingFlds{iFld}) = [];        
    end
    
    Out.raw = orderfields( Out.raw, allRawFlds );
    
    clear('pf');
    return % <--- THIS IS THE EXIT POINT FOR HDR == -1 (RAW) MODE
    
end

% convert PF from integer representation to dB and linear forms
if ( isUncompressed )
    
    pfType = 'linear'; % i.e., data stored in file is in *linear* units
    if ( isComplex )
        pf = complex( pf(iOut,:), pf(iOut+1,:) ); 
    end
    
else
    
    pfType = 'db'; % i.e., data stored in file is in *dB* units
    pfMag = magnitudeQuanta .* pf(iOut,:) + magnitudeOffset;
    if (Head.version < 3.1)
        % Ver 3.0 output F**2 [dB] in this situation; must convert to F [dB]
        pfMag = pfMag./2; % Correct the output: F**2 -> F
        % NOTE, however, that the phase output in version 3.0 was the same
        % as later versions -> ANGLE( F ) ... *not* ANGLE( F**2 )
    end
    if ( isComplex )
        Cn    = phaseQuanta * 2*pi;
        phase = Cn * pf(iOut+1,:);
        j     = sqrt(-1);
        
        % --- This part of code was replaced on 2011-03-14 (TRH) --------
        %  % TBD add phase info w/out having to convert back to linear???
        %  pf    = ( 10.^(pfMag./10) ) .* exp( j.*phase );
        %  pfType = 'linear';
        %
        % --- with the following code -----------------------------------
        % 
        f_db = pfMag;
        f_linear = ( 10.^(pfMag./10) ) .* exp( j.* phase ); % dB to linear and make complex
        pfType = 'skip';
        %
        % ---------------------------------------------------------------
        clear('phase','pfMag'); % <- free up memory
    else
        pf    = pfMag;
        clear('pfMag');  % <- free up memory
    end
    
end


% Convert dB to linear / linear to dB as necessary
switch ( pfType )
    case 'linear'
        f_linear = pf;
        f_db     = x2db( pf, 'nowarn' ); % linear to dB
    case 'db'
        f_linear = db2x( pf ); % dB to linear
        f_db     = pf;   
    case 'skip'
        % For TRH 2011-03-24 mod
    otherwise
        code_bug('invalid pfType');
end


if ( Head.thinned_nz ~= length(f_linear(:,1)) )
    code_bug('Header.thinned_nz ~= output # of rows');
elseif ( Head.thinned_nr ~= length(f_linear(1,:)) )
    code_bug('Code bug detected -> Header.thinned_nr');
end


% Post-process / fix a bug in TEMPER v3.0's output terrain vectors - they
% did not include the terrain offset
if ( Head.version == 3.0 ) & ( abs(Head.teroff) > eps )
    warning('Correcting a nonzero-terrain-offset bug in TEMPER v3.0');
    terrain = terrain + Head.teroff;
end

if ( min(height) < max(terrain) ) % 2015-09-27 (JZG) changed <= to < 
    
    % 2015-07-28 (KAG) Vectorized and fixed serious bug for f_linear
    
    % Generate a matrix that is the same size as prop factor arrays, and is true
    % wherever the physical locations correspond to below-terrain heights.
    [terrainMatrix,heightMatrix] = meshgrid(terrain,height);
    isBelowTerrain = heightMatrix < terrainMatrix;
    
    % Set dB values to NaN below the terrain:
    f_db(isBelowTerrain) = NaN;
    
    % If compression level 1 or 2, also set linear values to 0.0 below terrain
    % (for uncompressed output TEMPER already handles this).
    if ( Head.compr == 1 ) || ( Head.compr == 2 )
      f_linear(isBelowTerrain) = 0;
    end
 
end


if not( quiet )
    % Screen output
    if ( tha > 1 )
        disp(['Data has been thinned in altitude to ',num2str(numHgtOut),...
            ' points']);
    end
    if ( thr > 1 )
        disp(['Data has been thinned in range to ',num2str(numRngOut),...
            'points']);
    end
end


if (computePLdB)
    % Convert PF to PL
    code_bug('Interface to proploss.m should not currently used');
    % rngDim = 1 % Not sure if this should be 1 or 2 ???
    % freqHz = Header.freq;
    % inArray = 2.*f_db; % <- note the factor of 2, required for accurate PL calc!
    % inUnits = 'db';
    % rngUnits = Header.units;
    % Out.pldb = 0.5.* proploss( freqHz, inArray, inUnits, range, rngUnits, rngDim );
end


% Store data in an output structure (field names need an upgrade!):
Out.ptitle  = Head.title;
Out.header  = 'header vector is obsolete - please use .head struct instead'; % <- TODO: remove this field entirely?
Out.r       = range;        clear range;
Out.h       = height;       clear height;
Out.g       = grazing;      clear grazing;
Out.t       = terrain;      clear terrain;
Out.f       = f_linear;     clear f_linear;
Out.fdb     = f_db;         clear f_db;
Out.head    = Head;
Out.file    = file; % added 2000-08-15

if ~is_equal( size(Out.fdb), size(Out.f) )
    code_bug( ['.f & .fdb fields different size for file ',Out.file] );
end

return





function [tha,thr] = autonmax_thin_factors(...
    nTotalMax, thinMoreIn, numAltUnthinned, numRngUnthinned )
% Second input must be either 'R' or 'A'

    nTotal = numAltUnthinned * numRngUnthinned;
    
    if ( nTotal <= nTotalMax )
        % No need to thin at all
        tha = 1;
        thr = 1;
        return;
    end

    thinFactor  = sqrt(nTotal/nTotalMax);
    
    % Get ready to determine the thinning factor that gets down to "nTotalMax".
    % Don't just round up or down, compute both of these integers:
    thinMin = floor( thinFactor + eps*thinFactor );
    thinMax = ceil(  thinFactor - eps*thinFactor );
    % ... the +/- eps ensures that thinMin == thinMax for perfect squares
    % ... otherwise, thinMin will == (thinMax-1)
    
    % But first, need to make sure that thinning factors do not exceed length of
    % either dimension:
    isTooMuchForAlt = ( thinMax > numAltUnthinned );
    isTooMuchForRng = ( thinMax > numRngUnthinned );
    
    if ( isTooMuchForAlt & isTooMuchForRng )
        
        % Cannot thin
        tha = 1;
        thr = 1;
        
    elseif ( isTooMuchForAlt )
        
        % All thinning must come from reduction in the range dimension
        tha = 1;
        thr = max( ceil( numAltUnthinned / nTotalMax ), 1 );
        
    elseif ( isTooMuchForRng )
        
        % All thinning must come from reduction in the altitude dimension
        tha = max( ceil( numAltUnthinned / nTotalMax ), 1 );
        thr = 1;
        
    elseif ~ischar(thinMoreIn)
        
        error(['Incorrect 3rd input, should be the character',...
            '''R'' or ''A'' in this thinning mode']);
        
    else
        
        switch upper(thinMoreIn)
            
            case 'A'        
                tha = thinMax;
                thr = thinMin;
                
            case 'R'        
                tha = thinMin;
                thr = thinMax;
                
            otherwise
                error(['Unrecognized character for 3rd input (''',thinMoreIn,...
                    '''), should be ''R'' or ''A'' in this thinning mode']);
                
        end
        
        if tha ~= thr
            if ( numAltUnthinned / tha )*...
               ( numRngUnthinned / thr ) > nTotalMax
                tha = max( tha, thr );
                thr = max( tha, thr );
            end
        end
        
    end

return





function code_bug( errMsg )
    error([sprintf('Code bug detected in %s: %s\n',mfilename,errMsg),...
        'Please send this message to apl.temper@jhuapl.edu']);
return
