function [isAllOk,errMsg] = failsafe_copyfile( sourceFile, destFile, moveOpt )
%failsafe_copyfile - Wrapper to greatly improve reliability of builtin COPYFILE
%
%   Matlab's builtin MKDIR, COPYFILE & MOVEFILE functions are inflexible &
%   unreliable. Furthermore, despite Matlab help comments that claim these
%   routines inform the user when files cannot be copied or moved, in practice
%   this is not true - their "message" outputs rarely give useful information
%   (if any) about why the copy/move failed.
%
%   This "failsafe" version is essentially a wrapper around the built-in
%   routines.  By adding flexibility and working around the many limitations of
%   the builtin functions, this routine greatly improves file moving/copying
%   capabilities from within Matlab.
%
%   SEE ALSO: failsafe_delete.m
%
%
% USE: [SUCCESS,MESSAGE] = failsafe_copyfile( sourceFile, destFile );
%
%   COPYFILE mode: copies file "sourceFile" to location "destFile".  See NOTES
%   below for more info, and type "help copyfile" for a more thorough
%   description of inputs & outputs.
%
%
% USE: [SUCCESS,MESSAGE] = failsafe_copyfile( sourceFile, destFile, 'move' );
%
%   MOVEFILE mode: moves file "sourceFile" to location "destFile" then, if copy
%   was successful - deletes the source file.  See NOTES below for more info.
%
%   SEE ALSO: failsafe_movefile.m & failsafe_rename.m
%            (these two routines are merely wrappers for failsafe_copyfile.m)
%
%
% USE: [SUCCESS,MESSAGE] = failsafe_copyfile( [], newDir );
%
%   MKDIR mode: like COPYFILE mode, except that function only creates new
%   subdirectories needed to make input directory "newDir" exist - no files are
%   actually copied.  See NOTES below for more info.
%
%   SEE ALSO: failsafe_mkdir.m 
%            (failsafe_mkdir.m is merely a wrapper for failsafe_copyfile.m)
%
%
% IMPORTANT NOTES:
% ---------------
% - Unlike COPYFILE.M, destFile should include both the path *AND* filename.
% - Both inputs must have full pathnames -> no relative paths allowed.
% - "sourceFile" must already exist.
% - "destFile" may or may not exist.
% - If "destFile" exists & is read-only, it will be overwritten in Matlab v6.0+
% - "destFile" can include any number of subfolders that do not yet exist
% - This function *explicitly* confirms that destFile exists after copying.
%   While this check adds runtime, it is necessary due to the many shortcomings
%   of Matlab's built-in functions.
% - This function has *not* been tested on Mac or Unix platforms, however it
%   doesn't call any PC-specific routines.  The only possible quirk is that it
%   will treat two files/paths that differ in capitalization only as identical.
%
%
% Last update: 2012-02-23 (JZG)


% Update list:
% -----------
% 2006-02-24 - Added checks for disallowed_filesys_chars().
% 2009-09-20 - Prevent infinite loop on invalid input (e.g., C:\work\C:\work)
% 2009-11-11 - Removed minor nuisance (thisDir assignment missing a ;) and made
% code throw an ERROR if not successful & no output args
% 2009-12-31 - Switched from delete to failsafe_delete for 'move' mode cleanup,
% improved header comments.
% 2010-10-31 - Changed the behavior of this function to make write-protected 
% files writable after copying
%
%       ... (TBD ADD THE OPTION TO NOT CHANGE WRITE STATUS?) ...
%
% 2012-02-23 - Adapted to R2011's annoying change to fileparts output args.
% 
% ... Note that unit test in failsafe_movefile.m tests much of this routine's
% functionality as well.

	
	if ( nargin < 3 ), moveOpt = ''; end
    
    nOut = nargout; % passed into errchk() subroutine
	 
	isAllOk = 0; % initialize output, will be set to 1 if all goes well
	errMsg = '';
	
    if ispc
        sourceFile = lower( sourceFile );
        destFile   = lower( destFile );
    end
    
	isMkDirMode = isempty( sourceFile );
	isMoveMode  = strcmpi( moveOpt, 'move' );
	
	if ( isMkDirMode )&( isMoveMode )
        errMsg = ['Incorrect inputs to ',mfilename,': first input cannot be empty for MOVEFILE mode'];
        errchk(errMsg,nOut); return
	end
	
	if not( isMkDirMode ) & not( exist( sourceFile, 'file' ) )
        errMsg = ['Source file (',sourceFile,') does not exist.'];
        errchk(errMsg,nOut); return
	end
	
	% Note that use of STRCMPI is PC-specific, since on Mac & Unix platforms you
	% can have files that differ only in case (i.e., STRCMP instead of STRCMPI)
	if not( isMkDirMode ) & strcmpi( sourceFile, destFile )
        if ~ispc && ~strcmp( sourceFile, destFile )
            % I think it's safer to throw an error here, in case the difference 
            % in case was just a mistake in the Matlab code
            errMsg = ['A dest. that only differs in case already exists (',...
                sourceFile,')'];
        else
            errMsg = ['Source & dest. file the same (',sourceFile,')'];
        end        
        errchk(errMsg,nOut); return
	end
	
	% Determine if destination input includes any new directories.  Use FILEPARTS
	% to "bootstrap" up the directory chain, saving each intermediate directory
	% name in "newDirList".
	newDirList = {};
	[thisDir] = fileparts( destFile );
	counter = 0;
	maxCounter = 100;
	while ( exist(thisDir,'dir') ~= 7 ) & ~isempty(thisDir)
        counter = counter + 1;
        newDirList{end+1} = thisDir;
        if thisDir(end) == filesep, thisDir(end) = []; end
        [thisDir] = fileparts( thisDir );
        if strcmpi( newDirList{end}, thisDir ) | ( counter > maxCounter )
            error(['Malformed input destFile (',destFile,') or code error',...
                   ' detected. ',mfilename,'.m has thrown an error to',...
                   ' prevent infinite loop.']);
        end
	end
	
	% Now create the new destination directories.  Must work in reverse (end to 1)
	% order.  But first, initialize to 1 to handle case where "newDirList" is
	% empty (i.e. directory already exists)
	isSuccess = 1;
	for i = length(newDirList):-1:1
        [parentDir,temp1,temp2] = fileparts( newDirList{i} );
        newDir = [temp1,temp2]; % bug fix 2004-05-27
        [isSuccess,errMsg] = mkdir( parentDir, newDir );
        [isSuccess,errMsg] = dont_trust_it( 'mkdir', newDirList{i}, isSuccess, errMsg );
        if not( isSuccess ), errchk(errMsg,nOut); return; end
	end
	
	if not( isMkDirMode )
	
		% Lastly, call COPYFILE.  Version 6.0 and later purport to have a "force" 
		% mode where files are copied even if the destination folder has the 
		% "read only" roperty, so make the call to COPYFILE version-specific.
		
		copyfileArgs = { sourceFile, destFile };
            
		matlabVersion = sscanf(version,'%d.');
        % If possible, use the "force" input that was added to COPYFILE at v6.0.
        % This allows COPYFILE to overwrite read-only files.
        if matlabVersion(1) >= 6, copyfileArgs{ end+1 } = 'f'; end
		
		[isSuccess,errMsg] = copyfile( copyfileArgs{:} );
		[isSuccess,errMsg] = dont_trust_it( 'copyfile', destFile, isSuccess, errMsg );
        
	end
	
	% Added 2006-02-24
	if not( isSuccess )
        [pSource,fSource,xSource] = fileparts( sourceFile );
        [pDest,  fDest,  xDest  ] = fileparts( destFile   );
        if disallowed_filesys_chars(     'file', [fSource,xSource] )
            errMsg = [ errMsg, sprintf('\n'), ...
                       'Source filename contains disallowed system characters' ];
        elseif disallowed_filesys_chars( 'path', pSource           )
            errMsg = [ errMsg, sprintf('\n'), ...
                       'Source path contains disallowed system characters' ];
        elseif disallowed_filesys_chars( 'file', [fDest,xDest]     )
            errMsg = [ errMsg, sprintf('\n'), ...
                       'Dest filename contains disallowed system characters' ];
        elseif disallowed_filesys_chars( 'path', pDest             )
            errMsg = [ errMsg, sprintf('\n'), ...
                       'Dest path contains disallowed system characters' ];
        end        
	end
	
	if ( isSuccess )&( isMoveMode )
        isBatch = 1;
        [isDelOk,delMsg] = failsafe_delete( sourceFile, isBatch );
        if not( isDelOk )
            isSuccess = 0;
            errMsg = sprintf(['New file was successfully created (%s),\n',...
                    'however old file was *NOT* deleted (%s).\nError = "%s"'],...
                    destFile, sourceFile, delMsg );
        end
    end
	
    if ( isSuccess ) & not( isMoveMode ) & not( isMkDirMode )
        fileattrib( destFile, '+w' );
    end
    
	if ( isSuccess ), isAllOk = 1; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return




    
function errchk(errMsg,nOut)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If # output args (nOut) is non-zero, this function does nothing - it's merely
% a pass-throuhg - however if nOut==0 this function throws an error using the
% input message whenever that message (errMsg) is non-empty.
    if ( nOut > 0 ), return; end
    if isempty(errMsg), return; end
     error(errMsg);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return





function [isSuccess,errMsg] = dont_trust_it( fun, target, isSuccess, errMsg )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I've found Matlab's MKDIR & COPYFILE sometimes report success when the
% directory/file wasn't actually created, and they can report an error without
% any explanatory message - both of which contradict Matlab's "help"
% documentation on these functions.  Maybe it's a Windows-specific problem?
	
	switch lower(fun)
        case 'mkdir'
            targetExists = ( exist( target, 'dir' )  == 7 );
        case 'copyfile'
            targetExists = exist( target, 'file' ); % note: don't use == 2!
        otherwise
            error('Coding error detected - bad first input to subfunction');
	end
	
	if ( isSuccess ) % don't trust it
        if not( targetExists )
            errMsg = [upper(fun),' errantly reported success - "',target,...
                    '" was not actually created.'];
            isSuccess = 0;
        end
	elseif isempty( errMsg )
        errMsg = [upper(fun),' failed to create "',target,'" and also',...
                ' failed to give a useful error message.'];
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return


