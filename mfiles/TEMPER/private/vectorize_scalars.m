function [varargout] = vectorize_scalars( varargin )
%vectorize_scalars - Given scalars & vectors, REPMAT's scalars to correct size.
%
% USE: [arg1,arg2,...] = vectorize_scalars( arg1, arg2, ... );
%
%   If an input is...   then this routine will return...
%       empty               empty
%       scalar              vector/array
%       vector/array        vector/array
%
% All vector/array inputs must be the same size, otherwise an error will be
% thrown. If all inputs are scalar and/or empty, the outputs will be exactly
% the same as the inputs.
%
% Last update: 2007-02-07

% Update list
% 2004-10-13 (JZG) ...
% 2007-01-18 (Kevin Norman) Wrote tester routine.
% 2007-02-07 (JZG) Added to tester routine.

    if ( nargin == 1 )
        if strcmpi( varargin{1}, '-test' ), run_test; return; end
    end

    outSize = [];
    for i = 1:length(varargin)
        argSize        = size(varargin{i});
        isArgEmpty(i)  = isempty(varargin{i});
        isArgScalar(i) = ( 1 == max(argSize) );
        if not(isArgEmpty(i)) & not(isArgScalar(i))
            if isempty(outSize)
                outSize = argSize;
            else
                if length(outSize) ~= length(argSize)
                    argName = inputname(i);
                    if isempty(argName), argName = ['arg #',int2str(i)]; end
                    error([argName,' has wrong # of dimensions']);
                elseif any( outSize ~= argSize )
                    argName = inputname(i);
                    if isempty(argName), argName = ['arg #',int2str(i)]; end
                    error([argName,' has wrong size']);
                end
            end
        end
    end

    if all( isArgEmpty | isArgScalar )
        varargout = varargin;
        return
    end
    
    for i = 1:length(varargin)
        if isArgScalar(i),  
            varargout{i} = repmat( varargin{i}, outSize );
        else
            varargout{i} = varargin{i};
        end
    end

return





%function run_test
%	
%    % All empty tests
%	[out1] = vectorize_scalars( [] );
%    if ~is_equal( out1, [] ), error('Failed empty input'); end
%    [out1, out2] = vectorize_scalars( [], [] );
%    if ~is_equal( out1, [] ) | ~is_equal( out2, [] )
%        error('Failed 2-empty input');
%    end
%        
%    % All scalar tests
%    in1 = 1;
%    in2 = 2;
%	[out1] = vectorize_scalars( in1 );
%    if ~is_equal( out1, in1 ), error('Failed scalar input'); end
%    [out1, out2] = vectorize_scalars( in1, in2 );
%    if ~is_equal( out1, in1 ) | ~is_equal( out2, in2 )
%        error('Failed 2-scalar input');
%    end
%    
%    % All vector tests
%    in1 = [1,2,3];
%    in2 = [0,1,2];
%	[out1] = vectorize_scalars( in1 );
%    if ~is_equal( out1, in1 ), error('Failed vector input'); end
%    [out1, out2] = vectorize_scalars( in1, in2 );
%    if ~is_equal( out1, in1 ) | ~is_equal( out2, in2 )
%        error('Failed 2-vector input');
%    end
%    
%    % All array tests
%    in1 = [1,2,3;4,5,6];
%    in2 = [0,1,2;1,0,1];
%	[out1] = vectorize_scalars( in1 );
%    if ~is_equal( out1, in1 ), error('Failed array input'); end
%    [out1, out2] = vectorize_scalars( in1, in2 );
%    if ~is_equal( out1, in1 ) | ~is_equal( out2, in2 )
%        error('Failed 2-array input');
%    end
%    
%    % Mixed empty / scalar / vector test
%	in1 = [];
%	in2 = 6;
%	in3 = ones(4,1);
%	[out1, out2, out3] = vectorize_scalars( in1, in2, in3 );
%    if ~is_equal( out1, [] )
%        error('Failed mixed input (empty->empty)');
%    elseif ~is_equal( out2, repmat(in2,size(in3)), 'ignoretranspose',1 )
%        error('Failed mixed input (scalar->vector)');
%    elseif ~is_equal( out3, in3,                   'ignoretranspose',1 )
%        error('Failed mixed input (vector->vector)');
%    end
%    
%    % ... expand on previous test - preservation of vector orientation
%	[out1T, out2T, out3T] = vectorize_scalars( in1, in2, in3.' );
%    if ~is_equal( out2, repmat(in2,size(in3)),        'ignoretranspose',0 )
%        error('Vector orientation not preserved (scalar->vectorT)');
%    elseif ~is_equal( out3, in3,                      'ignoretranspose',0 )
%        error('Vector orientation not preserved (vectorT->vectorT)');
%    elseif ~is_equal( out2T, repmat(in2,size(in3.')), 'ignoretranspose',0 )
%        error('Vector orientation not preserved (scalar->vectorT)');
%    elseif ~is_equal( out3T, in3.',                   'ignoretranspose',0 )
%        error('Vector orientation not preserved (vectorT->vectorT)');
%    end
%    
%    % Mixed input w/ arrays
%	in1 = [];
%	in2 = 6;
%	in3 = ones(4,5);
%	[out1, out2, out3] = vectorize_scalars( in1, in2, in3 );
%    if ~is_equal( out1, [] )
%        error('Failed mixed input (empty->empty)');
%    elseif ~is_equal( out2, repmat(in2,size(in3)), 'ignoretranspose',0 )
%        error('Failed mixed input (scalar->array)');
%    elseif ~is_equal( out3, in3,                   'ignoretranspose',0 )
%        error('Failed mixed input (array->array)');
%    end
%    
%    disp([mfilename,' passed all internal tests']);
%
%return