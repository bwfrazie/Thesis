function [rngUnits,hgtUnits] = unitflag2str( iUnits )
%unitflag2str - Returns units strings based on TEMPER integer units flag.
% 
%
% USE: [rngUnits,hgtUnits] = unitflag2str( iUnits )
%
%   iUnits - TEMPER units flag:
%       0 = nmi/ft
%       1 = km/m
%   rngUnits - Either 'nmi' or 'km'.
%   hgtUnits - Either 'ft' or 'm'.
%
%   Input can either be a single value, or an array of values.  Array input
%   produces cellstr output.  Otherwise, output are strings, not cells.
%
%
% USE: [...] = unitflag2str( S )
%
%   Input can be any TEMPER-related struct. This routine will attempt to find
%   the right struct field to get the units flag.
%
%
% USE: unitflag2str test
%
%   Runs internal test on code.
%
% SEE ALSO: str2unitflag.m, tdata31.m, read_spf.m
%
% Last update: 2016-08-20

% TODO: use this routine to replace hardcoded logic in several other functions!

% Update list: (all JZG unless noted)
% -----------
% 2007-01-18 - (Kevin Norman) Wrote initial unit test.
% 2007-01-22 - Added to unit test.
% 2016-08-20 - Added capability to input structures (e.g., from tdata31).

    
    if ( nargin == 1 ) & strcmpi( iUnits, '-test' )
        run_test;
        return;
    end
    
    if ( nargin ~= 1 )
        error('Incorrect # of input arguments');
    end
    
    if isstruct( iUnits )
        iUnits = find_units_field( iUnits );
    end
    
    rngUnitList = {'nmi','km'};
    hgtUnitList = {'ft','m'};
    
    if any( iUnits ~= 0 & iUnits ~= 1 )
        error('TEMPER units flags must be either 0 or 1');
    end
    
    iOut = iUnits + 1;
    
    if length(iOut) == 1;
        rngUnits = rngUnitList{iOut}; % string output
        hgtUnits = hgtUnitList{iOut}; % string output
    else
        rngUnits = rngUnitList(iOut); % cell output
        hgtUnits = hgtUnitList(iOut); % cell output
    end
    
return





function iUnits = find_units_field( S )

    nFound = 0;
    
    if isfield( S, 'head' ) && isstruct( S.head ) && isfield( S.head, 'units' )
        iUnits = S.head.units;
        nFound = nFound + 1;
    end
    
    if isfield( S, 'units' )
        iUnits = S.units;
        nFound = nFound + 1;
    end
    
    if ( nFound == 0 )
        error(['Could not automatically find the units field of input',...
            ' struct, please input that flag directly instead of the struct.']);
    elseif ( nFound > 1 )
        error(['Multiple possibilities for units field found in the input',...
            ' struct, please input that flag directly instead of the struct.']);
    end        

return





%function run_test
%
%    disp('Running unit tests on unitflag2str.m & str2unitflag.m ...');
%    disp('... any error indicates a problem in 1 or both of those functions.');
%
%    try
%        unitflag2str(2);
%        wasError = 0;
%    catch
%        wasError = 1;
%    end
%    if ~( wasError )
%        error('unitflag2str did not throw an error for invalid input');
%    end
%      
%    [nmiStr,ftStr] = unitflag2str(0);
%    [kmStr, mStr ] = unitflag2str(1);
%    if ~strcmpi(nmiStr,'nmi') | ~strcmpi(ftStr,'ft')
%        error('unitflag2str fails to return ''nmi'' & ''ft'' for 0 input');
%    elseif ~strcmpi(kmStr,'km') | ~strcmpi(mStr,'m')
%        error('unitflag2str fails to return ''km'' & ''m'' for 1 input');
%    end
%    
%    check0(1) = str2unitflag('nmi');
%    check0(2) = str2unitflag('ft');
%    check0(3) = str2unitflag('nmi','ft');
%    check0(4) = str2unitflag('ft','nmi');
%    if any( check0 ~= 0 )
%        error([mfilename,' fails to return 0 for all valid input combos']);
%    end
%    
%    check1(1) = str2unitflag('km');
%    check1(2) = str2unitflag('m');
%    check1(3) = str2unitflag('km','m');
%    check1(4) = str2unitflag('m','km');
%    if any( check1 ~= 1 )
%        error('str2unitflag fails to return 1 for all valid input combos');
%    end
%    
%    Head.units = 1;
%    Data.head.units = 1;
%    checkStruct(1) = str2unitflag( unitflag2str( Head ) );
%    checkStruct(2) = str2unitflag( unitflag2str( Data ) );
%    if any( checkStruct ~= 1 )
%        error('unitflag2str fails on struct test');
%    end    
%    
%    disp('... unitflag2str.m & str2unitflag.m passed all internal tests');
%    
%return