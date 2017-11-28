function [maxDeg,maxChangeDeg] = max_lsm_slope( temperVersion )
%max_lsm_slope - TEMPER's maximum terrain slope for Linear Shift Map (LSM).
%
%
% USE: [maxDeg,maxChangeDeg] = max_lsm_slope( temperVersion );
%
%   Outputs are maximum allowed slope and slope change before TEMPER switches
%   away from LSM to KE in Hybrid terrain mode.
%
%
% Last update: 2015-02-22


% Update list: (all JZG)
% -----------
% 2005-02-23 - Created initial version
% 2010-02-16 - Bug fix to value (x -> atan(x)) & added slope change variable
% 2015-02-22 - Hooks still in for changes w/ TEMPER version, but so far all
% versions of TEMPER have same limits. Updated this Matlab code to accept more
% version numbers.


    if ( nargin < 1 )
        disp('Output is valid for versions 3.0.0-3.2.0');
        temperVersion = 3.1;
    end

    switch round( temperVersion * 100 )
        case {300, 310, 311, 312, 313, 314, 320}
            % This value should match the "max_ls_slope" data assignment in
            % TEMPER's "INDATA.F" source file:
            maxLsmSlope  = 2.4747e-1;
            maxLsmChange = Inf; % All current versions of TEMPER do not limit slope change!
        otherwise
            error('Unrecognized TEMPER version number');
    end

    maxDeg       = (180/pi) * atan( maxLsmSlope );
    maxChangeDeg = (180/pi) * atan( maxLsmChange );
    
return