function out = disallowed_filesys_chars( opt, check )
%disallowed_filesys_chars - Checks for characters disallowed by file systems.
%
%
% USE: isBad = disallowed_filesys_chars( 'file', checkFile )
%
%   Returns true (1) if input string "checkFile" contains any characters that
%   are not allowed in file names.
%
% USE: isBad = disallowed_filesys_chars( 'path', checkPath )
%
%   Returns true (1) if input string "checkPath" contains any characters that
%   are not allowed in full paths.
%
% USE: charList = disallowed_filesys_chars( opt );
%
%   Returns a list (string "charList") of bad characters on the current
%   file system.  First input is one of the following strings:
%       'file' or 'copyfile'
%       'path' or 'mkdir'
%
% Last update: 2015-04-27

% Update list:
% -----------
% 2006-02-24 - ?
% 2015-04-27 - Added semicolon to list and removed isunix warning.

    charList = '/\:*?"<>|;';
    
%     if ( isunix )
%         warning( [mfilename,' list may not be correct for non-Windows',...
%                 ' file systems - please edit & correct'] );
%         charList = [charList,'+']; % ???
%     end
    
    switch lower( opt )
        case {'path','mkdir'}
            charList = setdiff( charList, '\/:' );
        case {'file','copyfile'}
            % do nothing
        otherwise
            error('First input must be either ''file'' or ''path''');
    end
    
    if ( nargin < 2 )
        out = charList;
        return
    end
    
    if ~ischar( check ), error('Second input must be a string'); end
    
    out = 0; % <- output "isBad" 0/1 flag
    for i = 1:length(charList)
        if any( check == charList(i) )
            out = 1;
            return
        end
    end

return