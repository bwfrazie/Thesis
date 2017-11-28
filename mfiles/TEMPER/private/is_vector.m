function isVec = is_vector( x, varargin )
%is_vector - Returns 1 if input is a non-empty vector w/ length > 1.
%
% USE: isVec = is_vector( x )
%
%   True if input is a non-empty vector w/ length > 1.
%
%
% USE: isVec = is_vector( x, ... ); % use with optional flags; see below
%
%   Unless the following flags are input, all of the following types of input 
%   "x" are treated as FALSE by default. Flags can be combined as multiple
%   inputs.
%
%   '+empty'  -> treat empty input (up to 2-dim) as true
%   '+scalar' -> treat scalar [1,1] as true
%   '+ndim'   -> treat multi-dim (n>2) with singletons as true (e.g., [1,1,8,1])
%
%   Note that '+empty' will still treat scalar inputs as FALSE. To include both
%   empty and scalar input as true, you must input '+empty' *and* '+scalar', and
%   to ensure that multi-dimension empty & scalar inputs are handled as TRUE,
%   you must input all *three* flags explicitly.
%
%
% EXAMPLES:
%
%   E  = [];            % Empty array
%   En = zeros(0,0,0);  % Multi-dim empty array
%   S  = 1;             % Scalar
%   Sn = ones(1,1,1);   % Scalar with extra singletons
%   V  = rand(1,3);     % Cannonical vector
%   Vn = rand(1,1,3);   % Vector with extra singletons
%
%   % In default mode, output will be false (0) for all but vector "V"
%   [ is_vector( E ), is_vector( En ); ...
%     is_vector( S ), is_vector( Sn ); ...
%     is_vector( V ), is_vector( Vn )  ]
%   
%   % Adding the '+scalar' flag emulates builtin ISVECTOR routine, added to
%   % Matlab at ver 7.0. % Output will be [ 0,0; 1,1; 1,0 ]
%   [ is_vector( E, '+scalar' ), is_vector( En, '+scalar' ); ...
%     is_vector( S, '+scalar' ), is_vector( Sn, '+scalar' ); ...
%     is_vector( V, '+scalar' ), is_vector( Vn, '+scalar' )  ]
%
%   % Add all flags to return true (1) for everything except actual 2+ dimension
%   % matrices, even when extra singleton dimensions are involved.
%   args = {'+scalar', '+empty', '+ndim'};
%   [ is_vector( E, args{:} ), is_vector( En, args{:} ); ...
%     is_vector( S, args{:} ), is_vector( Sn, args{:} ); ...
%     is_vector( V, args{:} ), is_vector( Vn, args{:} )  ]
%
%
% Last update: 2008-11-04


% Update list:
% -----------
% 2005-09-08 ?
% 2008-11-04 Added option flags & unit test


    if ischar(x)
        if strcmpi(x,'-test'), run_test; return; end
    end

    [isScalarOk,isEmptyOk,isNdimOk] = parse_flag( varargin );

    if not( isNdimOk )
        isVec = ( ndims(x) <= 2 );
    else
        isVec = 1; % additional checks will be applied below ...
    end
    
    if isEmptyOk && isempty(x)
        return
    end
    
    xSize = size(x);

    if isScalarOk && ( max(xSize) == 1 )
        return
    end
    
    isVec = isVec && ( count(xSize>1) == 1 );
        
return





function [isScalarOk,isEmptyOk,isNdimOk] = parse_flag( flagArgs )
    
    % Set default values - DO NOT CHANGE to maintain backward compatability with
    % older versions of this routine! Note that Matlab's new builtin "isvector"
    % routine could be emulated by changing both values to true.
    isEmptyOk  = 0;
    isScalarOk = 0;
    isNdimOk   = 0;

    if isempty(flagArgs), return; end
    if ischar(flagArgs), flagArgs = {flagArgs}; end

    for i = 1:length(flagArgs)
        switch lower(flagArgs{i})
            case '+empty',  isEmptyOk  = 1;
            case '+scalar', isScalarOk = 1;
            case '+ndim',   isNdimOk   = 1;
            otherwise, error('Bad flag input; should be ''+scalar'', ''+empty'' or ''+ndim''');
        end
    end
    
return





%function run_test
%
%    %              expected outcomes for flag == ...
%    %   size       (none) '+empty' '+scalar'
%    %               *1,*N   *1,*N  *1,*N     <- *1 = w/o '+ndim', *N = with
%    %               
%    testSetup = {...
%        [0,0],      0, 0,   1, 1,   0, 0; ...
%        [0,0,0],    0, 0,   0, 1,   0, 0; ...
%        [1,1],      0, 0,   0, 0,   1, 1; ...
%        [1,3],      1, 1,   1, 1,   1, 1; ...
%        [3,1],      1, 1,   1, 1,   1, 1; ...
%        [1,1,3],    0, 1,   0, 1,   0, 1; ...
%        [3,3],      0, 0,   0, 0,   0, 0; ...
%        [3,3,3],    0, 0,   0, 0,   0, 0; ...
%        [0,3,0,3],  0, 0,   0, 1,   0, 0; ...
%        [3,0,3],    0, 0,   0, 1,   0, 0; ...
%        [1,1,3,3],  0, 0,   0, 0,   0, 0 };
%    
%    % NOTE: any tests that specify a trailing singleton dimension will *FAIL*,
%    % not because the code is broken, but because Matlab routines such as ONES,
%    % ZEROS, and REPMAT trim off trailing singleton inputs when creating the
%    % input matrix "x"!
%    
%    testSizes = testSetup(:,1);
%    expected  = cell2num( testSetup(:,2:end) );
%    clear('testSetup');
%    
%    disp(['Running internal unit tests on ',mfilename,'.m ...']);
%    
%    for iTest = 1:length(testSizes)
%        
%        x = rand( testSizes{iTest} );
%        if length(size(x)) ~= length(testSizes{iTest})
%            dbstop if error;
%            error('Matlab failed to create the correct size matrix - stopping in debugger');
%        end
%        
%        for jVariant = 1:size(expected,2)
%            
%            argList = {x};
%            
%            switch jVariant
%                case {3,4}, argList{end+1} = '+empty';
%                case {5,6}, argList{end+1} = '+scalar';
%            end
%            if any( jVariant == [2,4,6] ), argList{end+1} = '+ndim'; end
%            
%            output = is_vector( argList{:} );
%            
%            output = double(output); % Handle Matlab logical-type annoyance
%            
%            thisFailed = ( output ~= expected(iTest,jVariant) );
%            
%            if ( thisFailed )
%                disp('-------------------------------------------------------');
%                disp([mfilename,' failed for the following input list:']);
%                argList{:}
%                disp(sprintf('Output value = %d, expected %d',output,expected(iTest,jVariant)));
%                disp('-------------------------------------------------------');
%            end
%            
%            testFailed(iTest,jVariant) = thisFailed;
%            
%        end
%        
%    end
%    
%    if any( [testFailed(:)] )
%        disp('FAIL MATRIX:');
%        disp( num2str( testFailed, '%d %d   ' ) );
%        error(upper(['>> ',mfilename,'.m failed one or more tests!!! <<']));
%    else
%        disp([' ... ',mfilename,'.m passed all internal tests.']);
%    end
%    
%return    