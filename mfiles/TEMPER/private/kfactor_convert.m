function xOut = kfactor_convert( xIn, inType, outType, hUnits, ae )
%kfactor_convert - Converts among dNdh, dMdh, k & roc (ray radius of curvature).
%
% USE: xOut = kfactor_convert( xIn, inType, outType, hUnits, ae );
%
%   xIn/Out - Input/output quantities.
%   inType  - Type of input ('dNdh','dMdh','k' or 'roc') - case insensitive.
%   outType - Desired output type.
%   hUnits  - Height units for input/output.
%   ae (optional) - Earth radius, in units of "hUnits".
%
% Note that normal gradient inputs will be NEGATIVE, despite the fact that some
% literature lists "delta N" around the world using positive values.  E.g. Bean
% et. al. 1966 displays world charts of average "delta N" and "lapse rate" over
% the first 1 km above the surface, however they've defined their quantities in
% a manner such that positive values read off their figures must go into this
% routine as a NEGATIVE numbers, otherwise results will be incorrect!
%
% Also note that conversions assume h = 0. In general the conversion between dM 
% & dN is height dependent. See comments in convert_ref_gradient.m, and use that
% routine to convert between dM/dh and dN/dh rather than 
%
%
% (c)2006-2016, Johns Hopkins University / Applied Physics Lab
% Last update: 2016-01-20


% Update list: (all JZG unless otherwise noted)
% -----------
% 2006-05-17 - added 'dMdh' input option.
% 2006-07-17 - fixed a few bugs (k->roc for k=1 & inf, dmdh<->dndh, added
% "run_test" subroutine.
% 2006-07-26 - added 'dMdh' output option, updated test accordingly.
% 2006-11-15 - RESHAPE to preserve row/column orientation of in/output
% 2008-03-03 - added vector & array I/O checks to "run_test", changed trigger
% from empty to '-test' input, fixed error that occured when vector or array
% input had one or more k==inf entries.
% 2013-09-05 - added "ae" input
% 2014-04-07 - corrected typo (Input->Output) in error message.
% 2016-01-20 - no longer throws error if dz used instead of dh, e.g., 'dMdz'


    if ( nargin == 1 )
        if strcmpi( xIn, '-test' ), run_test; return; end % <- test mode trigger & exit-point
    end
    
    if ( nargin < 4 ), error('At least 4 inputs required'); end
    if ( nargin < 5 ), ae = []; end

    inType  = lower(inType);
    outType = lower(outType);
    
    % Added 2016-01-20, allow 'dz' inputs as well as 'dh'
    inType  = strrep(inType, 'dz','dh');
    outType = strrep(outType,'dz','dh');
    
    validTypes = lower({'k','roc','dndh','dmdh'});

    if ~ismember(inType,validTypes)
        error(['Input type must be one of the following: ',...
               sprintf('''%s'' ',validTypes{:})]);
    elseif ~ismember(outType,validTypes)
        error(['Output type must be one of the following: ',...
               sprintf('''%s'' ',validTypes{:})]);
    end
    
    % Added 2006-05-17 to handle new 'dMdh' functionality; updated 2006-07-26
    isDmDhOutput = 0;
    if strcmpi(inType,'dmdh') & ~strcmpi(outType,'dmdh')
        xIn    = convert_ref_gradient(xIn,['M/',hUnits],['N/',hUnits], 0,hUnits, ae);
        inType = 'dndh';
    elseif strcmpi(outType,'dmdh') & ~strcmpi( inType, 'dmdh' )
        % Code will compute dN/dh, then special "isDmDhOutput" flag will trigger
        % conversion to dM/dh before output:
        isDmDhOutput = 1;
        outType = 'dndh';
    end
    
    % Handle trivial case of inType == outType, as well as the dN/dh -> dM/dh
    % (effectively uses this routine as a wrapper for CONVERT_REF_GRADIENT).
    if strcmp(inType,outType)
        if ( isDmDhOutput ) % dN/dh -> dM/dh
            xOut = convert_ref_gradient( xIn, ['N/',hUnits], ['M/',hUnits], 0,hUnits, ae );
        else                % inType == outType
            xOut = xIn;
        end
        return
    end
    
    if isempty( ae )
        ae = earth_radius(hUnits);
    end
    
    % Note: equation #'s below refer to Sept '99 ed. of Julius Goldhirsh's
    % course notes for "Propagation of Radio Waves in the Atmosphere".
    
    % For more-clearly readable code, transfer input "xIn" to a variable that's
    % named appropriately (either "k", "roc" or "dndh").  A similar EVAL will
    % be execuated *after* the main SWITCH block to assign a value to "xOut".
    eval([inType,' = xIn;']);
    
    switchFlag = [inType,'2',outType];
    
    switch( switchFlag )
        
        case 'dndh2roc', roc        = -1e6./dndh; % eqn. 9.21
            
        case 'roc2dndh', dndh       = -1e6./roc;
            
        case 'roc2k',    [roc,ae]    = vectorize_scalars(roc,ae);
                         isKInf      = ( roc == ae  );
                         isKOne      = isinf( roc );
                         isOk        = not(isKInf) & not(isKOne);
                         k(isKInf)   = inf;
                         k(isKOne)   = 1;
                         k(isOk)     = roc(isOk) ./ ( roc(isOk) - ae(isOk) ); % eqn. 9.26
                         
        case 'k2roc',    [k,ae]      = vectorize_scalars(k,ae);
                         isKInf      = isinf( k );
                         isKOne      = ( k == 1 );
                         isOk        = not(isKInf) & not(isKOne);
                         roc(isKInf) = ae(isKInf);
                         roc(isKOne) = inf;
                         roc(isOk)   = ( k(isOk) ./ ( k(isOk) - 1 ) ).*ae(isOk); % eqn. 9.27
                         
        case 'k2dndh'
            roc  = kfactor_convert( k,   'k',   'roc',  hUnits, ae );
            dndh = kfactor_convert( roc, 'roc', 'dndh', hUnits, ae );
            
        case 'dndh2k'
            roc = kfactor_convert( dndh, 'dndh', 'roc', hUnits, ae );
            k   = kfactor_convert( roc,  'roc',  'k',   hUnits, ae );
            
        otherwise
            error('Internal code error occured - unrecognized SWITCH');
            
    end
      
    % See comment on EVAL cmd above SWITCH block for more info ...
    eval(['xOut = ',outType,';']);
    
    if ( isDmDhOutput )
        % First, a redundant error check, just to be safe...
        if ~strcmpi(outType,'dndh'), error('Code glitch detected!'); end
        % ... then convert dN/dh to dM/dh for output:
%        warning(['output dM/dh only accurate for small h (',mfilename,'.m)']);
        xOut = convert_ref_gradient( xOut, ['N/',hUnits], ['M/',hUnits], 0,hUnits, ae );
    end
    
    % Make sure row/column orientation of input vectors is preserved on output:
    xOut = reshape( xOut, size(xIn) );

%  dN
%  --  =  - (10^6) * (k - 1) / (ae * k)     in [N/m]
%  dh
%                     1
%  k   =  --------------------------
%         1 - ( ae / 10^6 )*(dN/dh)
%
%            (ae = radius of earth in meters)
%
%  N = Ns + dNdH.*h        h in [m]
%            (Ns = N at surface)

return




%function run_test
%
%    hUnits = 'm';
%    ae = 6371000; % must be in "hUnits" for test to work
%
%    disp(['Running internal accuracy tests on ',mfilename,'.m ...']);
%    
%    % Each row should contain physically-equivalent values, expressed in a
%    % different "unit" for each column. Consequently, excluding the first row
%    % (header), there will be (#rows-1) tests run by the code below.
%    testTable = {...
%            'k',     'roc',    'dndh',  'dmdh';...
%            1,       Inf,       0,      1e6/ae;...
%            4/3,     25580000, -0.0389, 0.1181;...
%            Inf,     ae,       -1e6/ae, 0          };
%    
%    [m,n] = size(testTable);
%    
%    errMsg = '';
%    anyFailed = 0;
%    
%    warning off;
%    
%    for iTest = 2:m
%        
%        for jFrom = 1:n
%          for jTo = 1:n
%              
%            for vectorTest = [0,1,2,3,4]
%            
%                xIn          = testTable{iTest,jFrom};
%                fromUnit     = testTable{1,jFrom};
%                toUnit       = testTable{1,jTo};
%                xOutExpected = testTable{iTest,jTo};
%                
%                switch vectorTest
%                    case 0,     repSize = [0,0];    vectorStr = 'empty';
%                    case 1,     repSize = [1,1];    vectorStr = 'scalar';
%                    case 2,     repSize = [1,3];    vectorStr = 'row vector';
%                    case 3,     repSize = [3,1];    vectorStr = 'col vector';
%                    case 4,     repSize = [3,4];    vectorStr = 'array';
%                end
%                xIn          = repmat( xIn,          repSize );
%                xOutExpected = repmat( xOutExpected, repSize );
%                
%                try
%                    xOut = kfactor_convert( xIn, fromUnit, toUnit, hUnits, ae );
%                catch
%                    xOut = lasterr;
%                end
%
%                % Special handling for the fact that -Inf/+Inf are identical for
%                % a k-factor calculation:
%                iInf = find( isinf(xOut) );
%                xOut(iInf) = Inf; % effectively replaces -Inf's with +Inf's
%                
%                % Test fails if off by more than 1% (0.01 relative tolerance)
%                thisFailed = ~is_equal( xOut, xOutExpected, 'tolerance',0.01, ...
%                    'ignoreNan',0, 'ignoreTranspose',0 );
%                if ( thisFailed ), anyFailed = 1; end
%                
%                if ( thisFailed )
%                    thisMsg = sprintf( 'Test #%d of %d failed! (''%s''->''%s'' with %s I/O)',...
%                        iTest-1, m-1, fromUnit, toUnit, vectorStr );
%                    if ischar(xOut), thisMsg = [thisMsg,' LASTERR = ',xOut]; end
%                    errMsg = add_msg( errMsg, thisMsg );
%                end
%            
%            end
%            
%          end
%        end
%        
%    end
%
%    warning on;
%    
%    if ( anyFailed )
%        disp( errMsg );
%        error([mfilename,' failed one or more internal tests!']);
%    else
%        disp(['... ',mfilename,'.m passed all internal tests']);
%    end
%    
%return