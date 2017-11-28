function [Srf,hFig] = plot_srf( file, plotRngUnits, plotHgtUnits, showKeSlopes )
%plot_srf - Plots terrain heights from a TEMPER surface-parameter (.srf) file
%
%   Note that this routine only works on TEMPER version 3.0 & later .srf files.
%   Older versions of TEMPER used terrain files that did not have header text;
%   this routine cannot read that old file format.
%
%
% USE: [Srf,hFig] = plot_srf;
%
%   Prompts for selectionn of a TEMPER .srf file & generates a plot of the
%   terrain heights stored in that file. Output is a structure returned by
%   read_srf.m. Optional 2nd output is handle of the created figure.
%
%
% USE: [...] = plot_srf( file, unitsFlag );
%
%   First input is a string specifying the path & name of a TEMPER .srf file.
%   Input an empty value for "file" to trigger graphical file prompt. Optional
%   second input is a 0/1 flag that, if set to 1, forces all plots to be in
%   metric units (m/km) even when the .srf file contains value in ft & nmi.
%   nmi. Default value is 0 (i.e., use native units of file for plot).
%
%
% USE: [...] = plot_srf( file, plotRngUnits, plotHgtUnits, showKeSlopes );
%
%   Similar to calling convention above, except with complete control over units
%   used for height & range dimensions of plot, independent of units used in
%   file. Type "help convert_length" for more info about these two units inputs.
%   Input empty values for either one of these units inputs to default to the
%   native range and/or height units used in the .srf file.
%
%   Optional 4th input (showKeSlopes) is a 0/1 flag; set it to 1 to highlight
%   all terrain slopes which are sufficiently steep to require the knife edge
%   (KE) method in TEMPER, as opposed to the linear shift map (LSM) method (see
%   TEMPER User Guide for more info about KE & LSM, and why some terrain slopes
%   cannot be modeled using LSM).
%
%
% EXAMPLES:
%
%   Srf = plot_srf; % you'll be prompted to select a .srf file
%   pause;
%
%   file = Srf.file;
%
%   % Now plot same terrain profile in data miles by kilofeet, highlighting
%   % slopes that are too large for the LSM terrain method in TEMPER:
%   plot_srf( file, 'dmi', 'kft', 1 );
%
%
% ©1999-2015, Johns Hopkins University / Applied Physics Lab
% Last modified 2015-02-22 by JZG


% JZG note: original version corresponds to a calling convention that is no
% longer supported:
%   >> plot_srf(file,interp) % no output


% Update list: (all JZG)
% ----------
% 1999-09-23: Added UIGETFILE and Metric input flag.
% 2002-12-02: Got rid of extraneous line on plot.
% 2004-01-23: Adapted to accept struct input as well as filename, structure
% output, improved code, fixed some minor bugs.
% 2007-03-12: Improved code readability, much better header comments, added
% rngUnits/hgtUnits calling convention (replaces old "plotMetric" convention),
% switched to convert_length instead of hardcoded unit-conversion constants,
% added MAX_TITLE_LEN.
% 2007-10-27: Updated "Srf" structure names.
% 2009-03-09: Reinstated old (file,plotMetric) calling convention + made units
% handling more flexible via calls to unitflag2str.m. Added "showKeSlopes" input
% arg & functionality + a few more minor tweaks.
% 2010-12-01: Updated header comments, renamed some variables to help clarify
% code, and changed the "plotMetric" input to "unitsFlag" (functionally, the
% only impact is that in the old code, plotMetric==0 for a km/ file would
% result in a km/m plot, whereas in the new convention unitsFlag==0 will produce
% a nmi/ft plot for the same inputs).
% 2015-02-22: No longer forcing 12-pt font size, added 2nd output arg, added
% "textColor" to KE % message, and dropped MAX_TITLE_LEN from 75 to 60. 


	% Hardcoded parameters
    %~~~~~~~~~~~~~~~~~~~~~
    
	%PRE: FONT_SIZE = 12;     % font size for all text in plot
    FONT_SIZE = []; % empty will conform to axes defaults
    MAX_TITLE_LEN = 60; % max # of characters in title
    
    
	% Input handling
    %~~~~~~~~~~~~~~~
    
	if ( nargin < 1 ), file = []; end
    if ( nargin < 2 ), plotRngUnits = []; end
    if ( nargin < 3 ), plotHgtUnits = []; end
    if ( nargin < 4 ), showKeSlopes = 0; end
	
	if ( nargin == 2 ) % similar to old (file,plotMetric) calling convention
        unitsFlag = plotRngUnits;
        [plotRngUnits,plotHgtUnits] = unitflag2str( unitsFlag );
    end
	
	if isempty( file )
       [f,p] = uigetfile('*.srf');
       if isnumeric(f), return; end % quit if user hits "cancel"
       file = fullfile(p,f);
       cd(p); % cd to path - helpful when plotting files in sequence
	end

    
	% Load data
    %~~~~~~~~~~~~~~~
    
	if isstruct(file)
        Srf = file;
        file = Srf.file;
	else
        Srf = read_srf( file );
	end

    
	% Unit handling
    %~~~~~~~~~~~~~~~
    
    [srfRngUnits,srfHgtUnits] = unitflag2str( Srf.units );
	if isempty( plotRngUnits ), plotRngUnits = srfRngUnits; end
	if isempty( plotHgtUnits ), plotHgtUnits = srfHgtUnits; end
    	
	
	% Generate plot
	%~~~~~~~~~~~~~~
	
	hFig = figure;
    
    r = convert_length( Srf.range,  srfRngUnits, plotRngUnits );
    h = convert_length( Srf.height, srfHgtUnits, plotHgtUnits );
	plot( r, h, ...
          'Color', [0.1,0.8,0.2], ...
          'Marker', '.', ...
          'MarkerEdgeColor', 'k', ...
          'MarkerSize', 4 );

    if ( showKeSlopes )
        riseOverRun =          diff(Srf.height) ./ ...
                      convert_length( diff(Srf.range ), srfRngUnits, srfHgtUnits );
        slopeDeg = (180/pi).*atan( riseOverRun );
        slopeDeg = reshape( slopeDeg, 1, length(slopeDeg) );
        slopeChangeDeg = [0,diff(slopeDeg)];
        forTemperVersion = 3.1;
        [maxLsmSlope,maxLsmChange] = max_lsm_slope( forTemperVersion );
        iLsmBad  = find( abs(slopeDeg) > maxLsmSlope | abs(slopeChangeDeg) > maxLsmChange).';
        hold on;
        plot( r([iLsmBad,iLsmBad+1]).', h([iLsmBad,iLsmBad+1]).', 'r' );
        percentKe = 100 * length(iLsmBad)/(length(r)-1);
        if ( percentKe > 0 )
            textColor = 'r';
        else
            textColor = 'k';
        end
        text('parent',gca,...
            'string',sprintf('%0.1f %% KE',percentKe),...
            'position',[0.01,0.99,0],...
            'units','normalized',...
            'color',textColor,...
            'verticalalignment','cap');
    end
    
    hAx = gca;
    
	set( hAx, 'box','on', 'xgrid','on', 'ygrid','on' );
    if isempty(FONT_SIZE)
        FONT_SIZE = get(hAx,'fontsize');
    else
        set( hAx, 'fontsize',FONT_SIZE );
    end
	zoom on; 
    axis tight;
    	
    xlabel( ['Range [',plotRngUnits,']'],          'FontSize',FONT_SIZE );
    ylabel( ['Terrain Height [',plotHgtUnits,']'], 'FontSize',FONT_SIZE );
   
    titleStr = [file,': terrain height'];
    if ( length(titleStr) > MAX_TITLE_LEN )
        titleStr = titleStr(end-MAX_TITLE_LEN+1:end);
    end
    title( titleStr, 'FontSize',FONT_SIZE, 'interpreter','none' );

return
