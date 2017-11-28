function x = convert_length( x, from, to )
%convert_length - Converts length units.
%
% USE: y = convert_length( x, from, to );
%
%   Input:
%       x    - numeric variable of any size [MxN]
%       from - string specifying current length units of "x"
%       to   - string specifying length units for output
%   Output:
%       y    - unit-converted version of x.
%
% USE: unitStrList = convert_length;
%
%   When called with no inputs, function returns a list (cellstr) of recognized
%   unit strings.  This is especially useful as a means of providing an always-
%   correct list of strings to a graphics object that allows user to select
%   units.
%
%
% (c)2001-2016, JHU/APL (A2A)
% Written by: jonthan.gehman@jhuapl.edu
% Last update: 2016-01-04


% Update list: (all JZG unless noted)
% -----------
% 2005-12-18 - nargout==0 mistake has bit me several times in external routines
% that call this function (i.e., convert a value but forget to update variable
% with new value), so changed nargout==0 from WARNING to ERROR. This is why
% the following error occurs:
%       Error using convert_length (line 79)
%       Must provide an explicit output argument for conversion
% 2006-02-10 - moved most of code to convert_engine.m - what's left is merely a
% wrapper routine - and added millimeters, centimeters and inches
% 2006-02-22 - added 'yards' & skip multiplication when factor = 1.0
% 2006-07-01 - fixed bug in 'yards' conversion
% 2012-02-09 - renamed function from convert.m to convert_length.m to avoid
% confusion with a growing number of "convert_..." functions in the \unitfun\
% folder. No functional changes from the 2006-07-11 version were made.
% 2016-01-04 - Removed updates < 2005 from this list. Added AU & parsec 4 grins.
 

    % Parameter list has form:
    %   full unit name,   to-meters factor,  alternate names (cellstr);
    conversionBasis = {...
        'meters',           1,          {'m','meter'};...
        'kilometers',       1000,       {'km','kilometer'};...
        'millimeters',      0.001,      {'mm','millimeter'};...
        'centimeters',      0.01,       {'cm','centimeter'};...
        'inches',           0.0254,     {'in','inch'};...
        'feet',             0.3048,     {'ft','foot'};...
        'yards',            0.9144,     {'yd','yard'};...
        'kilofeet',         304.8,      {'kft','kilofoot'};...
        'nautical miles',   1852,       {'nm','nmi','nautical mile'};...
        'statute miles',    1609.344,   {'mi','miles','mile','statute mile'};...
        'data miles',       1828.8,     {'dm','dmi','data mile'};...
        'astronomical units',149597870700,{'au','astronomical unit'};...
        'parsecs',          3.08567782e16,{'pc','parsec'}  };
    
    % Notes:
    % -----
    % - All strings in the above list must be unique and all-lowercase (type
    %   "help convert_engine" for more info)
    %
    % - Factors are all exact (see, for example, Abramowitz & Stegun, 1972),
    %   except for parsecs which is approximate (+/- ~1 part in 1e9)
    %
    % - The algorithm used by this function will not introduce any errors in
    %   cyclical conversions, within the limits of floating-point arithmetic.
    %
    % - In R12 & R12.1 (and possibly later releases), Matlab Mapping Toolbox
    %   conversion function was slightly incorrect on some units*, which is one
    %   of the reasons I've spent time updating and maintaining this function.
    %
    % * Matlab Mapping Toolbox's DISTDIM.M conversion from any english unit to
    %   any metric units is was in error by ~0.003% in some releases.

    if ( nargin == 0 ) % return list of valid unit strings if no input arguments
        x = convert_engine( conversionBasis, which(mfilename), 'list' );
        return
    elseif ( nargin ~= 3 ) % added 2005-12-18
        error('Must provide 3 inputs when converting numerical values!');
    elseif ( nargout == 0 ) % added 2005-12-18
        error('Must provide an explicit output argument for conversion');
    end

    factor = convert_engine( conversionBasis, which(mfilename), ...
                             'factor', from, to );
                         
    if ( factor ~= 1 ), x = factor .* x; end

return
