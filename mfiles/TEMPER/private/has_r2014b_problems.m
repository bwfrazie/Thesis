function [ itIs ] = has_r2014b_problems( varargin )
%has_R2014b_problems - A switch for working around Matlab R2014b bugs/glitches
%
%   Matlab R2014b (version 8.4.0) has several quirks, especially in its graphics
%   handling. This routine is intended to be used as a logical switch for
%   working around those problems.
%
%   NOTE that these "problems" are not meant to include the expected
%   incompatibilities between pre- and post-R2014b Handle Graphics objects. Do
%   not use this routine for that purpose, instead use:
%
%       >> verLessThan('matlab','8.4.0')
%
%   The distinction is that, presumably, some of the quirks/errors in R2014b
%   will be resolved (maybe in 2015a?) and this routine will be updated to
%   return FALSE for those versions. However, the Handle Graphics changes are
%   permanent and require a reworking of your code, not a temporary work-around.
%
%
% USE: [ itIs ] = has_r2014b_problems;
%
%
% Last update: 2015-02-05

    problemsStartAt = '8.4.0';
    problemsFixedAt = ''; % TODO: fill this in when Matlab smooths things over
    
    itIs = ~verLessThan('matlab',problemsStartAt);
    
    if ( itIs ) & ~isempty( problemsFixedAt )
        itIs = verLessThan('matlab',problemsFixedAt);
    end

return

