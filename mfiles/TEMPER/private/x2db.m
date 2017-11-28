function [db,nChunks] = x2db( x, varargin )
%x2db - An extremly robust 10*log10(x) calculation (see also db2x).
%
% This routine is essentially 10*log10(x), with error handling for several
% significant problems that could occur for 10*log10(x) in Matlab:
%   - handles x < 0
%   - handles complex x
%   - handles NaN, +Inf & -Inf values
%   - averts out-of-memory problems in LOG10 for large arrays
%
%
% USE: db = x2db( x );
%
%   Converts input (scalar or array) from linear to db units (10*log10).  When
%   input is complex, output is magnitude in db.  Where input is <= 0, output
%   is NaN.  See also DB2X.M
%
%
% USE: [db,nChunks] = x2db( x, [nLog10Chunk] );
%
%   Same as above, except optional 2nd input allows external control over the
%   maximum # of values passed into LOG10 at a time.  When omitted, a hardcoded
%   default value of 1500^2 is used.  Arrays with more than "nLog10Chunk"
%   elements are never passed into LOG10 at once - otherwise, unusually slow
%   execution times and/or out-of-memory problems would occur.  Instead, the
%   array is broken into smaller "chunks", each of which are passed into LOG10
%   separately to generate the final output array. 
%
%   Optional 2nd output returns the number of "chunks" that the input array was
%   broken into in order to avoid out-of-memory problems.
%
%
% USE: [...] = x2db( ..., '-nowarn' );
%
%   Append a string argument of '-nowarn' to any of the above calling conventions
%   to supress warning messages.
%
%
% USE: x2db -test;
%
%   With the string 'test' input, tester code checks both x2db.m and db2x.m for
%   errors.
%
%
% ©1999-2015, Johns Hopkins University / Applied Physics Lab
% Last update: 2009-06-04


% Update list: (all JZG unless noted)
% -----------
% 2004-02-25 - Created test mode.
% 2005-06-21 - Now outputs -Inf instead of NaN when input == 0
% 2005-09-16 - Added "chunking" to avert memory errors for large input.
% 2005-10-20 - Fixed bug in the "chunking" code.
% 2007-02-28 - Changed "test" mode trigger from no input to 'test' input,
% switch from constant to subroutine for default chunk size. Added to tester
% routine, making it a complete test of both x2db & db2x functionality.
% 2007-09-18 - Added "nowarn" input option & made extra_arg_handler(), and
% used this new option to suppress all extraneous messages in test mode.
% 2009-06-04 - Changed nowarn flag from 'nowarn' to '-nowarn' to match
% conventions in my other mfiles (code still supresses warnings for *any* non-
% empty string input, so old 'nowarn' inputs will still work even ow).


    % Special "test" mode, created 2004-02-25
    if ( nargin == 1 )
        if strcmpi( x, '-test' ), run_test; return; end
    end
    
    % This routine only parses the inputs into the appropriate local variables -
    % it does *NOT* assign default values. Empty values for the local variables
    % indicate that the variable was not provided at the command line, *OR* was
    % provided as an empty input variable (which provides a convenient way for
    % the user to trigger default behavior of only specific inputs):
    [nLog10Chunk,noWarn] = extra_arg_handler( varargin );
    
    % Log10 chunking functionality added 2005-09-16 
    if isempty(nLog10Chunk), nLog10Chunk = default_chunk_size; end 

    % no-warnings added 2007-09-18
    if isempty(noWarn), noWarn = 0; end
    showWarn = not( noWarn );
    
    % Initialize output to NaN w/ same size & shape as input
    db = repmat( NaN, size(x) );

    % Check for complex input, and convert to magnitudes if necessary
    iImag = find( imag(x) ~= 0 );
    if length( iImag ) > 0
        if ( showWarn  )
            disp(['Warning: using magnitude of complex input in ' mfilename]);
        end
        % Only apply ABS( ) to the complex elements, otherwise negative
        % reals will be treated incorrectly
        x(iImag) = abs( x(iImag) );
    end 

    % Find those elements of "x" which will not cause LOG10 errors
    iGt0 = find( x > 0 );  % Note: (NaN > 0) return FALSE, which keeps
                           % NaN's from going through the call to LOG10
                           % and thereby speeds up the function.

    % Warn user if some of the elements are <= zero
    if ( length(iGt0) ) < prod( size(x) ) & ( showWarn )
        % ... then the # of indices with elements > 0 is less than the total
        % ... # of elements in x, therefor some elements must be <= 0
        disp(['Warning: NaN''s and/or values <= 0 in input array (will',...
              ' be NaN or -Inf on output from ',mfilename,')']);
    end

    % Only operate on elements that are greater than zero
    
    nVals  = length(iGt0);
    if ( nVals <= nLog10Chunk )
        db( iGt0 ) = 10.*log10( x( iGt0 ) );
        nChunks = 1;
    else
        if ( showWarn )
            disp([upper(mfilename),': chunking calls to LOG10 in an',...
                ' attempt to avoid memory problems']);
        end
        nChunks = ceil( nVals/nLog10Chunk ); % <- fixed bug, 2005-10-20
        ii1 = 1;
        for iCall = 1:nChunks
            ii2 = ii1 + nLog10Chunk - 1;
            ii2 = min( ii2, nVals );
            db( iGt0(ii1:ii2) ) = 10.*log10( x( iGt0(ii1:ii2) ) );
            ii1 = ii2 + 1;
        end
        if ( showWarn )
            disp([upper(mfilename),': succesfully prevented memory problems']);
        end
    end
    
    % New, 2005-06-21 -> wherever input is exactly 0, set the output to -Inf
    % rather than NaN:
    iEq0 = find( x == 0 );
    db(iEq0) = -inf;
    
return





function [nLog10Chunk,noWarn] = extra_arg_handler( args )

    [nLog10Chunk,noWarn] = deal([]);
    
    switch length(args)
        
        case 0
            % do nothing - return all empty local vars
            
        case 2
            % Calling convention dictates that nLog10Chunk come first for
            % backward-compatibility reasons:
            nLog10Chunk = args{1};
            noWarn      = args{2};
            
        case 1
            thisArg = args{1};
            if isnumeric(  thisArg )
                nLog10Chunk = thisArg;
            elseif ischar( thisArg )
                noWarn      = thisArg;
            else
                error('Improper input - expecting either numeric or string (char) value');
            end
            
        otherwise
            error('Incorrect # of input arguments');
            
    end

return





function n = default_chunk_size
% Only point of this routine is to provide access to this number in both the
% main routine *and* the tester routine without having to resort to globals or
% code duplication.
    n = 2250000; % defaults to 1500^2
return





%function run_test
%
%    % This variable sets the tolerance for IS_EQUAL calls, as a relative
%    % tolerance, for declaring values as "practically equal". Note that the 
%    % original eps of 2e-16 was too restrictive due to cumulative roundoff
%    % error in the floating-point operations involved in X2DB & DB2X.
%    relEps  = 1e-10; 
%    
%    disp('Running internal accuracy tests for x2db.m & db2x.m');
%    
%    % First, a few quick accuracy tests using integer values:
%    if any( x2db([1,10,100]) ~= [0,10, 20] ), error('x2db is not accurate'); end
%    if any( db2x([0,10, 20]) ~= [1,10,100] ), error('db2x is not accurate'); end
%    
%    % Do a series of x2db->db2x tests ...
%    
%    x = reshape( logspace(-7,7,(3*4*5*6)), [3,4,5,6] );
%    x2 = db2x( x2db( x, '-nowarn' ) );
%    if ~is_equal( x, x2, 'ignoreTranspose',0, 'relativeTol',relEps )
%        error('x2db->db2x failed for N-dim array');
%    end
%    
%    x   = reshape( x, 1, prod(size(x)) );
%    x2  = db2x( x2db( x,   '-nowarn' ) );
%    x2T = db2x( x2db( x.', '-nowarn' ) );
%    if ~is_equal( x, x2, 'ignoreTranspose',0, 'relativeTol',relEps )
%        error('x2db->db2x failed for row vector');
%    elseif ~is_equal( x.', x2T, 'ignoreTranspose',0, 'relativeTol',relEps )
%        error('x2db->db2x failed for col vector');
%    end
%    
%    % Using same "x", test x2db of complex inputs ...
%    
%    xComplex = complex( x./sqrt(2), x./sqrt(2) );
%    y1 = x2db( x,        '-nowarn' );
%    y2 = x2db( xComplex, '-nowarn' );
%    if ~is_equal( y1, y2, 'relativeTol',relEps )
%        error('Failed complex number test');
%    end
%    
%    % Now do a new cyclic test, this time starting in dB vice linear ...
%    
%    x  = [-1000:100:1000];
%    x2 = x2db( db2x( x ), '-nowarn' );
%    if ~is_equal( x, x2, 'relativeTol',relEps )
%        error('db2x->x2db failed');
%    end
%
%    % Test "special" input/output values: NaN & empty [] ...
%    
%    x = [NaN,-1,-eps];
%    if any( ~isnan(x2db(x,'-nowarn')) )
%        error('x2db failed NaN test');
%    end
%    
%    if ~isempty( x2db(db2x( [] ),'-nowarn') )
%        error('x2db and/or db2x failed empty input test');
%    end
%    
%    % Test 0 & infinite input/output values ...
%    
%    if ~is_equal( 0, db2x(x2db(0,'-nowarn')) )
%        error('x2db and/or db2x failed zero input test');
%    elseif ~is_equal( -inf, x2db(0,'-nowarn') )
%        error('x2db does not output -Inf for 0 input');
%    elseif ~is_equal( 0, db2x(-inf) )
%        error('db2x does not output 0 for -Inf input');
%    elseif ~is_equal( inf, x2db(inf,'-nowarn') )
%        error('x2db does not output +Inf for +Inf input');
%    elseif ~is_equal( inf, db2x(inf) )
%        error('db2x does not output +Inf for +Inf input');
%    end
%    
%	% Test x2db's default "chunking" mode ...
%    
%    nDefault = default_chunk_size;
%    
%    testSizeCmds  = {'nDefault-1','nDefault','nDefault+1','nDefault*3+1'};
%    expectNChunks = [ 1,           1,         2,           4            ];          
%    for i = 1:length(testSizeCmds)
%        testSize = eval([ '[1,',testSizeCmds{i},']' ]);
%        x = repmat( 0.1, testSize );
%        [db,nChunks] = x2db(x,'-nowarn');
%        if any( db ~= -10 ) | ( nChunks ~= expectNChunks(i) )
%            error(['x2db "chunk" mode failed for ',testSizeCmds{i}]);
%        end
%    end
%    
%	% Test x2db's "chunking" mode for various array shapes & sizes w/ explicit
%	% chunk-size input ...
%    
%    x = rand(1,1000) + eps; % + eps to avoid log10(0) complications
%    dbCheck = 10.*log10( x );
%    
%    [db,nChunks] = x2db( x, 10, '-nowarn' );
%    if ~is_equal( db, dbCheck )
%        error('x2db output incorrect for non-default chunk size (vector)');
%    elseif ( nChunks ~= 100 )
%        error('x2db reports and incorrect # chunks (vector)');
%    end
%    
%    x = reshape( x, [10,100] );
%    dbCheck = reshape( dbCheck, size(x) );
%    [db,nChunks] = x2db( x, 10, '-nowarn' );
%    if ~is_equal( db, dbCheck )
%        error('x2db output incorrect for non-default chunk size (array)');
%    elseif ( nChunks ~= 100 )
%        error('x2db reports and incorrect # chunks (array)');
%    end
%    
%    disp('x2db & db2x passed all internal tests');
%    
%return        