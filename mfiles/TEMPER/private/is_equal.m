function [xySame,Opts] = is_equal( x, y, varargin )
%is_equal - Flexible, customizable, recursive, robust alternative to (==)
%
%
% USE: xySame = is_equal( x, y, [opt1, val1, opt2, val2, ...] );
%
%   OPTIONS:            VALUES:     NOTES:
%   -------             ------      -----
%
%   'ignoreCase'        (0|1)       When 1, strings that differ by lower/upper-
%                                   case only are treated as equal. Default = 1.
%
%   'ignoreNan'         (0|1)       When 0, treats (NaN == x) as true iff x is
%                                   NaN. When 1, treats as true for all x.
%                                   Default = 0.
%
%   'absoluteTol'       (numeric)   Absolute tolerance for comparing doubles.
%                                   Value must be >= 0.
%
%   'relativeTol'       (numeric)   Relative tolerance for comparing doubles.
%                                   Value must be >= 0 and < 1.
%
%   'requireBothTols'   (0|1)     * You can input either a relative or absolute
%                                   tol, or both. If both are input, default  
%                                   behavior considers x & y equal if *either*
%                                   the relative or absolute tols are satisfied.
%                                   Input 1 for 'requireBothTols' to override 
%                                   this default behavior.
%
%   'ignoreTranspose'   (0|1|2)     1 -> x & transpose(x) treated as equal
%                                   only when x is a vector. Value of 2 -> x &
%                                   transpose(x) treated equal even when x is an
%                                   array. For n-dimensional vectors a value of
%                                   1 or 2 will treat any permutation of the
%                                   same numeric vector as equal, however
%                                   n-dimensional arrays (for n > 2) will never
%                                   be treated equal even if 'ignoreTranspose'
%                                   is set to 2.
%
%   'ignoreFields'      (cellstr)   List of structure field names to ignore in
%                                   struct comparisons.  List is case sensitive
%                                   and applies to all nested structs in input.
%
%   'verbose'           (0|1)       When 1, messages printed to screen.
%
%   'fastFalse'         (0|1)       When 1, returns false at first difference.
%                                   When 0, always checks all elements/fields.
%
%   'mixedIntClass'     (0|1)       When 1, integer classes, doubles, and
%                                   logical types are allowed to be equal if,
%                                   after typecasting, values are equivalent.
%                                   Default = 1.
%
%   'mixedFloatClass'   (0|1)       When 1, doubles and floats are allowed to be
%                                   equal if, after typecasting, values are 
%                                   equivalent. Default = 1.
%
%   'mixedEmptyClass'   (0|1)       When 1, all varieties of empty (e.g., [], {}
%                                   and '') are treated as equivalent. 
%                                   Default = 0.
%
%   'analysisCmd'       (0|1)       Any string involving Matlab functions,
%                                   'x', 'y', 'xName' & 'yName'.  String passed
%                                   to EVAL.M whenever numeric arrays differ.
%
%
% USE: [xySame,Opts] = is_equal( ... )
%
%   In this mode, the options used for the equivalence test are echoed back to
%   the user as fields of the output structure "Opts".  "Opts" also has one
%   additional field (.msg) holds a cellstr - one descriptive string for each
%   difference found.  Note that the 'fastFalse' option affects whether 
%   "Opts.msg" describes just the first, or all differences found.
%
%
% EXAMPLES: 
%
%   % All examples below use these structures:
%   S1 = struct('rand',rand(10),'string','Hi','ones',ones(10),'different',[3,4]);
%   S2 = struct('rand',rand(10),'string','hI','ones',ones(10),'different',[5]);
%
%   % This will return false. Depending on your version of Matlab and how
%   % structs are constructed, the info printed to the screen will either list
%   % 'different', 'rand' or 'string' as the reason for declaring FALSE:
%   is_equal( S1, S2, 'ignoreCase',0 )
%
%   % This will return false noting that 'rand', 'string' & 'different' all are
%   % mismatches
%   is_equal( S1, S2, 'ignoreCase',0, 'fastFalse',0 )
%
%   % This will suppress messages to the screen
%   [xySame,Opts] = ...
%   is_equal( S1, S2, 'ignoreCase',0, 'fastFalse',0, 'verbose',0 )
%
%   % Note that Opts.msg from example above contains all the messages about
%   % differences that would have gone to the screen, in a cell array:
%   char( Opts.msg )
%
%   % This will return true because:
%   %   'ignoreCase'   -> ignores difference in 'string'
%   %   'absoluteTol'  -> ignores differences in 'rand'
%   %   'ignoreFields' -> ignores 'different' 
%   is_equal( S1, S2, 'ignoreCase',1, 'absoluteTol',1.0, 'ignoreFields',{'different'} )
%
%
% SEE ALSO (JZG): is_equal_mat, is_equal_matfile, is_equal_file
% SEE ALSO (bulitin): ISEQUAL, ISEQUALWITHEQUALNANS
%
% ©2002-2014, JHU/APL (AMDD-A2A)
% Written by: jonathan.gehman@jhuapl.edu
% Last update: 2012-03-20


% ~~~ Additional programmer-only header comment ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% RECURSIVE USE: [xySame,Opts] = is_equal( x, y, Opts, xName, yName );
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% UPDATE LIST: (all JZG)
%-------------
% 2004-01-16: Update log started.
% 2004-04-15: Fixed bugs in handling of structures with different fields.
% 2004-10-28: Added handling of +/-Inf entries.
% 2005-04-08: Ad hoc workaround for Matlab 6.5 bug (SIGN not defined for
% logical type).
% 2006-03-15: Added output "Opts".
% 2006-10-05: Added 'ignoreFields' input opt & 'msg' output.
% 2007-01-10: Warning for potential confusion when relative tol with x~=0 &
% y~=0 (e.g., is_equal(0,1e-6,'tolerance',1e-5) == false!) - basically a zero
% in relative-tolerance mode effectively does *not* allow for any tolerance!
% 2007-12-14: Replaced 'tolerance'/'relativeTolerance' inputs w/
% 'relativeTol' & 'absoluteTol'. Fixes problem identified on 2007-01-10;
% removed the temporary warning.
% 2008-03-27: Added call to builtin ISEQUAL for classes that are not yet
% handled in function's main switchyard (switch xClass), e.g. R2006's
% function_handle type.
% 2008-06-12: Moved is-empty check above size check to work around the
% stupifying Matlab error of two "empty" variables, one with "size" 1x0 and the
% other with "size" 0x0 (discovered in R2006b, possibly a problem in other
% releases as well?).
% 2009-05-20: Added 'mixedFloatClass' input.
% 2009-06-15: Added true/false constant definitions & fixed 1x1 sparse output.
% Fixed bug in 2009-05-20 implementation for x & y 'single' type input.
% 2009-10-26: Added 'mixedEmptyClass' input.
% 2009-11-03: Added 'requireBothTols' input.
% 2010-07-25: Added a few more checks on backward-compatability mode for the
% "relativeTolerance" input.
% 2012-03-20: Added new 'ignoreTranspose' option (2) and changed default
% behavior. Previous default was essentially identical to the new option (2),
% whereas the new default behavior is to only let x == transpose(x) when x is a
% vector (as determined by the is_vector function). This fixes what was 
% essentially a logical oversight in the old code, by which transposed arrays
% were treated as equivalent by default. This is no longer the case, but the
% "old" functionality can be revived using the new (2) option. Also added
% comprehensive unit tests (run_test subroutine) and checked code coverage.
% Existing unit tests cover a majority (80-90%) of the code, omitting only
% "analysisCmd" functionality and code related to backward-compatibility with
% older tolerance inputs. 
% 2014-04-28: No functional change, so I didn't modify the "last update" date.
% Changes were to header comments (added default vals & examples) and internal
% code comments.


% TODO: (high pri) SWITCH TO VARARGIN_STRUCT_HANDLER.M and start throwing errors
% for unrecognized input params (trips me up all the time).


% TODO: (low pri) Allow different "analysiCmd"'s based on dimension of array...
% Functionality currently doesn't work because the IS_SAME() subroutine
% vectorizes all input arrays.  Reason for vectorization was so that NaN's
% could be ignored by removing elements from vector - that can't be done if
% arrays are allowed to maintain their shape...
%
% (add this bit back into header comments if/when a solution is found)
%                                   Can also be a 3-element cellstr where:
%                                   - analysisCmd{1} -> eval for vectors
%                                   - analysisCmd{2} -> " " 2-d arrays
%                                   - analysisCmd{3} -> " " n-d arrays (n>2)


% Initialization:
%%%%%%%%%%%%%%%%%

    % "Hardcoded" constant:
    integerTypes = {'logical','int8','uint8','int16','uint16','int32','uint32'}; % Must all be lowercase!!!
    floatTypes   = {'single','double'}; % Must all be lowercase!!!
    
    % Explicitly defining these comments makes code work best in the most # of
    % Matlab releases:
    true  = (1==1);
    false = not(true);
    
    % Initialize:
    xySame = true;
    msg = '';

    % Set mode:    
    isRecursion = false;
    if ( nargin == 1 )
        if strcmpi(x,'-test'), run_test; return; end
    end
    if ( nargin == 5 )
        % Recursive mode - double check to make sure that the third input (which
        % corresponds to the 1st element of VARARGIN) is a structure (Opts):
        if isstruct( varargin{1} ), isRecursion = true; end
    end
    if ( not(isRecursion) & is_odd(nargin) )|( nargin == 0 )
        error(['Incorrect # of inputs to ',mfilename]);
    end
    
    % If at top-level call (i.e. not in a recursive call), handle list of input
    % options:
    if ( isRecursion )
        Opts  = varargin{1};
        xName = varargin{2};
        yName = varargin{3};
    else
        % Automatically determine x/yName for use in error messages
        xName = inputname(1); 
        if isempty(xName), xName = 'x'; else, xName = strrep(xName,'_',' '); end
        yName = inputname(2); 
        if isempty(yName), yName = 'y'; else, yName = strrep(yName,'_',' '); end
        % Set defalut Opts values:
        Opts.ignorecase        = true;
        Opts.ignorenan         = false;
        Opts.tolerance         = []; % <- for backward compatibility only!
        Opts.relativetolerance = []; % <- for backward compatibility only!
        Opts.relativetol       = [];
        Opts.absolutetol       = [];
        Opts.requirebothtols   = 0;
        Opts.ignoretranspose   = 1; % changed default & options for this, 2012
        Opts.mixedintclass     = true;              
        Opts.mixedfloatclass   = true; 
        Opts.mixedemptyclass   = false;
                                                 % OUTPUT:          DEFAULT MODE:
        Opts.fastfalse         = (nargout <= 1); % []            -> fast & verbose
        Opts.verbose           = (nargout == 0); % [xySame]      -> fast & quiet
        Opts.analysiscmd       = [];             % [xySame,Opts] -> slow & quiet (slow so that "msg" is filled)
        Opts.ignorefields      = {};
        Opts.msg               = {};
        for i = 1:2:length(varargin)
            param = lower(varargin{i});
            value = varargin{i+1};
            if ~isfield( Opts, param )
                warning(['Ignoring unrecognized input ''',param,'''']);
            else
                Opts = setfield( Opts, param, value );
            end
        end
        % ~~~ Compatibility handling for new (2007-12-10) tolerance inputs  ~~~
        if isempty( Opts.relativetol ) & isempty( Opts.absolutetol )
            if isempty( Opts.tolerance ) & isempty( Opts.relativetolerance )
                % Situation: either new or old convention, no tolerance inputs
                % Approach:  enforce *NEW* defaults either way:    
                Opts.relativetol = eps;
                Opts.absolutetol = eps;
                %
                % Note that old defaults of: Opts.tolerance         = eps;
				% 	                         Opts.relativetolerance = 1;
                %
                % Would now be input as:     Opts.relativetol       = eps;
				% 	                         Opts.absolutetol       = [];
                %
            else
                % Warning added 2010-07-25
                warning(['Please use new .relativeTol & .absoluteTol paramters',...
                    ' instead of the old .tolerance & .relativeTolerance']);
                % Situation: old calling convention w/ tolerance and/or
                %            relativetolerance inputs
                % Approach:  enforce *old* default behavior:
                if isempty( Opts.tolerance )
                    Opts.tolerance = eps; % <- this was the old default
                end
                if isempty( Opts.relativetolerance )
                    Opts.relativetolerance = true; % <- this was the old default
                else
                    % New, 2010-07-25
                    check = double( Opts.relativetolerance );
                    if ( check ~= 0 )&( check ~= 1 )
                        error('Bad .relativetolerance; not a logical (0 or 1)');
                    end
                end
                if ( Opts.relativetolerance )
                    Opts.relativetol = Opts.tolerance;
                    Opts.absolutetol = [];
                else
                    Opts.relativetol = [];
                    Opts.absolutetol = Opts.tolerance;
                end
            end    
            Opts = rmfield( Opts, 'tolerance' );
            Opts = rmfield( Opts, 'relativetolerance' );
        elseif ~isempty( Opts.tolerance ) | ~isempty( Opts.relativetolerance )
            error('Cannot mix new & old tolerance calling conventions!');
        else
            % New, 2010-07-25
            Opts = rmfield( Opts, 'tolerance' );
            Opts = rmfield( Opts, 'relativetolerance' );
        end
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        if Opts.verbose, disp( Opts ); end
    end

    % Extra handling required for "analysiscmd" as of 2004-01-06
    if ~isempty(Opts.analysiscmd) & ischar(Opts.analysiscmd)
        % Use same command for vectors (1), arrays (2) & n-d matrices (3)
        Opts.analysiscmd = repmat( {Opts.analysiscmd}, 1, 3 );
    end
    
    if min([Opts.relativetol,Opts.absolutetol]) < 0
        error('Tolerance cannot be negative!');
    end
    
    if ~isempty(Opts.relativetol)
        if ( Opts.relativetol >= 1 ), error('A relative tolerance >= 1.0 is meaningless');
        elseif ( Opts.relativetol >= 0.5 ), warning('Very lax tolerance, >= 50%');
        end
    end    
    
% x & y will be modified,
% but first, save copies of
% original variables for use
% in any "analysisCmd"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%    original_x = x;
%    original_y = y;


% Check for class difference:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    xClass = lower( class(x) );
    yClass = lower( class(y) );
    
    % Handle class differences
    if ~strcmp( xClass, yClass )
        isInteger = ismember( {xClass,yClass}, integerTypes );
        isEmpty   = [( length(x) == 0 ), ( length(y) == 0 )];
        if ( Opts.mixedfloatclass )
            isDouble = ismember( {xClass,yClass}, floatTypes );
        else
            isDouble = ismember( {xClass,yClass}, {'double'} );
        end
        if all( isEmpty ) & ( Opts.mixedemptyclass ) % new, 2009-10-26
            xySame = true;
            Opts = display_msg( Opts, [' ... ',xName,' and ',yName,' are',...
                ' both empty but of different classes - treating as equal'] );
            return % no point in continuing if both are empty            
        elseif all( isInteger ) & ( Opts.mixedintclass )
            % Convert values to 'double', but still compare like integers
            x = double( x );
            y = double( y );
        elseif all( isInteger | isDouble ) & ( Opts.mixedintclass )
            % Convert values to 'double', and compare like doubles
            x = double( x ); xClass = 'double';
            y = double( y ); yClass = 'double';
        elseif all( isDouble ) & ( Opts.mixedfloatclass )
            % Convert values to 'double', and compare like doubles
            x = double( x ); xClass = 'double';
            y = double( y ); yClass = 'double';
        else
            xySame = false;
            Opts = display_msg( Opts, [xName,' not same class as ',yName] );
            return % cannot continue w/ comparison if classes differ
        end
    end
    
    
% Handle special case: two empty inputs of the same class.  Treat them as equal
% (added 2003-12-02, moved above size check 2008-06-12 - see header comments).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    isEmptyInput = isempty(x) & isempty(y);
    if ( isEmptyInput )
        xySame = true;
        Opts = display_msg( Opts, [' ... ',xName,' and ',yName,' are both empty'] );
        return % no point in continuing if both are empty
    end


% Check for size difference:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [isSizeSame,x,y] = same_size( x, y, Opts.ignoretranspose );
    xySame = isSizeSame & xySame;
    if ~isSizeSame
        Opts = display_msg( Opts, [xName,' not same size as ',yName] );
        return % cannot continue w/ comparison if sizes differ
    end
    
    % Vectorize from this point on
    x = [x(:)];
    y = [y(:)];
    
    
% Check for difference in value
% (or recurse over elements of
%  cells, fields of structs):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    allNumericTypes = [floatTypes,integerTypes];

    switch xClass
        
        case allNumericTypes
            
            [isNanSame,x,y] = same_nans( x, y, Opts.ignorenan );
            xySame = isNanSame & xySame;
            if ~isNanSame
                Opts = display_msg( Opts, [xName,' differs by NaN entries from ',yName] );
                if ( Opts.fastfalse ), return; end
            end
            
            [isInfSame,x,y] = same_infs( x, y );
            xySame = isInfSame & xySame;
            if ~isInfSame
                Opts = display_msg( Opts, [xName,' differs by finite vs. +/-Inf entries from ',yName] );
                if ( Opts.fastfalse ), return; end
            end
            
            % Because calls to "same_infs" and "same_nans" remove elements from
            % the vectors, it's possible that x & y are empty at this point:
            if isempty(x) & isempty(y), return; end
            
            isEitherFloat = ismember( xClass, floatTypes ) | ismember( yClass, floatTypes );
            
            if ( isEitherFloat )
                
                % If originally floating-point numbers, allow for a user-
                % specified tolerance in the equality check. Note that for
                % complex numbers this tolerance is effectively a distance
                % in the Re/Im plane.
                
                % Note that using logical ops w/ ALL() is much faster than MAX()
                % in Matlab; e.g., speed2 will be ~50-100 faster than speed1 ...
                %
                %   n = 1e7; x = rand(n,1); 
                %   tic; temp = max(x);    isOk = ( temp < 0.001 ); speed1 = toc
                %   tic; temp = (x<0.001); isOk = all( temp );      speed2 = toc
                
                if isempty( Opts.relativetol ) & isempty( Opts.absolutetol )
                    error('Code bug detected - both relative & absolute tols are empty!');
                end
                
                absDelta = abs( x - y );
                if ~isempty( Opts.absolutetol )
                    isAbsDeltaOk = ( absDelta <= Opts.absolutetol );
                else
                    % Initialize to all TRUE if both tols required, in
                    % anticipation of an AND operation below; otherwise, use
                    % FALSE in anticipation of an OR operation below.
                    isAbsDeltaOk = repmat(Opts.requirebothtols, size(absDelta));
                end
                    
                if ~isempty( Opts.relativetol )
                    % For relative-tol comparison, normalize deltas;
                    % max( eps, ... ) in denom to prevent div-by-0 errors.
                    relDelta = absDelta ./ max( eps, max(abs(x),abs(y)) );
                    isRelDeltaOk = ( relDelta <= Opts.relativetol );
                    % When both relative & absolute tolerances set, only require
                    % *ONE* of the two criteria to be satisfied, unless
                    % requested otherwise by .requirebothtols option:
                    if ( Opts.requirebothtols )
                        isDeltaOk = ( isAbsDeltaOk & isRelDeltaOk );
                    else
                        isDeltaOk = ( isAbsDeltaOk | isRelDeltaOk );
                    end
                else
                    isDeltaOk = isAbsDeltaOk; % <- user only gave an absolute tol
                end
                
                isValueSame = all( isDeltaOk );
                
                if ~isValueSame
                    if ~isempty( Opts.relativetol ) & ~isempty( Opts.absolutetol )
                        tempStr = [' (max rel./abs. |delta| = ',...
                                num2str(max(relDelta)*100),'% / ',num2str(max(absDelta)),')'];
                    elseif ~isempty( Opts.relativetol )
                        tempStr = [' (max rel. |delta| = ',num2str(max(relDelta)*100),'%)'];
                    else % ~isempty( Opts.absolutetol )
                        tempStr = [' (max abs. |delta| = ',num2str(max(absDelta)),')'];
                    end
                    tempStr = [sprintf('\n'),tempStr];
                end
            
            else % integer types, already converted using DOUBLE()
                
                % If originally integers, do not use a tolerance in the
                % comparison:
                isValueSame = all( x == y );
                tempStr = '';
                
            end
            
            % Added 2009-06-15 to prevent Matlab 1x1 sparse output
            if issparse( isValueSame ), isValueSame = full( isValueSame ); end
            
            xySame = isValueSame & xySame;
            if ~isValueSame
                if ~isempty( Opts.analysiscmd )
					% x = original_x;
					% y = original_y;
                    iCmd = min( 3, length(setdiff(size(x),[0,1])) );
                    if ( iCmd > 0 )
                        thisCmd = Opts.analysiscmd{iCmd};
                        if ( Opts.verbose ), catchCmd = 'disp(lasterr); pause;';
                        else,                catchCmd = 'warning(lasterr);'; end
                        eval( thisCmd, catchCmd );
                    end
                end
                Opts = display_msg( Opts, [xName,' is numerically different than ',yName,tempStr] );
                if ( Opts.fastfalse ), return; end
            end
            
        case 'char'
            
            if Opts.ignorecase
                x = lower(x);
                y = lower(y);
            end
            isCharSame = all( x == y );
            xySame = isCharSame & xySame;
            if ~isCharSame
                Opts = display_msg( Opts, [xName,' has different characters than ',yName] );
                if ( Opts.fastfalse ), return; end
            end
            
        case 'cell'
            
            for i = 1:length(x)
                thisXName = [xName,'{',int2str(i),'}'];
                thisYName = [yName,'{',int2str(i),'}'];        
                [isValueSame,Opts] = is_equal( x{i}, y{i}, Opts, thisXName, thisYName );
                xySame = isValueSame & xySame;
                if ~isValueSame
                    Opts = display_msg( Opts, msg );
                    if ( Opts.fastfalse ), return; end
                end
            end
            
        case 'struct'
            
            nElements = prod(size(x)); % already assured that x & y same size
            
            xFldNames = sort( fieldnames( x ) );
            yFldNames = sort( fieldnames( y ) );
            if ~isempty( Opts.ignorefields )
                xFldNames = setdiff( xFldNames, Opts.ignorefields );
                yFldNames = setdiff( yFldNames, Opts.ignorefields );
                if isempty(xFldNames), warning('All fields of struct #1 are ignored!'); end
                if isempty(yFldNames), warning('All fields of struct #2 are ignored!'); end
            end
            inXnotInY = setdiff( xFldNames, yFldNames );
            inYnotInX = setdiff( yFldNames, xFldNames );
            isFieldsSame = isempty( inXnotInY ) & isempty( inYnotInX );
            if ~( isFieldsSame )
                if ~isempty( inXnotInY )
                    thisMsg = ['Struct ',xName,' has fields that are not in ',yName,':',...
                            sprintf(' ''%s''',inXnotInY{:}) ];
                    Opts = display_msg( Opts, thisMsg );
                end
                if ~isempty( inYnotInX )
                    thisMsg = ['Struct ',yName,' has fields that are not in ',xName,':',...
                            sprintf(' ''%s''',inYnotInX{:}) ];
                    Opts = display_msg( Opts, thisMsg );
                end
                Opts = display_msg( Opts, ['Structs ',xName,' and ',yName,' have different fields'] );
            end
            xySame = isFieldsSame & xySame;
            if ~isFieldsSame
                if ( Opts.fastfalse ), return; end
            end
            commonFldNames = intersect( xFldNames, yFldNames );
            for i = 1:length(commonFldNames)
                for j = 1:nElements
                    thisFld = commonFldNames{i};
                    if ( nElements > 1 )
                        thisXName = sprintf('%s(%d).%s',xName,j,thisFld);
                        thisYName = sprintf('%s(%d).%s',yName,j,thisFld);
                    else
                        thisXName = [xName,'.',thisFld];
                        thisYName = [yName,'.',thisFld];
                    end
                    [isValueSame,Opts] = is_equal( ...
                                            getfield( x(j), thisFld ), ...
                                            getfield( y(j), thisFld ), ...
                                            Opts, thisXName, thisYName );
                    xySame = isValueSame & xySame;
                    if ~isValueSame
                        if ( Opts.fastfalse ), return; end
                    end
                end
            end
            
        otherwise % try to use builtin ISEQUAL() routine
            
            try
                xySame = isequal( x, y );
            catch
                errMsg = [mfilename,' cannot handle objects of class ',...
                    '''',xClass,''' (',xName,' and/or ',yName,'), and ',...
                    ' calling builtin ISEQUAL() failed (laster = ',lasterr,')'];
                error( errMsg );
            end
            
    end

    
% If code reaches this point
% w/out returning, then x==y:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ( xySame )
        display_msg( Opts, [' ... ',xName,' is the same as ',yName] );
    end
    
    
return





function Opts = display_msg( Opts, msg )
    if ( nargout > 0 ), Opts.msg{end+1} = msg; end
    if not( Opts.verbose ), return; end
    disp( repmat('-',[1,50]) );
    disp( msg );
return    





function [isSame,x,y] = same_nans( x, y, ignoreNan )
% This routine not only checks for NaN equivalence, it also removes them so
% that subsequent numeric comparisons are not corrupted (which is why,
% incidentally, this routine is still called even when "ignoreNan" is true).
    true   = (1==1);
    false  = not(true);
    isSame = false; % initialize
    iXNan = isnan(x);
    iYNan = isnan(y);
    if any( iXNan ~= iYNan )
        if ( ignoreNan )
            % Remove points wherever *either* x or y are NaN
            iXNan = ( iXNan | iYNan );
            iYNan = iXNan;
        else
            return
        end
    end
    x(iXNan) = [];
    y(iYNan) = [];
    isSame = true;    
return





function [isSame,x,y] = same_infs( x, y )
% This is essentially identical to "same_nans" w/out an "ignore" option.
    true   = (1==1);
    false  = not(true);
    % Next line is an ad hoc fix for Matlab 6.5 glitch, related to fact that
    % Mathworks added the LOGICAL type in ver 6.5 but failed to define many
    % common routines for the LOGICAL type (FAIL!).
    if islogical(x) | islogical(y), isSame = true; return; end % <- 2005-04-08
    isSame = false; % initialize
    iXinf = isinf(x);
    iYinf = isinf(y);
    % Return false if any finite vs. inf mismatches
    if any( iXinf ~= iYinf ), return; end
    % ... otherwise, check that sign (+inf vs -inf) matches
    if any( sign(x(iXinf)) ~= sign(y(iYinf)) ), return; end
    % Remove 
    x(iXinf) = [];
    y(iYinf) = [];
    isSame = true;
return





function [isSame,x,y] = same_size( x, y, ignoreTranspose )
% As of 2012, ignoreTranspose is not just boolean (0|1) - it can take on three
% values:
%           0 -> return "false" for isSame if any dimensions disagree
%           1 -> return "false" ... *unless* they are equivalent row / column
%                versions of the same vector
%           2 -> return "false" ... *unless* they are 1-D or 2-D transposed
%                versions of the same array

    true   = (1==1);
    false  = not(true);
    
    xSize = size(x);
    ySize = size(y);
    
    areBothVectors = is_vector( x, '+ndim' ) & is_vector( y, '+ndim' );
    % USE: isVec = is_vector( x, ... ); % use with optional flags; see below
    % 
    % Unless the following flags are input, all of the following types of input 
    % "x" are treated as FALSE by default. Flags can be combined as multiple
    % inputs.
    % 
    % '+empty'  -> treat empty input (up to 2-dim) as true
    % '+scalar' -> treat scalar [1,1] as true
    % '+ndim'   -> treat multi-dim (n>2) with singletons as true (e.g., [1,1,8,1])
    
    differentDims = length(size(x)) ~= length(size(y));
    
    if ( differentDims )
        
        if ( areBothVectors ) & ( ignoreTranspose > 0 )
            isSame = ( max(size(x)) == max(size(y)) );
        else
            isSame = false;
        end
        
    else
    
        if all( xSize == ySize )
            isSame = true;
        elseif ( ignoreTranspose > 0 )
            if ( areBothVectors )
                isSame = ( max(size(x)) == max(size(y)) );
            elseif ( ignoreTranspose == 2 )
                % Backward-compatibility mode
                isSame = all( size(x) == size(y.') );
                if ( isSame ), y = y.'; end
            else
                isSame = false;
            end
        else
            isSame = false;
        end
        
    end
        
return





%function run_test
%
%    hMsgStart = helpdlg(['Running internal tests on ',mfilename,'.m, please',...
%        ' ignore all command-window messages and warnings.']);
%
%    true = (1==1);
%    false = not(true);
%
%    %    test name,         {options},              x,          y,          expected output
%    testInfoCellArray = {...
%        'case sensitive',   {'ignoreCase',0},       'Hi',       'hi',       false;...
%        'case insensitive', {'ignoreCase',1},       'Hi',       'hi',       true;...
%        'nans ignored',     {'ignoreNan',1},        [0,NaN],    [NaN,NaN],  true;...
%        'nans considered',  {'ignoreNan',0},        [0,NaN],    [NaN,NaN],  false;...
%        'abs tol true',     {'absoluteTol',0.1},    [0,0.1],    [0,0.01],   true;...
%        'abs tol false',    {'absoluteTol',0.08},   [0,0.1],    [0,0.01],   false;...
%        'rel tol true',     {'relativeTol',0.1},    9.1,        10,         true;...
%        'rel tol false',    {'relativeTol',0.09},   9.1,        10,         false;...
%        'mixed tol true',   {'absoluteTol',0,  'relativeTol',0.499,'requireBothTols',0}, 1.01, 2,   true;...
%        'mixed tol F (1)',  {'absoluteTol',0,  'relativeTol',0.499,'requireBothTols',1}, 1.01, 2,   false;...
%        'mixed tol F (2)',  {'absoluteTol',0.9,'relativeTol',0.4,  'requireBothTols',0}, 1.01, 2,   false;...
%        'x~=x.''',          {'ignoreTranspose',0}, [1,2,3], [1,2,3]',       false;...
%        'x==x.'' (vector1)',{'ignoreTranspose',1}, [1,2,3], [1,2,3]',       true;...
%        'x==x.'' (vectorN)',{'ignoreTranspose',1}, [1,2,3],  reshape([1,2,3],[1,1,1,3,1]), true;...
%        'x~=x.'' (array0)', {'ignoreTranspose',0}, [1,2,3;4,5,6], [1,2,3;4,5,6]', false;...
%        'x~=x.'' (array1)', {'ignoreTranspose',1}, [1,2,3;4,5,6], [1,2,3;4,5,6]', false;...
%        'x~=x.'' (array2)', {'ignoreTranspose',2}, [1,2,3;4,5,6], [1,2,3;4,5,6]', true;...
%        'different dims',   {},                    ones(2,3),      ones(2,3,4),   false;...
%        'mixed ints',       {'mixedIntClass',1}, ...
%                    {(0==1), uint8(1), int16(2), uint32(3),       4 },...
%                    { 0,     1,        uint32(2), int16(3), uint8(4)}, true;...
%        'mixed floats',     {'mixedFloatClass',1}, {single(1),double(1)},...
%                                                   {double(1),single(1)}, true;...
%        'mixed empty',      {'mixedEmptyClass',1}, {struct([]),{},[]},...
%                                                   {[],        [],{}},      true;...
%        'mixed ints (F)',   {'mixedIntClass',0},    uint8(1), (1==1),       false;...
%        'mixed floats (F)', {'mixedFloatClass',0},  single(1), double(1),   false;...
%        'mixed empty (F)',  {'mixedEmptyClass',0},  [],         {},         false };
%    
%    anyTestsFailed  = false;
%    failMsgs        = '';
%    
%    for iTest = 1:size(testInfoCellArray,1)
%        
%        for variant = [1:5]
%        % Variant 1 = 'verbose' off, 'fastFalse' off
%        %         2 = 'verbose' on,  'fastFalse' off
%        %         3 = 'verbose' off, nested cell/struct, 'fastFalse' off
%        %         4 = 'verbose' off, nested cell/struct, 'fastFalse' on
%        %         5 = same as 4 w/ extra field and 'ignoreFields' exercised
%        
%            testName = testInfoCellArray{iTest,1};
%            opts     = testInfoCellArray{iTest,2};
%            x1       = testInfoCellArray{iTest,3};
%            x2       = testInfoCellArray{iTest,4};
%            expected = testInfoCellArray{iTest,5};
%            
%            if variant == 2
%                opts = [opts, {'verbose',1}];
%            else
%                opts = [opts, {'verbose',0}];
%            end
%        
%            if variant == 4
%                opts = [opts, {'fastFalse',0}];
%            else
%                opts = [opts, {'fastFalse',1}];
%            end
%            
%            if variant > 2
%                Temp1 = struct('field1',x1,'field2',x1);
%                Temp2 = struct('field1',x2,'field2',x2);
%                if variant == 5
%                    try
%                        Temp2.field3 = 'blah';
%                        Temp2.field4 = 'blah';
%                        opts = [opts, {'ignoreFields',{'field3','field4'}}];
%                        % It worked
%                    catch
%                        % This will not always work. That is ok.
%                    end
%                end
%                x1 = {Temp1,Temp1}; x2 = {Temp2,Temp2};
%            end
%        
%            try
%                output = is_equal( x1, x2, opts{:} );
%                if output ~= expected
%                    anyTestsFailed  = true;
%                    failMsgs        = add_msg( failMsgs, ...
%                        sprintf('%s.m failed %s test, variant %d',...
%                                mfilename, testName, variant )        );
%                end
%            catch
%                    anyTestsFailed  = true;
%                    failMsgs        = add_msg( failMsgs, ...
%                        sprintf('%s.m threw error on %s test, variant %d (error = "%s")',...
%                                mfilename, testName, variant, lasterr )       );
%            end
%            
%        end
%        
%    end
%    
%    try, delete( hMsgStart ); end
%    
%    if ( anyTestsFailed )
%        error( failMsgs );
%    else
%        msgbox([' ... ',mfilename,'.m passed all internal tests!']);
%    end
%
%return