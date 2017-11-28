function [out] = convert_engine( ...
    conversionBasis, callerFun, mode, inUnit, outUnit )
%convert_engine - General unit-conversion engine; requires wrapper routines.
%
%   An "engine" routine that can drive ANY linear, non-offset unit conversion
%   (i.e., of the form y = M*x).  Once an appropriate wrapper routine has been
%   written, this engine performs all of the following functions for the
%   wrapper routine:
%       - generates conversion factors between any two defined units
%       - automatically tests for accuracy whenever wrapper routine changes
%       - interprets any number of alternate names/strings for a given unit
%       - outputs a list of valid unit strings for use in, e.g., LISTDLG.M
%
%   Furthermore, the way this engine requires units to be defined is optimal
%   for "y=M*x" conversions in that:
%       - no add'l error introduced (i.e., beyond errs in defined constants)
%       - cyclic conversion errors are eliminated (e.g. m->ft->m = 1.0)
%
%
% USE: convert_engine( conversionBasis, callerFun, mode );
%
%   conversionBasis - (3-column cell) First row holds name of the "refenence"
%       unit.  Remaining rows define additional units, with conversion factors
%       in relation to the "reference" unit(***).  Columns are as follows:
%       {i,1} -> (string) Primary name of the ith unit, all lowercase.
%       {i,2} -> (number) Multiplicative conversion factor that takes the ith
%       unit to the "reference" unit.  Note that element {1,2} must be 1.0.
%       {i,3} -> (cellstr) List of alternate names for the ith unit (plural
%       forms, alternate spellings, abbreviations, etc).  All names must be
%       lowercase and unique.
%
%   callerFun - (string) The full name of the file that's calling
%       convert_engine().  Typically, this will be another Matlab function, in
%       which case you can simply use "callerFun = which(mfilename);".  When
%       calling from a Matlab script, however, you'll have to provide the full
%       path and name of your script as the callerFun input.  MAC/UNIX NOTE:
%       this routine will not recognize case differences between file names!
%
%   mode - (string) Case-insensitive input that determines the mode of
%       operation for a given call to convert_engine().  The three mode
%       options, 'test', 'list' & 'factor', are described below.
%
% (***) In general, try to select a "reference" unit to which *exact*
%   conversion factors are defined.  For example, most length units have an
%   exact conversion to meters by definition, hence meters makes the most
%   logical reference unit for length conversions.
%
%
% USE: convert_engine( ..., ..., 'test' );
%
%   First three inputs as described above, mode = 'test'.  This forces the
%   routine to run a basis test (normally, a test only occurs if the callerFun
%   file has changed).  As with normal test operation, a test failure generates
%   a Matlab error, so make sure you call this routine within a TRY CATCH if
%   you don't want execution to halt.
%
%
% USE: [unitList] = convert_engine( ..., ..., 'list', opt );
%
%   First three inputs as described above, mode = 'list'.  In this mode, the
%   routine generates a list of unit strings available in the given basis.
%   Optional fourth input can be opt = 'primary' to return primary string, or
%   opt = 'abbrev' to return the shortest string per unit.
%
%
% USE: [factor] = convert_engine( ..., ..., 'factor', inUnit, outUnit );
%
%   First three inputs as described above, mode = 'factor'.  In this mode, the
%   routine generates a multiplicative conversion factor that takes a quantity
%   from "inUnit" to "outUnit".
%
%
% ©2006, JHU/APL (A2A)
% Written by: jonthan.gehman@jhuapl.edu
% Last update: 2011-03-29


% Update list:
%~~~~~~~~~~~~~~
% 2006-02-06 (?) Last untracked update
% 2008-06-30 Fixed minor bug (transposed char array for "units" caused crash)
% 2011-03-29 Undid autotest at request of TRH; need to add a better unit test


    out = []; % initialize

    if ( nargin < 3 ), error('3 inputs required'); end

    mode = lower( mode ); % case insensitive
    
    if strcmpi( callerFun, '-test' )
        % In test-mode this routine calls itself once recursively; a
        % "callerFun" of '-test' flags these special recursive calls and
        % prevents the routine from entering additional layers of recursion.
        doAutoTest = 0;
    else
        % ... otherwise, test basis whenever the calling routine has been
        % updated since
        doAutoTest = 0; % is_autotest_needed( callerFun ); <- turned this off 2011-03-29 as temporary measure; TBD add a better unit test functionality!
    end
    if ( doAutoTest ), test_basis( conversionBasis, callerFun ); end
    
    switch ( mode )
        
        case '-test'
            if ( doAutoTest ), return; end % don't test twice!
            test_basis( conversionBasis, callerFun );
            
        case 'list'
            if ( nargin < 4 ), opt = 'primary';
            else,              opt = inUnit;
            end
            switch lower(opt)
                case 'primary'
                    out = conversionBasis(:,1);
                case 'abbrev'
                    out = get_shortest_string( conversionBasis );
                otherwise
                    error('Bad option string for ''list'' mode');
            end
            
        case 'factor'
            if ( nargin < 5 ), error('5 inputs required in ''factor'' mode'); end
            iFrom = id_unitstr( inUnit, conversionBasis );
            iTo   = id_unitstr( outUnit,   conversionBasis );
            x2ref = conversionBasis{iFrom,2};
            y2ref = conversionBasis{ iTo, 2};
            out = x2ref / y2ref; % = x2y
            
        otherwise
            error('Unrecognized string for 3rd input (mode)');
            
    end

return





function iMatch = id_unitstr( str, conversionBasis )
    if ~ischar(str), error('Non-string input for unit string'); end
    % Make case-insensitive ("conversionBasis" is all lowercase)
    str = lower(str);
    % Handle transposed char arrays (bug fix 2008-06-30)
    str = reshape(str,1,length(str));
    % Try a fast character-array-based match first ...
    iMatch = strmatch( str, conversionBasis(:,1), 'exact' );
    if ~isempty( iMatch ), return; end
    % If no match to primary unit names, try alternames:
    for i = 1:size(conversionBasis,1)
        if ~isempty( strmatch(str,conversionBasis{i,3},'exact') )
            iMatch = i;
            return
        end
    end
    % If no match after either attempts, something's wrong
    error(['String ''',str,''' is not a recognized unit string']);
return





function test_basis( conversionBasis, callerFun )

    disp([mfilename,' is testing the unit-conversion basis...']);

	% make sure it's a cell array of correct size:
	if ~iscell( conversionBasis ) | ( size(conversionBasis,2) ~= 3 )
        error('Basis must be a 3-column cell array');
    end
    
    nRows = size(conversionBasis,1);
    
    % require at least 3 units - otherwise, what's the point?
    if ( nRows < 3 )
        error('You must define at least 3 units in your conversion basis');
    end
    
    % make sure the contents of each column are correct
    for i = 1:nRows
        if ~ischar(conversionBasis{i,1}) | isempty(conversionBasis{i,1})
            error('1st column of basis must hold non-empty strings');
        elseif ~isnumeric(conversionBasis{i,2}) | ( length(conversionBasis{i,2}) ~= 1 )
            error('2nd column of basis must hold conversion factors');
        elseif ~iscellstr(conversionBasis{i,3}) & ~isempty(conversionBasis{i,3})
            error('3rd column of basis should either be a cellstr or empty');
        end
    end
    
    % make sure the first row holds the "reference" unit
    if ( conversionBasis{1,2} ~= 1 )
        error('1st row of basis must hold the "reference" unit (factor = 1.0)');
    end
    
    % make sure all the unit strings are unique & lowercase
    allStrs = conversionBasis(:,1);
    for i = 1:nRows
        n = length(conversionBasis{i,3});
        allStrs(end+1:end+n) = conversionBasis{i,3};
    end
    if length(allStrs) ~= length(unique(allStrs))
        error('Not all basis unit strings are unique');
    end
    for i = 1:length(allStrs)
        if any( allStrs{i} ~= lower(allStrs{i}) )
            error('Basis strings must be all lowercase');
        end
    end
    
    % make sure the factors are unique (i.e. no redundant rows)
    factors = [conversionBasis{:,2}];
    if ( length(factors) ~= length(unique(factors)) )
        error(['One or more factors are redundant - i.e. same unit defined',...
               ' with different names on different rows']);
    end
    
    % make sure the factors are all finite & non-zero
    if any( factors == 0 )
        error('Factors cannot be zero');
    elseif any( ~isfinite(factors) )
        error('Factors cannot be NaN, -Inf or Inf');
    end
    
    % test 'list' mode (NOTE: "unitList" will be used in subsequent tests)
    try
        unitList = convert_engine( conversionBasis, '-test', 'list' );
    catch
        error(['''list'' mode failed (',lasterr,')']);
    end
    
    % no way to check the factors defined "callerFun" automatically, so simply
    % display to user and hope they pay attention...
    disp('Please check the following values for accuracy, and fix file')
    disp(['"',callerFun,'" if any errors are discovered!']);
    for i = 2:length(unitList)
        thisFactor = convert_engine( conversionBasis, '-test', 'factor',...
                                     unitList{i}, unitList{1} );
        disp( sprintf(' -> 1.0 %-15s = %20g %s',unitList{i},thisFactor,unitList{1}) );
    end

    disp([mfilename,' test finished']);

return





function shortest = get_shortest_string( conversionBasis )

    shortest = repmat( {''}, [size(conversionBasis,1),1] );

    for i = 1:size(conversionBasis,1)
        
        thisList = [ conversionBasis(i,1), conversionBasis{i,3} ];
        
        jShort   = 1;
        shortLen = length( thisList{1} );
        for j = 2:length(thisList)
            if ( length(thisList{j}) < shortLen )
                shortLen = length(thisList{j});
                jShort   = j;
            end
        end
        
        shortest{i} = thisList{ jShort };
        
    end        

return





function doAutoTest = is_autotest_needed( callerFun )

    true = (1==1);
    false = not(true);

    prefGroup = 'convert_engine_test_dates';
    prefName  = str2varname( lower(callerFun) );
    
    doTestIfNoPrefs = false; % for legacy Matlab versions that don't have GETPREF
    
    try
        isTested = ispref(prefGroup,prefName);
    catch
        % An error on ISPREF can only mean that user is running an old version
        % of Matlab, or something is screwed up with Matlab's prefs.
        doAutoTest = doTestIfNoPrefs;
        return
    end
    
    % At this point, no reason why the pref functionality shouldn't work, so
    % generate errors if something breaks...
    
    if ( isTested )
        testDate = getpref(prefGroup,prefName);
        N = dir(callerFun);
        if isempty(N)
            warning(['Cannot find file "',callerFun,'" - unit conversion tests may be running unnecessarily!']);
            doAutoTest = true;
        elseif length(N) ~= 1
            warning(['File "',callerFun,'" may not be correct, or have full path - unit conversion tests may be running unnecessarily!']);
            doAutoTest = true;
        else
            fileDate = datenum( N(1).date );
            doAutoTest = ( fileDate > testDate );
        end
    else
        doAutoTest = true;
    end
    
    if ( doAutoTest )
        setpref(prefGroup,prefName,now);
    end
    
return