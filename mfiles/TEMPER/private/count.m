function x = count( x, dim )
%count - Returns number of true (or non-zero/nan) entries in a matrix.
%
% USE: n = count( x, [dim] );
%
%   If "dim" is omitted, function works along the first non-singleton
%   dimension.  Function can handle both logical and numeric inputs. NaN
%   entries are not counted.
%
% USE: n = count( x, 'all' );
%
%   Instead of working along a dimension of array "x", function will count
%   along *all* dimensions; hence, output will always be a single number in
%   this mode.
%
% Last update: 2008-05-15 (JZG)

% Update list:
% 2005-12-14
% 2008-05-15 Fixed bug for the case of empty input.

    if nargin == 1
        dim = [];
    elseif nargin ~= 2
        error('Must provide 1 or 2 inputs');
    elseif ( nargin >= 2 )
        % Smoothly handle dim=='all' mode by vectorizing x & setting dim to 1:
        if strcmpi( dim, 'all' ), x = [x(:)]; dim = 1; end
    end

    % Must handle empty arrays as a special case
    if isempty(x)
        x = 0;
        return
    end

    % Convert to an array of all zeros & ones
    if islogical( x )
        x = double( x );
    elseif isnumeric( x )
        iNan = isnan( x );
        x(iNan) = 0;
        x = double( x & x ); % DOUBLE->LOGICAL->DOUBLE conversion is very fast
        % The following code is slower, and can cause a "NaN's
        % cannot be converted to logicals" error in Matlab R13:
        %DON'T USE: iOne = find( abs(x) > eps );
        %DON'T USE: x = zeros( size(x) );
        %DON'T USE: x(iOne) = 1;
    end
    
    % Default to first non-trivial (size > 1) dimension:
    if isempty( dim )
        % Note that empty arrays have already been handled.
        xSize = size(x);
        i = find( xSize > 1 );
        if isempty(i)
            dim = 1;
        else
            dim = i(1);
        end
    end

    % By now, assured that x is a logical array - convert to 
    % doulbe to get all 1/0 entries.
    x = double( x );

    % Because all entries are 1 or 0, summing the array along the
    % prescibed dimension is the same as a COUNT() operation:
    x = sum( x, dim );

return

    
    