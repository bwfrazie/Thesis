function x = db2x( db )
%db2x - For input "db", computes x = 10^(db/10) (see also x2db).
%
%
% USE: x = db2x( db )
%
%   Converts input (scalar or array) from db units (10*log10) to linear units.
%
%
% ©1999-2015, Johns Hopkins University / Applied Physics Lab
% Last update: 2005-06-21


% Update list: (all JZG unless noted)
% -----------
% 2007-02-07 - Added "test" mode w/ call to x2db's tester code.


    if strcmpi( db, '-test' )
        x2db('-test'); 
        return; 
    end

    x = 10.^(db./10); % vectorized form of 10^(db/10)

    % Note that the above expression correctly returns 0 for x when db is -inf

return