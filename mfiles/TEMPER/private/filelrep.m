function out = filelrep( replaceThis, withThis, line, files )
%filelrep - STRREP on a given line in multiple text files w/ similar format.
%
%   WARNING: This function is dated and not very efficient. It is still useful
%   as a stand-alone tool in certain situations, however avoid coding to it as a
%   dependency if possible in new functions.
%
%
% USE: [Undo] = filelrep( replaceThis, withThis, [line], [files] );
%
% INPUT:
%
%   replaceThis* - If not empty, a string passed as "S2" into to builtin STRREP.
%            If empty, it signals that the entire "line" should be overwritten.
%   withThis*  - If replaceThis is not empty, a string passed as "S3" input 
%            to STRREP. Otherwise this string overwrites the text currently
%            at "line".
%   line     - (optional, integer) Line number within files to affect.  Can only 
%            modify one line at a time with current function.  Value is
%            qraphically selected if empty or not specified.
%   files    - (optional, cell) Cell array of filenames to act on.
%
%   * PASS EMPTY STRINGS FOR BOTH ARGUMENTS TO DELETE THE LINE ENTIRELY.
%   E.g., filelrep( '', '', 10, files ) % <- removes line #10 from file
%
%
% EXAMPLES: 
%
%   % This will prompt user for all inputs
%   files = uigetfnames('*.in');
%   filelrep( [], [], [], files );
%
%   % Sets a batch of TEMPER input files to vertical polarization:
%   filelrep( '' , '0  Polarization flag [0=vertical|1=horizontal]', 12, files )
%
%
% (c)2000-2016, Johns Hopkins University / Applied Physics Lab
% Last Update: 2016-08-19


% Update List: (all JZG unless noted)
% -----------
% 2007-07-27 - ... older revisions removed from list
% 2008-03-04 - Removed all DISP()'s when 1 output arg, removed built_in_gui()
% subroutine (don't need an alternative to UIGETFNAMES) & refactored slightly,
% but it's still a big 'ole mess.
% 2012-02-23 - Adapted to new fileparts behavior (no "ver" output).
% 2015-02-23 - Removed dependence on uigetfnames to make function more portable.
% 2015-05-18 - No functional changes, just updated header comments.
% 2015-09-09 - Updated error message for empty files input.
% 2016-01-21 - Error message now more helpful for 1 input. Added header warning.
% Also caught the error that occurs if user cancels in uigetline subroutine.
% 2016-02-22 - Bug fix to get (replaceThis, withThis, []) convention working.
% 2016-08-19 - Fixed bug (error if replacing 1st line in file without any CRs).
% Added error when requested line > EOF. Removed 'slow' mode entirely. Cleaned
% up header and code. Made more robust to errors in-loop, can now still undo.


% TODO: remove this function from the repository, after back-filling any
% functions that depend on it.

    
    if ( nargin == 1 )
        
        % --- start undo -------------------------------------------------------
        
        Undo = varargin{1};
        
        if ~isstruct(Undo)
            error(sprintf('%s\n',...
             'When 1 input arg it must be an "Undo" structure',...
             'If you want to provide an input file list, use the following:',...
            [' >> ',mfilename,'([],[],[],fileList);']));
        end
        
        disp('Attempting to undo previous filename modifications ...');
        try
            undo_fast(Undo.undotxt,Undo.files);
            out = 'undo successful';
            return % <------------------ exit point for undo mode
        catch
            error(['Undo structure failed: ',lasterr])
        end
        
        % --- end undo --------------------------------------------------------

    end
    
    if ( nargin == 0 )
        error('Invalid call, must have 1 or more input args');
    elseif ( nargin == 5 )
        error('The mode input (#5) has been removed. Please update your code');
    elseif ( nargin > 5 )
        error('Too many input arguments');
    end
        
    if ( nargin < 3 )
        line = []; % empty triggers default
    end
    
    if ( nargin < 4 )
        files = {}; % empty triggers default
    end
    
    if isempty(files)
        if exist('uigetfnames','file')
            msg = ['uigetfnames as a dependency was removed to make ',...
                mfilename,'.m more portable',sprintf('\n'),...
                'Run this instead >> ',mfilename,'([],[],[],uigetfnames)'];
        else
            msg = 'Please input a none-empty value for "files"';
        end
        error(msg);
        % Note: removal of dependency was done b/c this file is now part of
        % TEMPER mfiles set, by way of getset_temper_input.m.
        %PRE: files = uigetfnames('*.in, *.cmi');
        %PRE: if isempty(files), return; end
    end
    
    if ischar(files)
        files = cellstr(files);
    end
    
    if isempty(line)
        % Added the second condition 2005-02-23 so that a list of files can be
        % input w/ empty 1st, 2nd & 3rd args:
        if ( nargin < 2 ) | ...
           ( isempty(replaceThis) & isempty(withThis) & isempty(line) & nargin==4 )
            [line, replaceThis, withThis] = uigetlines(files{1});
        else
            line = uigetlines(files{1});
        end
        if isempty(line)
            return % user canceled
        end
    end
    
    % Replace text
    
    % Initialize prior to loop over files
    undotxt        = cell(size(files)); 
    wasError       = 0;
    caughtErrorMsg = '';
    
    for i = 1:length(files)
        
        try
            undotxt{i}  = linrep_fast( files{i}, line, replaceThis, withThis );
        catch
            wasError       = 1;
            caughtErrorMsg = lasterr;
            files          = files(1:i-1);   % trim off files not yet modified
            undotxt        = undotxt(1:i-1);
            break
        end
        
    end
    
    % Set "undo" output
    out.files   = files;
    out.undotxt = undotxt;
    
    % If either no output argument or an error occurred, make sure that the user
    % can still undo the modifications by assigning a variable in the top-level
    % (base) workspace:
    if ( nargout == 0 ) | ( wasError )
        
        assignin('base','Undo',out);
        
        msg = sprintf('%s\n',...
            ['modified ' int2str(length(files)) ' files,'],...
            ['use this command to undo any modifications >> filelrep(Undo)'] );
        
        if ( wasError )
            msg = ['An error occurred after this function had ',msg];
            if isempty(caughtErrorMsg)
                msg = [msg,'Matlab did not generate an error message'];
            else
                msg = [msg,'The error message was: ',caughtErrorMsg];
            end
            error( msg );
        else
            disp( msg );
        end
        
    end
                
return





% function tmpfile = linrep_slow(file , line , replaceThis , withThis)
% % Creates a temporary file, then reads from that file and copies to the original
% % file, modifying text at specified "line" in file.  See "get_new_line"
% % subfunction for more info.
% 
%     [pth fil ext] = fileparts(file);    % derive temp filename from current filename
%     tmpfile = [pth '\' fil '.tmp'];     % change extension to ".tmp'
%     eval(['!copy ' file ' ' tmpfile]);  % now 2 files - old (.tmp) & new (unchanged)
%     
%     fid_in = fopen(tmpfile,'rt');       % open old file for reading
%     fid_out= fopen(   file,'wt');       % open new file for writing
%     
%     for j = 1:line-1    % read in all lines preceding line of interest ...
%         fprintf(fid_out,'%s',fgets(fid_in));% ... sequentially printing them to new file
%     end
%     
%     % Get line of interest from old file (include CR)
%     oldLine = fgets(fid_in);
%     
%     % mid-i/o, write new line to new file ...
%     fprintf(fid_out,'%s',get_new_line(oldLine,replaceThis,withThis)); % don't add a CR anymore (PRE: '%s\n')
%     
%     % Use loop to copy rest of text from old file to new file:
%     thisline = fgets(fid_in);
%     while not(isnumeric(thisline))      % (NOTE - fgets returns -1 for EOF)
%         fprintf(fid_out,'%s',thisline);
%         thisline = fgets(fid_in);
%     end
%     
%     fclose(fid_in);                     % close files before returning
%     fclose(fid_out);   
%     
% return





function oldtext = linrep_fast( file, line, replaceThis, withThis )
% Returns un-modified contents of file for undo purposes ONLY IF one explicit
% output arg. See "get_new_line" subfunction for more info.

    % open file for reading
    fid = fopen(file,'rt');               
    
    % read in all lines
    temp = fscanf(fid,'%c',inf);         

    % return the OLD text-contents for UNDO purposes
    oldtext = temp; 
    
    % close the file temporarily
    fclose(fid);                          
    
    % find all the carriage-return characters
    CR = findstr(temp,sprintf('\n'));     
    
    % now line #N of "files{i}" is contained between index CR(N-1) and CR(N)
    if line == 1 
            
        % First line is requested
        if isempty(CR) 
            % Added 2016-08-18
            oldLine = temp;
            theRest = '';
        else
            oldLine = temp( 1 : CR(1) );   % include line's CR
            theRest = temp( CR(1)+1 :end); % don't include that CR here
        end
        temp = [ get_new_line( oldLine, replaceThis, withThis ), theRest ];
        
    elseif line == ( length(CR) + 1 )
            
        % Last line requested & doesn't terminate with carriage-return
        oldLine = temp( (CR(end) + 1) : end );
        temp = [ temp(1:CR(end)) ...
                 get_new_line( oldLine, replaceThis, withThis ) ];

    elseif line >  ( length(CR) + 1 )
        
        % Line requested is beyond length of file
        error(sprintf('Line #%s is beyond the EOF for "%s"',line,file));
        
    else
            
        % Neither the 1st nor last line requested (i.e., typical case)
        oldLine = temp( (CR(line-1) + 1) : CR(line) ); %(include line's CR)
        temp = [ temp(1:CR(line-1))    ...
                 get_new_line( oldLine, replaceThis, withThis ) ...
                 temp( CR(line)+1 :end) ]; %(don't include that CR here)
            
    end
    
    fid2 = fopen(file,'wt'); % re-open same file
    
    if ( fid2 == -1 )
        error([file,...
            ' could not be altered - possibly write protected, or disk full?']);
    end
    
    % Blast the whole text array into same file (overwrite):
    fprintf(fid2,'%s',temp); 
    
    fclose(fid2);
    
return





function out = get_new_line(oldLine,replaceThis,withThis)
% If "replaceThis" is empty, function's action is to replace "oldLine" with
% "withThis". Otherwise, function performs strrep( ..., replaceThis, withThis),
% where ... will be text at specified line # in the file (as read by the calling
% function).
%
% NOTE THAT "oldLine" INPUT IS ASSUMED TO INCLUDE A LINE-RETURN CHARACTER


    switch isempty(replaceThis) * ( 1 + isempty(withThis) )
        
        case 0 
            % replaceThis IS NOT EMPTY -> withThis CAN BE EMPTY OR SPECIFIED.
            % Assume user wants to replace the specified string with empty or
            % specified "withThis".
            out = strrep(oldLine,replaceThis,withThis);
            
        case 1 
            % replaceThis IS EMPTY, BUT withThis IS NOT EMPTY. Assume user does
            % not need old line - just wants to stick in non-empty "withThis".
            out = [withThis sprintf('\n')]; 
            
        case 2 
            % NEITHER replaceThis NOR withThis ARE EMPTY. No text specified.
            % Assume user just wants to rid file of this line completely.
            out = [];
            
        % TODO: otherwise? throw error?
            
    end  
    
return





function undo_fast(oldtext , files) 
% Input matching cells of old text - filenames. Writes the old text to files,
% thereby undo-ing previous command

    for i = 1:length(files)
        fid = fopen(files{i},'wt');
        fprintf(fid,'%s',oldtext{i});
        fclose(fid);
    end
    
return





function [lines,replaceThis,withThis] = uigetlines( file )
% This function sends the contents of a text file to a LISTDLG window and allows
% the user to click on the line they want to select.  The selected line numbers
% are returned

    lines = [];    

    maxLines = 1000;

    txt = {};
    fid = fopen(file,'rt');    
    for i = 1:maxLines
        thisLine = fgetl(fid);
        if isnumeric(thisLine), break; end
        txt{i} = thisLine;
    end
    fclose(fid);

    if isempty(txt)
        warning(['File "',file,'" is empty!']);
        return
    end

    screenSize = get(0,'ScreenSize'); % in pixels

    lines = listdlg('ListString' ,    txt , ...
        'ListSize' ,         screenSize(3:4) - 250 , ...
        'SelectionMode',    'single' , ...
        'Name' ,             mfilename , ...
        'PromptString' ,    'Select line to modify' );
    
    if isempty(lines) % fix 2016-02-22, moved this from if-else-end block below
        error('User canceled at prompt for selecting line numbers');
    end
    
    if nargout > 1
        line = lines(1);
        LNstr = int2str(line);
        dlgTitle=[mfilename ' : strrep(S1,S2,S3), where S1 = text at line ' LNstr];
        prompt={     'Enter S2 string, or blank to overwrite whole line', ...
                ['Enter S3 string - if both S2 & S3 blank, line ' LNstr ' will be removed']};
        def={txt{line},txt{line}};
        lineNo=1;
        userAnswer = inputdlg( prompt, dlgTitle, lineNo, def );
        if isempty(userAnswer)
            error('User canceled at prompt for replacement string');
        end
        replaceThis = userAnswer{1};
        withThis = userAnswer{2};
    end
    
return

