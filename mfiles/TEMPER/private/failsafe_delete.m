function [isOk,msg] = failsafe_delete( file, isBatch )
%failsafe_delete - More robust & flexible version of DELETE.M
%
%   This function has the following advantages over DELETE.M:
%       - will delete read-only files
%       - will delete directories
%       - catches unhandled errors
%
% USE: [isOk,msg] = failsafe_delete( file, isBatch )
%
%   file - Name of a file or directory to delete.
%   isBatch - (optional) 0/1 flag, 1 = delete w/out prompting.  Note that, even
%       when isBatch == 0, this function will not prompt you when deleting a
%       file.
%
% (c) 2005-2015
% Last update: 2009-12-31 (JZG)

    isOk = 0;
    msg = '';
    
    if ( nargin < 2 ), isBatch = 0; end
    
    if isempty(file), msg = 'Input was empty'; return; end
    
    isFile = all( exist( file, 'file' ) ~= [0,7] );
    isDir  = ( exist( file, 'dir'  ) == 7 );
    
    if not( isDir ) & not( isFile )
        msg = 'Input is not an existing file or directory';
        return;
    end
    
    if ( isDir & isFile )
        msg = ['"',file,'" is both a file & a directory - delete file?'];
        if ~user_says_yes( msg, isBatch ), return; end
    end
    
    if ( isFile )
        try
            delete( file );
            if exist( file, 'file' )
                fileattrib( file, '+w' );
                delete( file );
                if exist( file, 'file' )
                    msg = ['Tried setting +w attribute & still could not delete "',file,'"'];
                else
                    isOk = 1;
                end
            else
                isOk = 1;
            end
        catch
            msg = lasterr;
        end
    elseif ( isDir )
        msg = ['"',file,'" is a directory - delete all contents?'];
        if ~user_says_yes( msg, isBatch ), return; end
        [isOk,msg] = rmdir( file, 's' );
    end
    
return





function isYes = user_says_yes( qStr, isBatch )
    if ( isBatch )
        isYes = 1;
    else
        resp = questdlg( qStr, mfilename, 'yes', 'no', 'no' );
        isYes = strcmpi( resp, 'yes' );
    end
return