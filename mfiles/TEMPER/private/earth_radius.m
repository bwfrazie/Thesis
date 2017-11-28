function ae = earth_radius(units,aeType)
%earth_radius - Returns various measures of earth's radius of curvature (ROC).
%
%   NOTE: this function does *not* provide local ROCs for an arbitrary lat, lon
%   & bearing on the ellipse - see ellipse_local_radius.m instead.
%
% USE: ae = earth_radius(units,[aeType])
%
%   Returns earth radius in "units" (which can be any units string accepted by
%   convert.m).  Optional "aeType" input is one of the following:
%       'sphere'   - 6371 km (roughly the "average" WGS-84 ellipsoid value).
%       'min'      - Minimum local radius of curvature for WGS-84 ellipsoid
%                    (corresponds to facing due N or due S at equator).
%       'max'      - Maximum local "" "" (corresponds to any direction at the
%                    N or S pole).
%       'TEMPER'   - Value used in TEMPER.
%       'RAYCAP'   - Value used in Ray Wasky's RAYCAP ray-tracer.
%
%   NOTE: prior to 2004-10-27, this routine always returned the 'TEMPER' value.
%   Now, however, this routine returns the 'standard' value by default.  Keep
%   this change (an increase of ~0.18% in output radius) in mind when comparing
%   to old results!
%
% Last update: 2014-04-23


% Update list: (all JZG unless noted)
% -----------
% 2004-10-27 - Added WGS84 min/max options, revamped code.
% 2007-01-18 (Kevin Norman) Wrote tester routine
% 2007-01-21 - Added to tester routine, removed 'default', added aeTypeList
% 2008-05-12 - Added raycap value.
% 2014-04-23 - No functional changes. Updated internal comments about TEMPER &
% APM values. Added note of "new" (added in 2008) RAYCAP value option in help.


% Validation log:
% --------------
% See comments in code + run unit test


    % Coding note: make sure this list of strings is 1) all lowercase & 2)
    % eactly matches the strings used in SWITCH cases below.
    aeTypeList = {'standard','min','max','temper','raycap'};

    if ( nargin == 0 )
        % Special mode -> return all possible
        ae = aeTypeList;
        return;
    end
    
    if ( nargin == 1 ) & strcmpi( units, '-test' )
        run_test;
        return;
    end

    if ( nargin < 2 ), aeType = 'standard'; end

    aeType = lower( aeType );
    
    if strcmp( aeType, 'default' ) | strcmp( aeType, 'sphere' )
        % For backward compatibility, handle string that had been used for the
        % 'standard' type in past versions ('default') as well as 'sphere', to
        % avoid confusion.
        aeType = 'standard';
    end
    
    if ~ismember( aeType, aeTypeList )
        error(['''',aeType,''' is not a recognized aeType.',sprintf('\n'),...
               'Run ',mfilename,' with no inputs to generate a list of valid aeType strings.']);
    end
   
    switch lower(aeType)
        
        case {'standard'}
            % Note that all of the following fall between 6371.000 and 6371.010
            % km for the WGS 84 ellipsoid: mean radius of semiaxes (R1), radius
            % of sphere with equal area (R2), & radius of sphere with equal
            % volume (R3).
            ae = 6371;
            aeUnits = 'km';
            % Comments in the TEMPER code, from TEMPER/APM comparisons (OAML
            % effort, ~2000-2001?), indicate that APM used 6371 for its assumed
            % earth radius.
            
        case 'min'
            % Value computed by "ellipse_local_radius" using WGS-84 parameters
            % (a = 6378137.0 meters, e = 0.08181919092891) on 2004-10-27.
            ae = 6335439.3272;
            aeUnits = 'm';
            
        case 'max'
            % Value computed by "ellipse_local_radius" using WGS-84 parameters
            % (a = 6378137.0 meters, e = 0.08181919092891) on 2004-10-27.
            ae = 6399593.6258;
            aeUnits = 'm';
            
        case 'temper'
            ae = 2.08649e7;
            aeUnits = 'ft';
            % Confirmed that code (as of 3.1.2 & 3.2 / Apr 2014) uses this same
            % value for converting M & N units. Also note that this value is
            % close to the North-South local r.o.c. at the Wallops region:
            %
            %   ellipse_local_radius; % generates a plot
            %   hline( convert_length(2.08649e7,'ft','km'), 'k' );
            %   vline( 38, 'k' ); % Wallops lattitude = 37.85 ~ 38 deg
            %
            % Overall this value is a little low relative to other local r.o.c.
            % values around the globe (ellipse).
            
        case 'raycap'
            ae = 6.378135E+06;
            aeUnits = 'm';
            
        otherwise
            error('Internal code bug detected: one or more SWITCH case strings do not match "aeTypeList"');
            
    end

	ae = convert_length( ae, aeUnits, units );

return





%function run_test
%
%    % Check the string-output mode of earth_radius.m:
%    aeTypeList = earth_radius;
%    if ~iscellstr( aeTypeList )
%        error('Does not return a list of aeType strings when no input arguments');
%    end
%    
%    standardAeKm = 6371;
%    
%    % Check that the default mode is working correctly
%    aeKm  = earth_radius('km');
%    aeKm2 = earth_radius('km','standard');
%    if ( aeKm ~= aeKm2 ), error('Unexpected default value returned'); end
%    
%    % Check accuracy of standard value
%    if ( aeKm ~= standardAeKm ), error('Error in standard value (typo in code?)');end
%    
%    % Check accuracy of other values
%    nonStdErrTol = 1.0/100; % non-standard values (WGS84 min/max, TEMPER value,
%                            % etc) should all be w/in 1.0% of standard value.
%    for i = 1:length( aeTypeList )
%        thisValue = earth_radius('km',aeTypeList{i});
%        if ~is_equal( standardAeKm, thisValue, 'tolerance',nonStdErrTol )
%            error(['''',aeTypeList{i},''' value is inaccurate (typo in code?)']);
%        end
%    end            
%    
%    % This isn't really testing earth_radius.m - actually testing convert.m
%    % (just to be safe).  Note that convert.m should provide exact values for
%    % these unit conversions, however use IS_EQUAL w/ a tiny tolerance just in
%    % case round-off errors come into play:
%    aeM   = earth_radius('m');
%    aeFt  = earth_radius('ft');
%    aeNmi = earth_radius('nmi');
%    unitConvertTol = eps/1000; % relative tolerance
%    if ~is_equal( aeM/aeKm, 1000, 'tolerance',unitConvertTol )
%        error('Unit check failed; possible convert.m error for km and/or m?');
%    elseif ~is_equal( aeM/aeFt, 0.3048, 'tolerance',unitConvertTol )
%        error('Unit check failed; possible convert.m error for ft and/or m?');
%    elseif ~is_equal( aeM/aeNmi, 1852, 'tolerance',unitConvertTol )
%        error('Unit check failed; possible convert.m error for nmi and/or m?');
%    end
%    
%    disp([mfilename,' passed all internal tests']);
%    
%return