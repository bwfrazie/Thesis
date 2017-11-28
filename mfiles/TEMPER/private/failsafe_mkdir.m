function [isCreated,errMsg] = failsafe_mkdir( newDir )
%failsafe_mkdir - Wrapper that improves reliability of MKDIR.M
%
% USE: [SUCCESS,MESSAGE] = failsafe_mkdir( newDir );
%
% This function is merely a wrapper for "failsafe_copyfile" - see help comments
% in that function for more info.
%
% Last update: 2004-03-30 (JZG)

    if isempty(newDir), error('Empty input!'); end

    if newDir(end) ~= filesep, newDir = [newDir,filesep]; end

    [isCreated,errMsg] = failsafe_copyfile([], newDir );
    
return