function faded = fade_colormap(factor,map)
% fades the color of a plot by "factor"
%
% USE: faded = fade_colormap(factor,map) fades "map" by "factor".
%      faded = fade_colormap(factor)     fades current map by "factor".
%      faded = fade_colormap             fades current map by factor of 2.
%
% all calls return the new map.  The function also always attempts to 
% apply this new map to a current figure.
%
% note that [ fade_colormap(f1) ] is equivalent to [ fade_colormap(f1*f2) ]
%           [ fade_colormap(f2) ]
%
% Last update: 2004-02-05 (now only updates current fig's colormap if no output
% arguments).

if nargin==0
   factor = 2;
   map = colormap;
elseif nargin==1
   map = colormap; % retrieve current colormap
end

if factor < 1
   error('fading factor must be > 1')
end

faded = 1 - (1 - map)./factor;

if ( nargout == 0 )
   try, colormap(faded)
   catch
    warning('could not fade current plot - faded colormap was returned, however')
    end
end

