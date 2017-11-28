function [hFig,hAx] = plot_grz( file )
%plot_grz - Plots TEMPER-calculated grazing angle vs. range (.grz file).
%
%
% USE: [hFig,hAx] = plot_grz;          % <- graphical file prompt
% USE: [...     ] = plot_grz( file );
%
%   file - Input name of TEMPER .grz file to be plotted.
%   hFig - Output handle of created figure object.
%   hAx  - Output handle of axes object where grazing angles are plotted.
%
%
% ©1998-2015, Johns Hopkins University / Applied Physics Lab
% Last update: 2008-01-23 (JZG)


% Update list: (all JZG unless noted)
%-------------
% 1998-07-28 - (MHN) Updated to handle old (pre-beta 6) and new formats.
% 1999-09-13 - Graphical file selection added.
% 2004-03-10 - Revamped function, removed globals & broke file-reading
%   code into separate function (read_grz.m).
% 2006-11-02 - Added titles & labels to plot and changed some line properties.
% 2008-01-23 - Fixed bug, added file output to read_grz.m so that title is
% populated even in graphical-prompt mode.

    
    % Initialize output:
    [hFig,hAx] = deal([]);
    
    % Empty ihput to file-reading function triggers graphical selection
    if ( nargin < 1 ), file = ''; end
    
    [grz,rng,rngUnits,typ,typLegend,file] = read_grz( file );
    if isempty(grz), return; end % quit if user cancels
    
    hFig = figure;
    plot( rng, grz, 'k' );
    hAx  = gca;
    
    hLine = [];
    legendStr = {};
    colors = 'bgrym';
    for iTyp = 1:length(typLegend)
        i = find( typ == iTyp );
        if ~isempty(i)
            hold on;
            hLine(end+1) = plot( rng(i), grz(i), [colors(iTyp),'.'] );
            legendStr(end+1) = typLegend(iTyp);
            hold off;
        end
    end
    legend( hLine, legendStr{:}, 1 );
    
    [junk,titleStr] = fileparts(file);
    titleStr = strrep(titleStr,'_',' ');
    title( titleStr );
    xlabel(['range [',rngUnits,']']);
    ylabel('grazing angle [°]');

return