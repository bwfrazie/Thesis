function varargout = getset_temper_input( temperInFile, mode, param, value )
%getset_temper_input - Queries/modifies a TEMPER input (.in) file
%
%   This routine provides access for getting & setting values in a TEMPER input
%   file. It should work for v3.0.0 through v3.2.1 files.
%
%   KNOWN LIMITATIONS:
%   -----------------
%
%   - Current code is unnecessarily slow in struct and multi-input (cell "param" 
%     & "value") modes; this will be addressed in an update. Note, however, that
%     the fastest mode of operation - now and always - is the 'fprintf' mode.
%
%   - Related to the above limitation, the filelrep.m dependency will be removed
%     in a future update. Avoid using that function directly.
%
%   - Code will get values from PF Altitudes table, but cannot set this param.
%
%   - Code will crash if you attempt to assign a new v3.2 variable using a 
%     temperInFile that has the old v3.1.2 format.
%
%   - In get/set modes the function is case insensitive w.r.t. parameter names;
%     however, struct-mode output uses mixed case.
%
%   - Your own input file's comments may get overwritten by using this function.
%
%   - Section dividers (e.g., '**** Refractivity') will not always show up in
%     the standard way after this function reads/writes from a .in file.
%
%
% USE: value = getset_temper_input( temperInFile, 'get', param );
%
%   Input parameter names are *not* case sensitive. Multiple parameters can be
%   specified in a cell, in which case the output value will also be a cell with
%   the same # of elements as the input "param" cell.
%
%
% USE: [value1,value2,value3,...] = getset_temper_input( ... );
%
%   Same as above, except that cell input param{1}, param{2}, param{3}, ....
%   correspond to outputs value1, value2, value3, ...
%
%
% USE: getset_temper_input( temperInFile, 'set', param, value );
%
%   Sets value for a given parameter.
%
% 
% USE: getset_temper_input( temperInFile, 'set', Struct );
%
%   Same as above, except that 1 or more parameters can be input as a structure:
%
%   Struct.param1 = value1;
%   Struct.param2 = value2;
%   ... etc
%
%   Currently the code loops and performs separate I/O for each parameter, but
%   future versions will handle this more efficiently.
%
%
% USE: paramList = getset_temper_input;
% USE: [paramList,isNumeric] = getset_temper_input;
%
%   In both of these modes, call the function without any input arguments to get
%   a list (cellstr) of parameter names and, optionally, a second output
%   argument also gets a corresponding vector that is true (1) for any parameter
%   that takes numeric values (0 = character/string values).
%
%
% USE: fmt = getset_temper_input( templateInFile, 'fprintf', varyParams, [comments] );
%
%   Outputs a fprintf/sprintf format string "fmt" that can be used to optimize
%   speed & drive space when creating large numbers of input files. Optional
%   fourth input determines whether comments are included:
%       comments == 'COMMENTS_OFF'    % No comments
%       comments == 'COMMENTS_SPARSE' % Only '*' between sections <- default
%       comments == 'COMMENTS_ON'     % All comments
%
%   The output "fmt" string will have fprintf placeholders for any parameters
%   you list in "varyParams" (cellstr). These must be listed in the order they
%   appear in the input file. All other parameters will be inserted as static
%   strings in the "fmt" output using values from the template input file
%   "templateInFile".
%
%   Note that this mode should work for v3.1.2 and v3.2.0 style input files, but
%   not for older (e.g., v3.1.0 or v3.0.0) input files. And if the specified
%   template file is a v3.1.2-style input file, the output "fmt" will *not*
%   include any of the new v3.2.0 parameters. Provide a template file that
%   includes the new v3.2.0 lines at the end of the file if you want the
%   generated format to include those parameters.
%
%   The intended use of this mode is illustrated in an example, below:
%
%   EXAMPLE: 
%
%       % For this to work, you must have the following files in your current
%       % directory: test.in + ed05m, ed10m, ed15m & ed20m.ref
%
%       templateInFile = 'test.in';
%       varyParams     = {'frequency','refFile'};
%
%       fmt = getset_temper_input( templateInFile, 'fprintf', varyParams );
%
%       freqHz      = 3e9;
%       refFileList = {'ed05m.ref','ed10m.ref','ed15m.ref','ed20m.ref'};
%       for iRef = 1:length( refFileList )
%           fid = fopen(['new_file_',int2str(iRef),'.in'],'wt');
%           fprintf( fid, fmt, freqHz, refFileList{iRef} );
%           fclose( fid );
%       end
%   
%
% USE: Input = getset_temper_input( temperInFile, 'struct' );
%
%   Outputs a structure using the parameter names for fields, populated with
%   values from the specified input file.
%
%
% USE: Input = getset_temper_input( temperInFile, 'check' );
%
%   Same as above, with handling for file errors. This mode is *ONLY* for use in
%   debugging/checking input files, since the output structure may not always
%   have all fields, and existing fields may be improperly filled, when calling
%   getset_temper_input in this mode.
%
%   The function will display a message to the screen and pause (wait for
%   keypress) in this mode.
%
%
% USE: getset_temper_input -help % <- Prints help info about all the parameters
%  OR: getset_temper_input       %    Also prints info if no input or output
%
%
% ©2007-2016, Johns Hopkins University / Applied Physics Lab
% Last update: 2016-08-18


% Update list: (JZG unless noted)
% ------------
% 2007-10-02 - Created original version
% 2009-10-28 - Added all remaining params except 'pfTableAlts' (can't do that 
% yet). Code now prints comments into file on 'set'. Improved error msgs.
% 2009-11-11 - Fixed bug when text input (e.g. 'patFile') was empty. Modified
% get_pftable_altitude_list() to Dahlgren/LCM ppfTemper.m-generated .in files.
% Added '-test' & '-help' modes. Error checks for NaN and empty numeric values. 
% 2009-11-18 - Added [param1,param2,param3,...] output calling convention.
% 2010-01-31 - Fixed bug in paramList-output mode from 2009-11-18 mods.
% 2010-10-13 - Catches (error) .in files that don't exist or don't end in '.in'.
% 2013-12-04 - (griffka1) New v3.2 inputs: wavegen seed and WSP output.
% 2013-12-09 - (griffka1) New v3.2 input: antenna reference flag.
% 2013-12-31 - (griffka1) New v3.2 inputs: fld format (stream/fixed).
% 2014-04-09 - Added optional 2nd output arg isNumeric.
% 2014-12-18 - (griffka1) Update default commens for rough surface and rouhness.
% 2014-01-07 - Updated comments to be consistent with v3.2 User Guide. Fixed 
% mistake in v3.2 inputs (line 72 was fldHeightMax, should've been rngMaxFld).
% 2015-01-29 - Renamed 'osgTimeStep' to 'osgTime'. Added 'struct' and 'fprintf'
% modes. Added test for fprintf in unit tester. Added test for empty chars.
% Fixed logic that handled PF Table Altitudes. Set limit on # of table entries
% (nMaxTableEntriesAssumed). Improved function header comments.
% 2015-01-31 - Added '*' on line #46 in COMMENT_OFF mode to prevent TEMPER from
% crashing. Updated fprintf-mode logic to handle v3.1.2 input files.
% 2015-05-22 - Ad hoc fix for reading/getting from v3.1.2 input files.
% 2015-08-06 - Very minor: now accepts '-struct' as well as 'struct'.
% 2015-09-30 - Added DISP message to make "vars out of order" error helpful.
% 2015-11-10 - Added 'check' mode for debugging.
% 2016-02-02 - Added structure-set mode (loop for now, see TODO items for fix).
% 2016-08-16 - (griffka1) Update comments that are printed to input file.
% 2016-08-19 - Fixed bugs: mangled .in for COMMENTS_OFF fprintf mode, 0-length
% PF Alt tables, blank lines in PF Alt table, and handling for large osgSeed
% values (tracker issue #199). Significant updates to unit test, which found
% most of the fixed bugs. Updated header comments and TODO list. Removed
% unnecessary warning about new-line (NLC) on Mac/Linux. 


% Validation log: (all JZG unless noted)
% --------------
% 2009-11-11 - unit test + dbstop_everywhere for coverage.
% 2016-08-19 - updated unit test + dbstop_everywhere for coverage. Near-100%.


% TODO: prioritized top-to-bottom/most-to-least important (JZG)
% ----
%
%   1) Replace filelrep.m dependency.
%
%   2) Add 'set' mode, many more tests for, and fix zero-length handling of the
%      PF Altitudes table.
%
%   3) Create an 'update' mode that's analogous to 'set', except that file
%      datestamp isn't updated unless file's current value really needs to
%      change - would help automated TEMPER runs where Matlab code depends on
%      is_older() to determine if executable needs to be rerun, or if old .fld
%      file can simply be read w/out redoing TEMPER execution on that case.
%
%   4) Allow 'set' mode to create a new file.


    isHelpMode = 0;
    if ( nargin == 1 )
        flag = lower(temperInFile);
        switch flag
            case '-test'
                run_test;
                return;
            case '-help'
                isHelpMode = 1;
            % NO OTHERWISE CASE, IT WILL CAUSE PROBLEMS!
            % Invalid inputs will be handled later in code ...
        end
    end
    
    % Sruct-set mode, added 2016-02-02.
    % Interface (in/out) is good but this implementation is too slow. Only being
    % used because it was very fast to code up this way. See TODO items for ways
    % to make this significantly faster and cleaner.
    if ( nargin == 3 ) && isstruct( param )
        S = param; clear('param');
        paramList = fieldnames( S );
        for iParam = 1:length(paramList)
            thisParam = paramList{iParam};
            thisValue = S.(thisParam);
            getset_temper_input( temperInFile, 'set', thisParam, thisValue );
        end
        return % <---- exit point
    end
    
    % Any input above line #linePfTableAlts will always be on the
    % same line of the .in file; inputs below this line can potentially be
    % offset by the # of entries in the "List of Table Altitudes".
    linePfTableAlts = 50;
    % NOTE: changed from 49 to 50 on 2015-01-29. Line #49 is a now-defunct line
    % that used to provide the # of PF table altitudes. At some point (v3.1.0?
    % v3.1.2?) TEMPER was updated to automatically determine the # of altitude
    % entries and Line #49 started to be ignored completely. My original Matlab
    % code mistook that line for the beginning of the list of altitudes. (JZG)
    nTableLinesAssumed = 1; % <- kept this at 1 so inFileInfo col #2 didn't have
                            %    to also change below the PF table.

    true  = (1==1);
    false = not(true);
    
    % inFileInfo columns:
    % ------------------------------------------
    % 1) param name, 2) nLine,   3) is numeric?, 4) comment
    inFileInfo = {...
        'title',        1,         false,   '';...
        'integerTag',   2,         true,    'Integer file identifier/tag';...
        'units',        4,         true,    'Units [0=ft & nmi|1=m & km]';...
        'fileProtect',  5,         true,    'Protect old output files? [0=no|1=yes]';...
        'frequency',    7,         true,    'Frequency [Hz]';...
        'antHgt',       8,         true,    'Antenna height [ft|m]';...
        'patFlag',      9,         true,    'Source flag [0=Sinc|1=User Sym|2=User Antisym|3=Plane Wave|4=User Asym]';...
        'beamWidth',   10,         true,    'Antenna pattern FWHM (3 dB) beamwidth [deg] (for pat flag 0)';...
        'beamPoint',   11,         true,    'Beam pointing (elevation) angle [deg]';...
        'polarization',12,         true,    'Polarization flag [0=vertical|1=horizontal]';...
        'patFile',     14,         false,   ''; ...
        'propagator',  16,         true,    'Propagator type [0=narrow|1=wide]';...
        'paMin',       17,         true,    'Minimum problem angle required [deg] (0.0 = auto)';...
        'permCondType',18,         true,    'Surface type [0=ocean|1=PC|2=constant|3=from .srf file]';...
        'conductivity',19,         true,    'Surface conductivity [S/m] (for surface type 2)';...
        'permittivity',20,         true,    'Surface relative permittivity (for surface type 2)';...
        'absorpType',  21,         true,    'Volume absorption type [0=none|1=from .ref file|2=constant]';...
        'absorpCoef',  22,         true,    'Volume absorption coeff [dB/nmi|dB/km] (for volume abs. type 2)';...
        'earthGeom',   23,         true,    'Earth geometry [0=spherical|1=flat]';...
        'hgtMaxCalc',  24,         true,    'Calculation altitude ("Min required max alt.") [ft|m] (0.0 = auto)';...
        'hgtInc',      25,         true,    'Maximum altitude increment [ft|m] (0.0 = auto)';...
        'rngMax',      26,         true,    'Maximum problem range [nmi|km]';...
        'rngInc',      27,         true,    'Range increment [nmi|km]';...
        'roughType',   28,         true,    'Rough surf. calc. [-1=just angles|0=none|1=const|2=from .srf file|3=OSG|4=OSG+const]';...
        'roughness',   29,         true,    'rms surface roughness [ft|m] (for rough surf = 1 or 4)';...
        'grzEstMethod',31,         true,    'Grazing angle estimation [0=SE|1=GO|2=4/3 earth|3=auto]';...
        'createGrz',   32,         true,    'Grazing angle output file [0=don''t create|1=create]';...
        'terrainType', 34,         true,    'Terrain type [0=flat|1=knife edge|2=LSM|3=hybrid]';...
        'createSdf',   35,         true,    'Processed surface data output file [0=off|1=on]'; ...                    
        'srfFile',     37,         false,   ''; ...            
        'complex',     39,         true,    'Output type [0=magnitude|1=complex]';...
        'rngMinFld',   40,         true,    'Minimum .fld output range [nmi|km]';...
        'hgtMinFld',   41,         true,    'Minimum .fld output altitude [ft|m] (0.0 = auto)';...        
        'hgtMaxFld',   42,         true,    'Maximum .fld output altitude [ft|m] (0.0 = auto)';...       
        'fldHgtThin',  43,         true,    '.fld file altitude thinning [1=none|2=every other|etc.]';...
        'fldSizeWarn', 44,         true,    '.fld file size warning [0=don''t warn|1=warn]';...
        'compress',    45,         true,    '.fld compression level [-1=no file|0=normal|1=1/2|2=1/4]';...
        'pfTableFlag', 47,         true,    'Propagation factor table [0=don''t print|1=print]';...
        'pfTableRngInc',48,        true,    'PF table range increment [nmi|km]';...
        'pfTableAlts', linePfTableAlts, true, '';...    
        'prtRefSummary',52,        true,    'Print refractivity summary in print file? [0=no|1=yes]';...
        'refFile',     54,         false,   ''; ...
        'refExtend',   55,         true,    'Extend with standard atmosphere if necessary? [0=no|1=yes]';...
        'isRestarted', 57,         true,    'Restarted Case? [0=no|1=yes]';...
        'rsfFile',     59,         false,   '';...
        'rngRestart',  60,         true,    'Maximum startup range [nmi|km]';...
        'rng1stRsfOut',62,         true,    'Starting output range [nmi|km]';...  
        'rngIncRsfOut',63,         true,    'Output range increment [nmi|km]';...  
        'createRsf',   64,         true,    'Create output .rsf file? [0=no(default)|1=yes]';...  
        'createSpf',   66,         true,    'Create output .spf File? [0=no(default)|1=yes]';...
        'spfHeightMin',68,         true,    'Minimum height above surface in .spf file [ft|m]';...
        'spfHeightMax',69,         true,    'Maximum height above surface in .spf file [ft|m] (0.0 = auto)';...
        'spfRngThin',  70,         true,    '.spf range thin factor';...
        'fldRngThin',  71,         true,    '.fld File range thin factor';...
        'rngMaxFld',   72,         true,    '.fld File maximum range [nmi|km] (0.0 = auto)';...
        'fldFormat',   73,         true,    '.fld file format [0=fixed record|1=stream]'; ...
        'extBelow',    74,         true,    'Extend refractivity below .ref file [0=extend gradient bounded|1=unbounded]';...
        'antReference',75,         true,    'Antenna Height Reference [0=AGL|1=Above MSL]';...
        'osgFile',     77,         false,   '';...
        'osgTime',     78,         true,    'OSG realization time (seconds from time zero)';...
        'osgSeed',     79,         true,    'OSG realization random seed (integer)';...
        'osgOutFlag',  80,         true,    'OSG Wave spectrum output flag [0=off|1=on]';...     
        'surfParamFile', 81, false, 'Surface param file (200 char max) (ter type 1,2,3; surf type 3; rough surf 2):  '; ... 
        };
    % ------------------------------------------
    % Note about 'osgSeed' -> see TODO comment in make_print_fmt() if you ever
    % change this string!
    
   
    % Note that nLine is based on a file w/ "nTableLinesAssumed" lines in the PF
    % table. Check that assumption here:
    ind = strmatch( lower('prtRefSummary'), lower(inFileInfo(:,1)), 'exact' );
    if length( ind ) ~= 1
        error(['Code bug detected - could not find ''prtRefSummary'' to',...
            ' double-check nTableLinesAssumed value']);
    elseif ( inFileInfo{ind,2} ~= linePfTableAlts + nTableLinesAssumed + 1 )
        error(['Code bug detected - linePfTableAlts does not match col#2',...
            ' of inFileInfo']);
    end
    
    % If running in help mode, return here - this is the only mode that doesn't
    % require an existing input file to be listed as first input arg...
    if ( isHelpMode )
        display_help( inFileInfo );
        return
    end
        
    lookupParamNameList = inFileInfo(:,1);
    
    % Check inputs
    if ( nargin == 0 )
        
        % ---------------------------------------------------
        % No-input mode -> return a list of valid param names
        % ---------------------------------------------------
        
        if ( nargout == 0 )
            display_help( inFileInfo ); 
            % Effectively suppress the list of parameter names from printing to
            % screen, and instead "ans" variable will be this additional help
            % message;
            value = sprintf('\n%s',...
                'To get cellstr variable holding all paramter names, run:',...
               ['  >> paramList = ',mfilename,';']);
        else
            value = lookupParamNameList;
        end
        varargout(1) = {value};
        % Optional isNumeric output, added 2014-04-09
        if ( nargout > 1 )
            varargout(2) = {[inFileInfo{:,3}]'}; 
        end
        % Hidden 3rd output for unit tests, added 2016-08-18
        if ( nargout > 2 )
            varargout(3) = {[inFileInfo{:,2}]'}; % line #
        end
        return; 
        
    else
        
        % ---------------------
        % All other input modes
        % ---------------------
        
        if ( nargin < 2 )
            error(['When providing a file (1st input), a second input (mode)',...
                ' is always required.']);
        end
        
        switch lower(mode)
            
            case 'get'
                if (nargin ~= 3)
                    error('Incorrect # of inputs - expecting 3 in GET mode'); 
                end
                
            case 'set'
                if (nargin ~= 4)
                    error('Incorrect # of inputs - expecting 4 in SET mode'); 
                end
                
            case {'check','-check'} % TODO: merge this with struct case?
                % The only difference is that this case loops over calls to
                % getset_temper_input externally (vs. internal loop) so that
                % partial-reads can be reported out to the user before throwing
                % an error. NOTE, however, that a "merged" solution is not as
                % easy as it might initially seem, since the code in the struct
                % branch called getset_temper_input outside the loop with the
                % expectation of a future upgrade that would make
                % getset_temper_input faster (i.e., *NO* internal looping) in
                % the case where multiple parameters are queried in one call.
                % 2015-11-10 (JZG)
                if ( nargin ~= 2 )
                    error('Incorrect # of inputs - expecting 2 in CHECK mode'); 
                end                    
                fldNames = lookupParamNameList;
                errMsg = 'No errors found';
                for iFld = 1:length(fldNames)
                    try
                        values{iFld} = getset_temper_input( ...
                            temperInFile, 'get', fldNames {iFld} );
                        S.(fldNames{iFld}) = values{iFld};
                    catch
                        errMsg = lasterr;
                        break % <--------- stop loop
                    end
                end
                varargout{1} = S;
                disp(errMsg);
                disp('HIT ANY KEY TO CONTINUE ...'); pause; % <-- wait for user
                return % <------------------ end of routine's execution, here             
                
            case {'struct','-struct'}
                if ( nargin ~= 2 )
                    error('Incorrect # of inputs - expecting 2 in STRUCT mode'); 
                end                    
                fldNames = lookupParamNameList;
                values   = getset_temper_input( temperInFile, 'get', fldNames );
                for iFld = 1:length(fldNames)
                    S.(fldNames{iFld}) = values{iFld};
                end
                varargout{1} = S;
                return % <------------------ end of routine's execution, here             
                
            case 'fprintf'
                if (nargin == 3)
                    comments = 'COMMENTS_SPARSE';
                elseif (nargin == 4)
                    comments = value;
                else
                    error('Incorrect # of inputs - expecting 3 or 4 in FPRINTF mode'); 
                end
                if (nargout ~= 1)
                    error('Must provide exactly 1 output arg in FPRINTF mode');
                end
                varargout{1} = make_print_fmt( inFileInfo, temperInFile, ...
                                               param, comments );
                return % <------------------ end of routine's execution, here          
                
            otherwise
                if all(nargin~=[3,4])
                    error('Incorrect # of inputs');
                else
                    error(['Invalid 2nd input (mode), should be',...
                           ' ''get'', ''set'' or ''fprintf''']);
                end
                
        end
        
    end
        
    % Case-insensitive (w.r.t. input parameter names)
    param = lower(param);
    lookupParamNameList = lower(lookupParamNameList);
    
    isSetMode = strcmpi( mode, 'set' );
    
    if ~exist( temperInFile, 'file' )
        error(['Input file does not exist! -> ',temperInFile]);
    else
        [junk,junk,extn] = fileparts( temperInFile );
        if (isSetMode && ~strcmpi( extn, '.in' ))
            % Use an error here to prevent unintentional overwriting of other
            % files...
            error('Input file does not end in .in');
        end
    end        
    
    wasCellInput = iscell(param); % TBD accept structures in addition to cells?
    
    if ~iscell(param)
        param = {param}; 
    end
    if isSetMode && ~iscell(value)
        value = {value}; 
    end
    
    % Loop over the input parameters "params"
    for iParam = 1:length(param)
        
        thisParam = param{iParam};
        
        % Backward compatibility:
        thisParam = backcompat( thisParam );
    
        iThis = strmatch( thisParam, lookupParamNameList, 'exact' );
        if length(iThis) == 0
            error(['No nLine for param ''',thisParam,'''']);
        elseif length(iThis) > 1
            error(['Code bug detected in "inFileInfo" - param name ''',...
                thisParam,''' is not unique!']);
        end

        nLineList(iParam)   = inFileInfo{iThis,2};
        isNumList(iParam)   = inFileInfo{iThis,3};
        commentList{iParam} = inFileInfo{iThis,4}; 
        
    end
    
    % If any of the requested parameters fall below the PF table, must check to
    % see if this input file contains a different # of table entries than what
    % is assumed in this Matlab routine and - if necessary - adjust line nums:
    iNeedModified = find( nLineList >= linePfTableAlts );
    if ~isempty( iNeedModified ) 
        [pfTableAlts,nTableLinesActual] = get_pftable_altitude_list( ...
                                                temperInFile, linePfTableAlts);
        nOffset = nTableLinesActual - nTableLinesAssumed;
        % Bug-fix 2016-08-19, allow a -1 offset for files that don't have any PF
        % Table. TEMPER can handle this, but previously the Matlab could not.
        % Still do check for larger negative offsets, however:
        if ( nOffset < -1 )
            error('Code bug detected, PF Table offset adjustment is < -1');
        end
        nLineList(iNeedModified) = nLineList(iNeedModified) + nOffset;
    end
    % Beyond this point in the code, do not use nTableLinesAssumed, use
    % nTableLinesActual!
    clear('nTableLinesAssumed');    

    % As of 2009-11-11, code now loops over multiple parameters.
    % Eventually will replace this loop with something that does not close & 
    % reopen the the file for setting multiple parameters ...
    for iParam = 1:length(param)
        
        thisParam = param{iParam};
        if isSetMode, thisValue = value{iParam}; end
        
        if strcmpi(thisParam,'pfTableAlts')
            if isSetMode
                error('Current code is not yet able to set ''pfTableAlts''');
            else
                value{iParam} = pfTableAlts;
                continue; % <-- skip to top of next for iParam = ... loop
            end
        end
    
        nLine   = nLineList(iParam);
        isNum   = isNumList(iParam);
        comment = commentList{iParam};
        
        switch lower(mode)

            case 'get'
                fid = fopen(temperInFile,'rt');
                if ( fid == -1 )
                    error(['File does not exist: ',temperInFile]); 
                end
                for i = 1:nLine, thisValue = fgetl(fid); end
                fclose(fid);
                if isnumeric(thisValue)
                    % Ad hoc fix for reading older (pre-v3.2.0) input files.
                    % TODO: come up with a better fix that also addresses bugs
                    % that still exist when reading/writing parameters that go
                    % beyond the v3.1.2 (and perhaps also v3.0.0?) ends of the
                    % input file.
                    if ( nLine >= 68 )
                        if isNum
                            thisValue = 'NaN';
                        else
                            thisValue = '';
                        end
                    else
                    % < end ad hoc fix (2015-05-22)
                    % This was the behavior prior to ad hoc fix (error):
                        error(['Unexpected end-of-file reached, format',...
                            ' error likely. Check to see if this file',...
                            ' runs in TEMPER: ',temperInFile]);
                    end
                end               
                if ( isNum )
                    thisValue = sscanf(thisValue,'%f',1); 
                else
                    thisValue = strtrim( thisValue ); % new, 2015-01-29
                end
                value{iParam} = thisValue;

            case 'set'
                if ( isNum ) % added 2009-11-11
                    if ~isnumeric(thisValue) | isnan(thisValue)
                        error('You input a non-numeric value for a numeric parameter');
                    elseif isempty(thisValue)
                        error('You cannot input an empty value for a numeric parameter');
%      ... revisit this ^^^ if 'set','pfTableAlts' is ever allowed (no reason
%          why you shouldn't be able to input an empty value for that parameter)
                    end                        
                end
                newLine = thisValue;
                if strcmpi(thisParam,'osgSeed') % ad hoc bug fix, 2016-08-19
                    newLine = sprintf('%d',newLine);                     
                elseif isnumeric(newLine)
                    newLine = sprintf('%0.8g',newLine); 
                end
                if ~isempty(comment)
                    newLine = sprintf('%-13s %s',newLine,comment); % 2009-10-28
                end 
                if isempty(newLine)
                    newLine = ' '; % bug fix, 2009-11-10
                end 
                Undo = filelrep( [], newLine, nLine, {temperInFile} );
                % ^ only reason for listing output arg is to suppress disp()

        end
        
    end
    
    isGetMode = not(isSetMode);
    if ( isGetMode )
        if not( wasCellInput ) 
            % ... don't output a cell in the old get-single-parameter mode
            if length(value) ~= 1
                error('Code bug detected (non-cell out)!'); 
            end
            varargout{1} = value{1};
        elseif ( nargout <= 1 )
            varargout = {value}; % output all values to single cell output
        elseif ( nargout ~= length(value) )
            error('Please provide 1 output for each input parameter');
        else
            % [param1,param2,param3,...] = getset_temper_input( ..., cell );
            for i = 1:nargout
                varargout{i} = value{i};
            end
        end
    end
        
return





function param = backcompat( param )
% Replaces old input-parameter names with the corresponding new parameter name

    % Old,      New
    repList = {...
    'hMaxCalc', 'hgtMaxCalc';...
    'hInc',     'hgtInc';...
    'rMax',     'rngMax';...
    'rInc',     'rngInc';...
    'hMaxFld',  'hgtMaxFld'};

    repList = lower( repList );
    
    iRep = strmatch( param, repList(:,1), 'exact' );
    if ~isempty(iRep)
        param = repList{iRep,2};
    end
    
return





function [pfTableAlts,nTableLines] = get_pftable_altitude_list( ...
                                        temperInFile, linePfTableAlts)

    % Note about the first line in the pf table (always line #47):
    %   "Line ignored in current version, however [version] 3.0 required that
    %   this line contain 'number of altitudes to place in PF table'"
    %   - TEMPER 3.1.2 User Guide    
    %
    % Also note that, based on 2016-08-19 JZG testing using v3.2.1, blank lines
    % are simply ignored by TEMPER, hence the addition of a separate
    % "nTableLines" output because it's not 100% safe to simply look at the
    % length of pfTableAlts.
    
    fid = fopen( temperInFile, 'rt' );
    
    % Skip to the top of pf table
    for i = 1:linePfTableAlts-1
        fgetl(fid); 
    end
    
    pfTableAlts = [];
    
    % File IO pointer is now positioned at the first line of pf-table-altitudes
    % list. When the '****  Refractivity ...' line is reached, table is over.
    
    nMaxTableEntriesAssumed = 10e3; 
    iLoop  = 1; % <- this value +1'ed every time a numeric value is found
    
    nTableLines = 0;
    
    while (iLoop <= nMaxTableEntriesAssumed)
        
        checkLine = fgetl(fid);
        
        if isnumeric(checkLine)
            fclose(fid);
            error(['Unexpected end-of-file reached, is this really a TEMPER',...
                   ' input file? -> (',temperInFile,')']);
        end
     
        % Increment counter *before* checking for a totally-blank line
        nTableLines = nTableLines + 1;
        
        checkLine = strrep( checkLine, ' ', '' ); % remove blank chars
        if isempty(checkLine)
            continue; % <----- skip this line
        end
        
        % After checking for a blank line and incrementing the line-counter, try
        % to scane a numeric value. Failing to do so is what will trigger
        % "normal" exit. This is also what the TEMPER FORTRAN code does to
        % determine the end of the table, and why that one line of the input
        % file *must* contatin a non-numeric character (usually '*').
        thisAlt = sscanf(checkLine,'%f',1);
        % TODO: is it possible that difference in handling of certain characters
        % between Matlab's SSCANF and FORTRAN's READ could cause problems here?
        if ~isempty(thisAlt)
            pfTableAlts(end+1) = thisAlt;
        else
            nTableLines = nTableLines - 1; % don't count that last one
            fclose(fid);
            return % <------------------------ NORMAL ROUTINE EXIT POINT IS HERE
        end
        
        iLoop = iLoop + 1;
        
    end        

    % Code should never reach this point in a valid TEMPER input file, should
    % have exited at the RETURN statement in loop above...
    fclose(fid);
    msg = sprintf(['This is either not a TEMPER input file or it has more',...
                   ' than %0.0f PF Table altitudes listed\n%s'],...
                  nMaxTableEntriesAssumed, temperInFile );
    error(msg);        
    
return





function fmt = make_print_fmt( inFileInfo, templateFile, varyParams, comments )
% TODO: there are several logic items in this subroutine that are duplicated in
% (and must be manually kept consistent with) logic in the main get/set loop 
% over parameters on lines ~500-600. Probably indicates that whole routine
% should be refactored, eventually. Duplicated items include:
%   - handling of v3.2/v3.1 files and inputs
%   - ad hoc fix for osgSeed (%d format)
%   - "cannot set pfTableAlts" error, and eventually logic to fix this
%   ... this is probalby not a complete list

    switch upper(comments)
        case 'COMMENTS_OFF'
            COMMENT_MODE = 0;
        case 'COMMENTS_SPARSE'
            COMMENT_MODE = 1;
        case 'COMMENTS_ON'
            COMMENT_MODE = 2;
        otherwise
            error('Invalid string input for "comments" argument in struct mode');
    end
    
    if ischar( varyParams )
        varyParams = {varyParams}; % char to cellstr
    end
    
    if ismember( lower('pfTableAlts'), lower(varyParams) )
        error(sprintf('%s\n',...
            'You cannot currently set the pfTableAlts variable.',...
            'Although a future update may add this capability,',...
            'TEMPER users are discouraged from using the PF Table.'));
    end
    
    allParams   = inFileInfo(:,1);
    allLineNums = [inFileInfo{:,2}];
    
    allLineNums = reshape( allLineNums, size(allParams) ); % row->column
    
    % This is not necessary for code to work, but prevents logical mistakes on
    % part of the user -> make sure the order in which they specified the input
    % / variable parameters matches the order that they occur in the file:
    [isOk,indMatch] = ismember( lower(varyParams), lower(allParams) );
    if any( ~isOk )
        temp = varyParams( ~isOk );
        badParams = sprintf('''%s'',',temp{:});
        badParams(end) = []; % get rid of last ','
        error('Input parameter(s) not recognized: %s\nrun >> %s -help',...
            badParams, mfilename );
    elseif length( indMatch ) > 1 && any( indMatch(1:end-1) >= indMatch(2:end) )
        for iDisp = 1:length(varyParams)
            disp(sprintf('Line #%2d = %s',indMatch(iDisp),varyParams{iDisp}));
        end
        error('Please list parameters in the order they occur in the input file');
    end

    % Determine line numbers requred to handle the PF table
    % ... line # of start
    ind = strmatch( lower('pfTableAlts'), lower(allParams), 'exact' );
    pfTableAltLine = allLineNums(ind);
    if length( ind ) ~= 1
        error('Code bug detected - could not find ''pfTableAlts'' line number');
    end
    % - 1 to include the old "# of altitudes" line as part of the "PF Table"
    lineNumPfTableStart = allLineNums(ind) - 1; 
    % ... line # of stop
    ind = strmatch( lower('prtRefSummary'), lower(allParams), 'exact' );
    if length( ind ) ~= 1
        error(['Code bug detected',...
            ' - could not find ''prtRefSummary'' line number']);
    end
    lineNumPfTableStop = allLineNums(ind) - 2;
    if ( lineNumPfTableStop < lineNumPfTableStart ) 
        error(['Code bug detected',...
            '  - ''prtRefSummary'' found before ''pfTableAlts''']);
    end
    temp = setdiff( [lineNumPfTableStart:lineNumPfTableStop], pfTableAltLine );
    if any( ismember( temp, allLineNums ) )
        error('Code bug detected - inFileInfo includes PF Table lines'); 
        % ^ this could get triggered in a future code release
    end
    lineNumIoReset = lineNumPfTableStop + 1;
    if ismember( lineNumIoReset, allLineNums )
        error('Code bug detected - inFileInfo includes I/O reset line #');
    end
    % Due to the hidden "compression level 3" pf threshold value that was read
    % off of line #46 (which normally holds the comment '***** Print File ...')
    % that line also needs to always have some non-numeric character on it:
    lineNumHiddenCL3Thresh = 46;

    % Handle v3.1.2 format files, which stopped at 'createSpf'
    ind = strmatch( lower('createSpf'), lower(allParams), 'exact' );
    if length( ind ) ~= 1
        error('Code bug detected - could not find ''createSpf'' line number');
    end
    true = (1==1);
    false = not(true);
    isV320 = repmat( false, size(allParams) );
    isV320(ind+1:end) = true;
    
    % Get all values out of template file for v3.1.2 parameters
    templateValues = getset_temper_input( templateFile, 'get', allParams(~isV320) );
    % ... make sure it's a column vector, Matlab sometimes messes this up in
    % certain versions and not others, so always good to reshape
    templateValues = reshape( templateValues, length(templateValues), 1 );
    
    % Now try to get the v3.2.0 parameters
    v320Params = allParams(isV320);
    try
        v320Values = getset_temper_input( templateFile, 'get', v320Params );
        v320Values = reshape( v320Values, length(v320Values), 1 );
        templateValues = [templateValues; v320Values];
    catch
        isInvalidRequest = ismember( lower(varyParams), lower(v320Params) );
        if any( isInvalidRequest )
            temp = varyParams(isInvalidRequest);
            badParams = sprintf('''%s'',',temp{:});
            badParams(end) = []; % get rid of last ','
            error(['You specified v3.2.0 TEMPER parameters (',badParams,...
                ') but your template file is a v3.1.2 file.\nPlease',...
                ' add v3.2.0 lines to this .in file and try again:',...
                ' \n>> edit(''%s'')'],...
                templateFile);
        end
        % Otherwise proceed, but remove the v3.2.0 values from arrays:
        allParams(isV320)    = [];
        allLineNums(isV320)  = [];     
        inFileInfo(isV320,:) = [];
    end
        
    % Set new-line character (or characters, can have length > 1 and code will
    % still work). The \n escape code should adapt by OS (PC, Mac, Linux).
    NLC = sprintf('\n');

    % Initialize output, it will be progressively built up in loop, below
    fmt = '';
    
    nMaxLine = max(allLineNums);
    
    for thisLine = 1:nMaxLine
        
        infoIndex = find( thisLine == allLineNums );
        if length( infoIndex ) > 1
            error('Code bug detected in inFileInfo col #2 - duplicate line #');
        end
        
        if isempty(infoIndex)
            
            if ( thisLine >= lineNumPfTableStart ) & ...
               ( thisLine <= lineNumPfTableStop  )
                
                fmt = [fmt,'1']; % dummy value
                
            elseif ( COMMENT_MODE == 1 ) | ... % <- do not use short circuit ||
             ( ( COMMENT_MODE == 0 ) & ( thisLine == lineNumIoReset ) ) | ...
             ( ( COMMENT_MODE == 0 ) & ( thisLine == lineNumHiddenCL3Thresh ) )
             
                fmt = [fmt,'*']; 
                % Can be any non-numeric character, conventional is 
                % '***** Refractivity ****' but '*' is good enough. 
                % This is what TEMPER FORTRAN code uses to reset it's knowledge
                % of I/O position in the file w.r.t. input parameters after
                % parsing the variable-length "PF Table Altitudes" section.
                    
            elseif ( COMMENT_MODE == 2 )
                
                fmt = [fmt,'*********************************************']; 
                
            elseif ( COMMENT_MODE ~= 0 )
                
                error(['Code bug detected',...
                    ' - invalid setting for COMMENT_MODE variable']);
            else
                fmt = [fmt,' ']; % Needed for Linux/Mac Compatability
            end % if COMMENT_MODE == 0, do nothing here, new-line is added below
                        
        else

            thisParam = allParams{infoIndex};
            thisIsNum = inFileInfo{infoIndex,3};
            
            % TODO: for now, this hack which fixed bug for very large OSG seed
            % values on 2016-08-16 is sufficient. If code is ever refactored
            % (e.g., to remove dependence on filelrep.m), consider a better
            % solution here:
            thisIsSeed = thisIsNum && strcmpi(thisParam,'osgSeed');

            if ismember( lower(thisParam), lower(varyParams) )

                if thisIsSeed % <- TODO: this is a hack (must come 1st)
                    fmt = [fmt,'%d'];
                elseif thisIsNum
                    fmt = [fmt,'%g'];
                else
                    fmt = [fmt,'%s'];
                end

            else

                if thisIsSeed % <- TODO: this is a hack (must come 1st)
                    fmt = [fmt,sprintf('%d',templateValues{infoIndex})]; 
                elseif thisIsNum
                    fmt = [fmt,sprintf('%g',templateValues{infoIndex})];                
                else
                    str = printf_escapes( templateValues{infoIndex} );
                    fmt = [fmt,str];
                end

            end
            
            commentStr = inFileInfo{infoIndex,4};
            commentStr = strtrim( commentStr );
            if ( COMMENT_MODE == 2 ) & ~isempty( commentStr )
                str = printf_escapes( inFileInfo{infoIndex,4} );
                fmt = [fmt,sprintf('      '),str]; 
                %                    ^^^ use spaces for value-comment spacing
                % IMPORTANT NOTE! -> original code used a tab [sprintf('\t')]
                % method for all lines included comment-only lines. However,
                % when done this way the tab character inserted after the file
                % name inputs (e.g., .ref file) caused problems. Avoiding tabs
                % entirely after that.
            end
        
        end
        
        fmt = [fmt,NLC]; % add new-line character(s)
        
    end

return

function str = printf_escapes( str )
% Replaces any characters that would be interpreted by fprintf w/ escapes
    str = strrep( str, '\', '\\' );
    str = strrep( str, '%', '%%' );
% TODO: anything else I'm missing here? ^^^
return





function display_help( inFileInfo )

    fid = 1; % print to screen
    
    disp(' ');
    disp(['----- THESE ARE THE INPUT PARAMETERS FOR ',upper(mfilename),'.M -----']);
    disp(' ');

    maxParamNameLen = size( char(inFileInfo{:,1}), 2 );
    nFmt = sprintf('%%-%ds', maxParamNameLen + 2 ); % + 2 for quotes on either side of name
    
    fprintf( fid, ['%4s ',nFmt,' %-4s %-s\n'], 'line', 'parameter', 'type', 'comment' );
    fprintf( fid, ['%4s ',nFmt,' %-4s %-s\n'], '----', '---------', '----', '-------' );
    
    type = {'char','num'};
    for i = 1:size(inFileInfo,1)
        thisParam = ['''',inFileInfo{i,1},''''];
        oneOrTwo = double(inFileInfo{i,3})+1;
        thisType = type{ oneOrTwo };
        thisComment = inFileInfo{i,4};
        if isempty( thisComment ), thisComment = '(no comment)'; end
        fprintf( fid, ['%4d ',nFmt,' %-4s %-s\n'], ...
            inFileInfo{i,2}, thisParam, thisType, thisComment ); 
    end
    
    disp(' ');

return





%function run_test
%
%
%    %% Setup - get info from main routine and generate temporary .in file
%
%    % Get info from table in main routine using no-input mode w/ outputs:
%    [params,isNumeric,lineNums] = getset_temper_input;
%    
%    % Find pfTableAlts and remove it.
%    % Reading/getting table will be tested separately.
%    % Writing/setting table is not yet supported (TODO: test, if/when added)
%    iPfTableAlts = strmatch( 'pfTableAlts', params, 'exact' );
%    if length(iPfTableAlts) ~= 1
%        error('Problem in main routine or tester code at "Find pfTableAlts"');
%    end
%    pfTableAltsLineNum      = lineNums(iPfTableAlts);
%    params(iPfTableAlts)    = [];
%    isNumeric(iPfTableAlts) = [];
%    lineNums(iPfTableAlts)  = [];
%    clear('iPfTableAlts');    
%    
%    % Create test file, fill it with junk lines to length of a normal .in file
%    testFile = fullfile( tempdir, [mfilename,'.in'] );
%    fid = fopen( testFile, 'wt' );
%    if ( fid == -1 )
%        error(sprintf('%s\n',...
%          'Cannot run unit test, temp folder is not writable:',...
%          testFile,...
%         ['This does not necessarily indicate problems in ',mfilename,'.m,'],...
%          'only that the unit tests cannot be run at this time.'));
%    end
%    lastLine = max(lineNums);
%    for n = 1:lastLine
%        fprintf( fid, '***********\n' );
%    end
%    fclose( fid );
%    
%    
%    %% Start testing
%    
%    % Now that we know we can write to disk, issue the "starting test" message
%    disp(['Starting self-test of ',mfilename,'.m. This may take 10+ sec ...']);
%    disp('... Any errors that occur indicate a bug in the code');
%    
%    tic;
%    
%    
%    %% TEST USE: getset_temper_input( testFile, 'set', param, value );
%    % Set all values in a loop - this tests single-param 'set' mode and also
%    % established expected "before" values for checking later tests.
%    paramNum = reshape( [1:length(params)], size(params) );
%    for i = 1:length(params)
%        before{i} = paramNum(i);
%        if ~isNumeric(i)
%            before{i} = num2str(before{i}); 
%        end
%        getset_temper_input( testFile, 'set', params{i}, before{i} );
%    end
%    
%    
%    %% TEST USE: value = getset_temper_input( testFile, 'get', param );
%    % ... where "param" is a single string
%    for i = 1:length(params)
%        afterGet1By1{i} = getset_temper_input( testFile, 'get',params{i} );
%    end
%    % ... and where "param" is a cellstr (multi-param mode)
%    afterGetMulti = getset_temper_input( testFile, 'get', params );
%    
%    
%    %% TEST USE: getset_temper_input( testFile, 'set', Struct ); 
%    temp(1:2:length(params)*2)   = params;
%    temp(2:2:length(params)*2+1) = before;
%    BeforeStruct = struct(temp{:});
%    getset_temper_input( testFile, 'set', BeforeStruct ); 
%    afterSetStruct = getset_temper_input( testFile, 'get', params );
%    
%    
%    %% TEST USE: Input = getset_temper_input( testFile, 'struct' );
%   AfterStruct = getset_temper_input( testFile, 'struct' );
%   % Ad hoc mod:
%   AfterStruct = rmfield( AfterStruct, 'pfTableAlts' );
%    
%    
%    %% TODO: [value1,value2,value3,...] = getset_temper_input( ... );
%    % (not currently tested, but probably not frequently used)
%    
%    
%    %% TEST USE: fmt = getset_temper_input( testFile, 'fprintf', varyParams, ...
%    %                                                               comments );
%    %       comments == 'COMMENTS_OFF'    % No comments
%    %       comments == 'COMMENTS_SPARSE' % Only '*' between sections <- default
%    %       comments == 'COMMENTS_ON'     % All comments
%    comments = {'COMMENTS_OFF','COMMENTS_SPARSE','COMMENTS_ON'};
%    for iCMode = 1:3
%    for iParam = 1:length(params)
%        i1 = iParam;
%        i2 = length(params) - iParam + 1;
%        if ( i2 <= i1 ), break; end
%        fmt = getset_temper_input( testFile, 'fprintf', params([i1,i2]), ...
%                                   comments{iCMode} );
%        fid =  fopen( testFile, 'wt' );
%        fprintf( fid, fmt, before{i1}, before{i2} );
%        fclose( fid );
%        afterFPrintf = getset_temper_input( testFile, 'get', params );
%        isFmtBug(iParam,iCMode) = ~is_equal( before, afterFPrintf );
%    end
%    end
%    isFprintfBug = any( [isFmtBug(:)] );
%    
%    
%    %% TEST PF-TABLE HANDLING & V3.2-SET-from-V3.1-file HANDLING
%    
%    % Read data out of file into cellstr "txt". It will be used for both tests.
%    fid = fopen( testFile, 'rt' );
%    txt = {};
%    while 1
%        x = fgetl(fid); 
%        if ~isnumeric(x), txt{end+1} = x; else, break; end
%    end
%    fclose(fid);
%    
%    % Test PF-Altitude Table handling
%    for addExtraBlanks = [0,1]
%        tbl = {'100','200','300'};
%        if addExtraBlanks
%            % TEMPER effectively ignores any all-blank lines here. Matlab code
%            % did not behave the same way until 2016-08-19 bug fixes. Test that
%            % it is really fixed here:
%            tbl = [{'',' ','   '}, tbl];
%        end
%        newTxt = [txt(1:pfTableAltsLineNum), tbl,...
%                  txt(pfTableAltsLineNum+1:end)];
%        fid = fopen( testFile, 'wt' );
%        fprintf(fid,'%s\n',newTxt{:});
%        fclose(fid);
%        % Try reading out the values from the modified file
%        afterPfTableMod{addExtraBlanks+1} = ...
%            getset_temper_input( testFile, 'get', params );
%        checkTblVals = getset_temper_input( testFile, 'get', 'pfTableAlts' );
%        if ~is_equal( checkTblVals, [100,200,300], 'ignoreTranspose',1 )
%            error(['Failed on ''get'' pfTableAlts test #',...
%                    int2str(addExtraBlanks+1)]);
%        end
%    end
%    
%    % Test v3.2-inputs to v3.1-file handling
%    
%    
%    %% CHECK EMPTY VALUES
%    % Caught an error in Nov 2009 that screwed up the input file when an empty
%    % value was input for a char-type parameter. Test that this is now fixed by
%    % setting all char-type params to empty then re-reading values from file.
%    beforeEmptyChars = before;
%    iChars = find( ~isNumeric );
%    iChars = reshape( iChars, 1, length(iChars) );
%    for i = iChars
%        getset_temper_input( testFile, 'set',params{i}, '' );
%        beforeEmptyChars(i) = {''};
%    end
%    afterEmptyChars = getset_temper_input( testFile, 'get', params );
%    
%    
%    %% Extra test on OSG seed, due to bug fixed 2016-08-19
%    % Test for fprintf clipping of integer value (e.g., if written as %g)
%    bigSeed  = int32( 2^31 - 1);
%    readSeed = int32( [0,0] );
%    % First test normal/non-fprintf mode
%    getset_temper_input( testFile, 'set', 'osgSeed', bigSeed );
%    readSeed(1) = getset_temper_input( testFile, 'get', 'osgSeed' );
%    fmt = getset_temper_input( testFile, 'fprintf', 'osgSeed' );
%    fid = fopen( testFile, 'wt' );
%    fprintf( fid, fmt, bigSeed );
%    fclose(fid);
%	readSeed(2) = getset_temper_input( testFile, 'get', 'osgSeed' );
%
%    
%    %% Testing is done, issue error message or fall through to "passed!" disp()
%    
%    disp(sprintf('... testing took %0.1f seconds',toc));
%       
%    isBasicBug     = ~is_equal( before, afterGet1By1 );
%    isMultiBug     = ~is_equal( before, afterGetMulti );
%    isStructSetBug = ~is_equal( before, afterSetStruct );
%    isStructGetBug = ~is_equal( BeforeStruct, AfterStruct );
%    isPfTabBug     = ~is_equal( before, afterPfTableMod{1} ) & ...
%                     ~is_equal( before, afterPfTableMod{2} );
%    isEmptyBug     = ~is_equal( beforeEmptyChars, beforeEmptyChars );
%    isBadSeed      = any( bigSeed ~= readSeed );
%    
%    if isBasicBug
%        error('Code bug! Values changed after simple get/set operation');
%    elseif isMultiBug
%        error('Code bug! Values changed after cell-I/O get/set operation');
%    elseif isStructSetBug
%        error('Code bug! Values changed after set-by-Struct mode');      
%    elseif isStructGetBug
%        error('Code bug! Values changed after get-Struct mode');
%    elseif isFprintfBug
%        error('Code bug! The fprintf fmt output and/or handling is flawed');
%    elseif isPfTabBug
%        error('Code bug! PF table list length adapting code is flawed');
%    elseif isEmptyBug
%        error('Code bug! Get/setting of empty strings appears to be flawed');
%    elseif isBadSeed
%        error('Code bug! Large integers for osgSeed are not handled');
%    end        
%    
%    disp(['... ',mfilename,'.m passed all tests!']);
%    
%    
%return
