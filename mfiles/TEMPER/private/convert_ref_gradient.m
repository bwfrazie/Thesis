function grad = convert_ref_gradient(grad,from,to,atHeight,hUnits,ae)
% convert_ref_gradient - Converts units of refractive gradient.
%
% USE: grad = convert_ref_gradient( grad, from, to, [h], [hunits], [ae] )
%
% INPUT:
%   grad - gradient, or array of gradients.
%   from - units of input; string in the form 'M/x' or 'N/x', where
%          'x' is any valid length-units recognized by convert_length.m.
%   to   - units for output gradient; string in the form " "  " ".
%   h    - (optional) height of gradient measurement(s) - must be same
%          size as "grad" input.
%   hUnits - units of height input; any string recognized by convert_length.m.
%   ae   - (optional) earth radius, in "hUnits" (can be different than length
%          units in your from/to values).
%
%
% This function based on the equation:
%
%   M(h) = N(h) + 10^6 * log(1+h/a)   where h = altitude
%                                           a = earth radius
%   therefore:
%
%       dM/dh = dN/dh + (10^6)/(a+h)
%
% With no height input, the routine assumes h = 0:
%
%       dM/dh = dN/dh + (10^6)/a
%
% Even at an altitude of 10 nmi, the error (10^6)/a - (10^6)/(h+a) for
% a "standard" dM/dh of 0.036 is only 0.00046; roughly 1% of input value.
%
%
% (c)2001-2016, Johns Hopkins University / Applied Physics Lab
% Last update: 2013-09-05


% Update list: (all JZG unless noted)
% -----------
% 2003-03-18 - Created this function based on stdgrad.m, dated 2001-10-05.
% 2004-05-06 - Minor updates
% 2013-09-05 - Added "ae" input.


	if nargin == 3
        atHeight = 0;
    elseif ( nargin == 5 )|( nargin == 6 )
        atHeight = convert_length( atHeight, hUnits, from(3:end) );
    else
		help(which(mfilename));
		error('WRONG # OF INPUT ARGUMENTS! - SEE HELP ABOVE');
    end

    if ( nargin < 6 ), ae = []; end
    
    fromRefUnits = upper(from(1));
    toRefUnits   = upper(to(1));

    if length(from) < 2, error(['Invalid units input ''',from,'''']); end
    if from(2) ~= '/',   error(['Invalid units input ''',from,'''']); end
    if length(to) < 2,   error(['Invalid units input ''',to  ,'''']); end
    if to(2)   ~= '/',   error(['Invalid units input ''',to  ,'''']); end
    
    fromHgtUnits = lower( from(3:end) );
    toHgtUnits   = lower(   to(3:end) );

    % Deal with refractivity part of units conversion
    switch [fromRefUnits,'->',toRefUnits]
        
        case {'M->M','N->N'}
            % do nothing
            
        case {'M->N','N->M'}
            if isempty( ae )
                ae = earth_radius( fromHgtUnits );
            else
                ae = convert_length( ae, hUnits, fromHgtUnits );
            end
            offset = (10^6)./( ae + atHeight );
            if fromRefUnits == 'M'
                grad = grad - offset;
            else
                grad = grad + offset;
            end
            
        otherwise
            error('Invalid refractivity units input');
            
    end

    % Deal with length part of units conversion
	x2y = convert_length(1,fromHgtUnits,toHgtUnits);
    grad = grad ./ x2y;

return