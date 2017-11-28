function s1 = rem_adjdups( s1, s2 )
%rem_adjdups - Uses STRREP to remove adjacent duplicate substrings.
%
% USE: s1 = rem_adjdups( s1, s2 )
%
%   Input "s1" is a single string, a character array or a cellstr.  Upon output,
%   all adjacent duplicates of the "s2" string have been removed.  Note that
%   function is *not* case sensitive.
%
% EXAMPLE:
%   rem_adjdups( 'a___b_____c__', '_' ) % output is 'a_b_c_'
%
% Last update: 2007-01-24

% 2006-04-04 (JZG)
% 2007-01-18 (Kevin Norman) Wrote tester routine.  Test passed.
% 2007-01-24 (JZG) Added to tester routine, fixed several errors caught by new 
% tests (nMaxLoops wasn't being computed correctly for empty s1 and for certain
% cellstrings, and certain elements of cellstr arrays were always mishandled).


    if ( nargin == 1 ) & strcmp(s1,'-test')
        run_test;
        return
    end
    
    if ( nargin ~= 2 ), error('Incorrect # of inputs'); end
    
    if ( isempty(s1) | isempty(s2) ), return; end

    s3 = s2;
    s2 = [s2,s2];

    isCharIn = ischar(s1);
    if ( isCharIn ), s1 = cellstr(s1); end

    iMod = 1:prod(size(s1));

    % Determine the longest input string
    for i = iMod, lenStr(i) = length(s1{i}); end
    lenStrMax = max(lenStr);
    
    % Determine the most loops required, assuming that every possible duplicate
    % is present in the longest string:
    nMaxLoops = ceil( lenStrMax + 1 / length(s2) ) + 1;
    
    for nLoops = 1:nMaxLoops
        
        s1PreRep = s1;
        
        s1(iMod) = strrep( s1(iMod), s2, s3 );
        
        iMod = find( ~strcmp(s1,s1PreRep) );
        
        if isempty(iMod), break; end
        
    end

    if ( nLoops == nMaxLoops )
        error('S2/S3 inputs lead to infinite looping!');
        %disp('nLoops = maxLoops')
    end
    
    if ( isCharIn ), s1 = char(s1); end
    
return





%function run_test
%    
%    inStr  = 'kevinkevinkevinnorman';
%    dupStr = 'kevin';
%    outStr = rem_adjdups(inStr,dupStr);
%    if iscell(outStr), error('Cellstr output for char input'); end
%    if ~strcmp(outStr,'kevinnorman'), error('Incorrect output'); end
%        
%    % Test that 1-element cellstrings are handled correctly
%    inStr  = {inStr};
%    outStr = rem_adjdups(inStr,dupStr);
%    if ~iscell(outStr), error('Cellstr input didn''t produce cellstr out'); end
%    if ~strcmp(outStr{1},'kevinnorman'), error('Incorrect output (cell)'); end
%    
%    % Test mulitple-element cellstrings
%    inStr(2) = inStr(1);
%    outStr = rem_adjdups(inStr,dupStr);
%    if any( size(inStr) ~= size(outStr) ), error('Incorrect size (cell)'); end
%    for i = 1:prod(size(outStr))
%        if ~strcmp(outStr{i},'kevinnorman'), error('Incorrect output (cells)'); end
%    end
%    
%    % Test a few more oddball cases ...
%    
%    % ... both inputs empty
%    outStr = rem_adjdups('','');
%    if ~isempty(outStr), error('Non-empty output for 2 empty inputs'); end
%    % ... empty s1, non-empty s2
%    outStr = rem_adjdups('','x');
%    if ~isempty(outStr), error('Non-empty output for empty input #1'); end
%    % ... empty cellstr
%    outStr = rem_adjdups({''},'x');
%    if isempty(outStr), error('Returns [] instead of {''''}'); end
%    if ~isempty(outStr{1}), error('Non-empty output for empty cellstr'); end
%    
%    % ... empty s2, non-empty s1
%    outStr = rem_adjdups('x','');
%    if ~strcmp(outStr,'x'), error('Incorrect for empty input #2'); end
%    
%    % ... all duplicates
%    outStr = rem_adjdups('xxxx','x');
%    if ~strcmp(outStr,'x'), error('Incorrect for all-duplicates'); end
%    % ... s1 ~ s2
%    outStr = rem_adjdups('xxxx','xx');
%    if ~strcmp(outStr,'xx'), error('Incorrect for  s1 ~ s2'); end
%    % ... s1 == s2
%    outStr = rem_adjdups('xxxx','xxxx');
%    if ~strcmp(outStr,'xxxx'), error('Incorrect for s1 == s2'); end
%    % ... s1 > s2
%    outStr = rem_adjdups('xxxx','xxxxx');
%    if ~strcmp(outStr,'xxxx'), error('Incorrect for s2 longer than s1'); end
%    
%    % ... all duplicates in a row-oriented cellstr vector
%    outStr = rem_adjdups({'xxx','xxx','xxx'},'x');
%    if any( size(outStr) ~= [1,3] ), error('Incorrect size (row vector)'); end
%    for i = 1:prod(size(outStr))
%        if ~strcmp(outStr{i},'x'), error('Fails for replace-all row vector'); end
%    end
%    % ... all duplicates in a col-oriented cellstr vector
%    outStr = rem_adjdups({'xxx';'xxx';'xxx'},'x');
%    if any( size(outStr) ~= [3,1] ), error('Incorrect size (col vector)'); end
%    for i = 1:prod(size(outStr))
%        if ~strcmp(outStr{i},'x'), error('Fails for replace-all col vector'); end
%    end
%    % ... all duplicates in a cellstr array
%    outStr = rem_adjdups({'xxx','xxx','xxx';'xxx','xxx','xxx'},'x');
%    if any( size(outStr) ~= [2,3] ), error('Incorrect size (cell array)'); end
%    for i = 1:prod(size(outStr))
%        if ~strcmp(outStr{i},'x'), error('Fails for replace-all cell array'); end
%    end
%    
%    disp([mfilename,' passed all internal test']);
%    
%return