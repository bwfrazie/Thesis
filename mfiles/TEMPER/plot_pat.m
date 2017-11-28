function Pat = plot_pat( patFile, plotFlag, sourceFlag, titleStr )
%plot_pat - Plots a TEMPER antenna pattern file.
%
% USE: Pat = plot_pat;
%
%   All inputs optional. Function will prompt you for selections. Output "Pat"
%   is a structure with fields:
%
%       .file  -> .pat file name
%       .above -> normalized voltage amplitude above boresight (1st column)
%       .below ->  " "  below boresight (2nd column), or empty if no 2nd column
%       .angle -> vector of angles in degrees above & below boresight (i.e.
%                 the angular abscissa of first two output vectors)
%
%
% USE: Pat = plot_pat( patFile, plotFlag, sourceFlag, titleStr )
%
%   patFile - name of file that contains pattern data (usually .pat extension).
%       If omitted or input as empty, you will be prompted to select a file.
%
%   plotFlag - integer flag that controls what type of plot gets created. If
%       omitted or input as empty, the function prompts you to select one of the
%       available options. Integer input values are interpreted as follows:
%
%       1 = signed voltage, linear units
%       2 = |voltage|^2 in dB
%       3 = polar plot **
%       4 = all plots (1, 2 & 3) as subplots in the same figure
%       5 = 1 & 2 as subplots in the same figure
%       [] = default behavior (prompt user to select among the above options)
%
%   sourceFlag - integer flag that controls what symetric extensions are
%       plotted. This input is loosely analogous to the TEMPER "Source flag"
%       input parameter, in that this function will plot a representation of how
%       TEMPER *would* *interpret* a Source-flag input value for the given
%       pattern file. Omitting this flag or providing and empty value to this
%       Matlab function produces the default behavior of plotting *all* possible
%       extensions of the file.
%                                       # plots made by this Matlab function
%                                       when given a .pat file containing ...
%                                       ... half-space pat  ... full-space pat
%                                       ------------------  ------------------
%       1 = plot symmetric extension    1 (symmetric)       2 (full & symmetric)
%       2 = anti-symmetric extn. **     1*(anti-symmetric)  2*(full & anti-sym.)
%       3 = plane wave (NOT AVAILABLE)  0 (generates error) 0 (generates error)
%       4 = arbitrary symmetry          0 (generates error) 1 (full-space pat)
%       [] = default behavior           1 or 2*             2 or 3*
%
%       * Anti-symmetric extensions are only created if the pattern goes to zero
%       voltage at zero degrees elevation. In default mode, the function
%       automatically decides whether to plot the anti-symmetric extension. In
%       anti-symmetric mode (sourceFlag == 1) an error is generated if the
%       patter does not go to zero at zero elevation.
%   
%       ** Anti-symmetric extensions (and any negative voltage values, for that
%       matter) will not look right in polar plots (plotFlag == 3).
%
%   titleStr - String to use in plot titles, defaults to name (without path or
%       extension) of the .pat file. You can also input a string that starts
%       with '+' and that input string will be *appended* to the name of the
%       .pat file in the plot titles. For example:
%
%       file = 'C:\work\myPattern.pat'
%       titleStr = '+(I made it myself)'
%       --> plots will have the title "myPattern (I made it myself)"
%
%
% © 2003-2015 JHU/APL (jonathan.gehman@jhuapl.edu)
% Last update: 2013-05-14 (JZG)


% Update list:
% -----------
% 2003-11-12 (JZG) Significant code improvements & header comments.
% 2006-11-01 (JZG) Added struct input capability
% 2009-10-27 (JZG) Added option #5 for plotFlag, error check on plotFlag value,
% and aesthetic changes to code.
% 2010-10-13 (JZG) Relaxed test for making anti-symmetric plot from == 0 to
% abs() < 0.01.
% 2012-08-23 (JZG) Added third input arg (sourceFlag) and logic to support that
% functionality. Major overhaul to header comments. Also no longer CD to .pat
% directory when prompting user to select .pat file. Turned "boresight
% mistmatch" from a warning (disp) to an errordlg.
% 2013-02-06 (JZG) Fixed bug that occurred when structure is input directly.
% Added new "titleStr" option input arg.
% 2013-05-14 (JZG) Minor bug fixes (return if user cancels at plotFlag prompt &
% correctly set isPatAntisymFriendly for half-space .pat files)


    hFig = [];

    % Empty values for inputs trigger default behavior
    if nargin < 1, patFile      = ''; end % triggers graphical file selection
    if nargin < 2, plotFlag     = []; end % triggers graphical file selection
    if nargin < 3, sourceFlag   = []; end
    if nargin < 4, titleStr     = ''; end 
    
    % Error check values on 3rd input
    if ~isempty( sourceFlag )
        if ~ismember( sourceFlag, [1,2,4] )
            error(['Invalid input for sourceFlag; see ',mfilename,...
                ' help comments']);
        end
    end

    if isempty( patFile )
        Pat = read_pat;
        if isempty(Pat), return; end % <- user hit CANCEL at file prompt
        %PRE: [patPath, patName, patExtn] = fileparts( Pat.file );
        %PRE: cd(patPath);
    elseif ischar( patFile )
        Pat = read_pat( patFile );
    elseif isstruct( patFile )
        Pat = patFile;
    end

    [patPath,patName] = fileparts( Pat.file );
    if isempty( titleStr )
        titleStr = patName; 
    elseif titleStr(1) == '+'
        titleStr = [patName,' ',titleStr(2:end)];
    end

    if isempty( plotFlag )
        opts = {'(1) signed voltage, linear units',...
            '(2) |voltage|^2 in dB',...
            '(3) polar plot',...
            '(4) all (1-3) on one figure',...
            '(5) 1 & 2 on the same figure'};
        plotFlag = listdlg( 'PromptString','What to plot?', ...
            'ListString',opts, 'SelectionMode','single' );
        if isempty( plotFlag ), return; end
    end

    isPatFullSpace = ~isempty( Pat.below );

    isPatAntisymFriendly = abs( Pat.above(1) ) < 0.01;
    
    % This check is not necessary, but useful for helping the user catch bad
    % .pat files before they run them through TEMPER:
    if ( isPatFullSpace )
        mismatchError = abs( Pat.above(1) - Pat.below(1) );
        if ( mismatchError > 1e-9 )
            errordlg(['BAD .PAT FILE DETECTED: ',Pat.file,'''s boresight',...
                ' values are different in the "above" and "below" columns'])
        end
    end
    
    if isempty( sourceFlag ) || ( sourceFlag == 1 ) 
        % Symmetric-extension plot has been requested
        thisTitleStr = ['[ ',titleStr, ' ]: symmetric extension'];
        hFig(end+1) = make_plot( Pat.angle, Pat.above, Pat.above, 'b', ...
            thisTitleStr, thisTitleStr, plotFlag );
    end
    
    if isempty( sourceFlag ) || ( sourceFlag == 4 )
        % Full-pattern plot has been requested
        if ( isPatFullSpace )            
            thisTitleStr = ['[ ',titleStr, ' ]: full asymmetric pattern'];
            hFig(end+1) = make_plot( Pat.angle, Pat.above, Pat.below, 'k', ...
                thisTitleStr, thisTitleStr, plotFlag );
        else
            if not( isempty(sourceFlag) )
                error(['Cannot plot "arbitrary symmetry" (full-space)',...
                    ' because pattern data only covers half space (positive',...
                    ' elevation angles)']);
            end
        end            
    end
        
    if isempty( sourceFlag ) || ( sourceFlag == 2 )
        % Full-pattern plot has been requested
        if ( isPatAntisymFriendly )            
            thisTitleStr = ['[ ',titleStr, ' ]: anti-symmetric extension'];
            hFig(end+1) = make_plot( Pat.angle, Pat.above, -Pat.above, 'r', ...
                thisTitleStr, thisTitleStr, plotFlag );
        else
            if not( isempty(sourceFlag) )
                error(['Cannot plot anti-symmetric extension',...
                    ' because pattern data does not go to zero voltage at',...
                    ' zero-degrees elevation']);
            end
        end            
    end
        
return





function hFig = make_plot( ...
    anglesDeg, pAbove, pBelow, lineSpec, titleStr, figName, plotFlag )

    deg2rad = pi/180;
    rad2deg = 1/deg2rad;

    hFig = figure('Units','Normalized',...
        'Position',[0.2,0.1,0.6,0.75],'Name',figName);

    if ~ismember( plotFlag, [1:5] ), error('Invalid plot flag'); end

    if ( plotFlag == 4 ),       nSubRows = 3;
    elseif ( plotFlag == 5 ),   nSubRows = 2;
    else,                       nSubRows = NaN;
    end

    if ( plotFlag >= 4), subplot(nSubRows,1,1); end
    if ( plotFlag >= 4 | plotFlag == 1 )
        plot( anglesDeg, pAbove, lineSpec, ...
            -anglesDeg, pBelow, lineSpec );
        grid on;
        title(titleStr,'Interpreter','none');
        ylabel('voltage');
        if ( plotFlag ~= 4 ), xlabel('angle off boresight in degrees'); end
        axis tight;
    end

    if ( plotFlag >= 4), subplot(nSubRows,1,2); end
    if ( plotFlag >= 4 | plotFlag == 2 )
        plot( anglesDeg, x2db(pAbove.^2), lineSpec, ...
            -anglesDeg, x2db(pBelow.^2), lineSpec );
        grid on;
        if ( plotFlag ~= 4 ), title(titleStr,'Interpreter','none'); end
        ylabel('|voltage|^2 (dB)');
        xlabel('angle off boresight in degrees');
        axis tight;
    end

    if ( plotFlag == 4), subplot(nSubRows,1,3); end
    if ( plotFlag == 4 | plotFlag == 3 )
        polar( anglesDeg.*deg2rad, pAbove, lineSpec );
        grid on;
        hold on;
        polar( -anglesDeg*deg2rad, pBelow, lineSpec );
        hold off;
        if ( plotFlag ~= 4 ), title(titleStr,'Interpreter','none'); end
    end

    zoom on;

return