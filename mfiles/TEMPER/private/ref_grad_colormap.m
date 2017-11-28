function [hCb] = ref_grad_colormap( hAx, fadeFactor, varargin )
%ref_grad_colormap - Sets colormap & colorbar for a refractivity gradient plot
%
%
% USE: hCb = ref_grad_colormap( hAx,  fadeFactor, gradUnits );
%      ... = ref_grad_colormap( hAx,  fadeFactor, refUnits, hgtUnits );
%      ... = ref_grad_colormap( hFig, fadeFactor, ... );
%      ... = ref_grad_colormap(                   ..., fontSize );
%
%   First input is handle of either an axes or figure object (the plot). Second
%   input is a factor >= 1 for "fading" the colormap towards white (1 = no
%   fading, Inf = all white / no color). Additional inputs specify the units
%   used in this plot:
%
%       refUnits -> either 'M' or 'N'
%       hgtUnits -> run "help convert" for more info
%       gradUnits -> 'M/x' or 'N/x' where "x" is any valid hgtUnits string
%
%   Optional last input is font size for colorbar labels. Defaults to current
%   font size of the axes object
%
%
% ©2008-2015, Johns Hopkins University / Applied Physics Lab
% Last update: 2015-02-22


% Update list: (all JZG)
% -----------
% 2008-08-19 - ?
% 2014-01-03 - minor change; added the output hCb arg.
% 2015-01-25 - partial update for R2014b new UI objects (see comments for 
% "hGhost" variable), but resizing is still problematic.
% 2015-02-22 - R2014b issues should now be completely resolved; resizing
% addressed using resizefcn callbacks to figure + Tag/UserData properties.


    switch lower( get(hAx,'type') )
        case 'axes'
            hFig = get(hAx,'parent');
        case 'figure'
            hFig = hAx;
            hAx  = get(hFig,'currentaxes');
            if isempty(hAx), figure(hFig); hAx = gca; end % <- create new axes in figure
        otherwise
            error('First input must be a figure or axes handle');
    end
    
    if isempty( varargin ), error('Too few inputs'); end
    unitArgs = varargin;
    if isnumeric( unitArgs{end} )
        fontSize = unitArgs{end};
        unitArgs(end) = [];
    else
        fontSize = get(hAx,'fontsize');
    end
    
    switch length( unitArgs )
        case 1
            gradUnits = unitArgs{1};
            iDiv      = find( gradUnits == '/' );
            refUnits  = gradUnits(1:iDiv-1);
            hgtUnits  = gradUnits(iDiv+1:end);
        case 2
            refUnits  = unitArgs{1};
            hgtUnits  = unitArgs{2};
            gradUnits = [refUnits,'/',hgtUnits];
        otherwise
            error('Incorrect # of inputs');
    end
    
    [stdGrad, ductThresh] = reference_ref_grads( refUnits, hgtUnits );
    
    nCmapColors = 18; % <- *** FUNCTION PARAMETER *** (TBD make it an input?)
        % Shouldn't be too big (e.g. use something >= 10 and <= 20) because each
        % color always represents the same delta-gradient, therefor too few or
        % too many colors will lead to a colorscale that's either too big or too
        % small w.r.t. the range of naturally occurring gradients.
        
    % Set color-scale limits such that midpoint of scale corresponds to
    % standard gradient, and 1.5 colors below midpoint corresponds to
    % the ducting-threshold gradient:
    nColorsBetweenStdAndDuct = 2; % <- *** FUNCTION PARAMETER ***
    deltaColor = abs(stdGrad - ductThresh)/nColorsBetweenStdAndDuct;
    
    % Put roughly 25% of colorscale above standard
    nColorsAboveStd = ceil( 0.25 * nCmapColors);
    nColorsBelowStd = nCmapColors - nColorsAboveStd;
    cLim = stdGrad + [-nColorsBelowStd,nColorsAboveStd].*deltaColor;
    
    % Shift color axis downward by 0.01% of extent, otherwise roundoff
    % errors will put standard & duct gradients randomly in one of the two
    % bounding colors.
    cLim = cLim - 0.0001*diff(cLim);
    caxis( cLim );
    
    % Create colormap:
    % JET colormap with small # of colors tends to look better when
    % it's created with more than enough colors, then thinned to the
    % desired size.
    cMap = jet(256);
    
    % Attempt to place first yellow color just below the duct threshold.
    % Check for yellow by testing whether red is >= 0.5 & blue is < 0.5.
    isYellow = ( cMap(:,1) >= 0.5 & cMap(:,3) < 0.4 );
    iYellow  = min(find(isYellow)); % <- first yellow entry
    isGreen  = ( cMap(:,2) >= 0.9 & cMap(:,1) < 0.4 );
    iGreen   = max(find(isGreen));  % <- last green entry
    iCmapTop = round( linspace(1,iGreen,nColorsAboveStd) );
    iCmapBot = round( linspace(iYellow,256,nColorsBelowStd) );
    cMap = cMap([iCmapTop,iCmapBot],:);
    
    % For refractivity gradients, negative values correspond to ducting &
    % should be associated with warm colors -> need to flip color order:
    cMap = flipud(cMap);
    
    % Fade colors towards white to avoid obscurring lines in foreground
    % (but only if surface plot & actually has lines in the foreground):
    cMap = fade_colormap(fadeFactor,cMap);
    
    colormap(cMap);
    
    % IMPORTANT: only create colorbar *after* axes color limits & figure 
    % colormap have been set:
    hCb = colorbar('vert');
    stdNormPos  = nColorsBelowStd/nCmapColors;
    ductNormPos = stdNormPos - nColorsBetweenStdAndDuct/nCmapColors;
    
    isGoodOldUiObjects = verLessThan( 'matlab', '8.4.0' );
    
    if ( isGoodOldUiObjects )    
        hGhost = hCb; % no ghost, just work with normal colorbar axes object hCb
    else
        % R2014b implements colorbars in a new way. They are now their own type
        % (or at least an extension of axes objects with their own properties &
        % behavior). One implication is that text objects can no longer be
        % children of a colorbar object. Workaround (provided by Mathworks) is
        % to create a "ghost" axes object with the same size as the colorbar and
        % then attach the text objects to this "ghost" axes.
        hGhost = axes('Position',hCb.Position,...
                    'Color','none',...
                    'XColor','none',...
                    'YColor','none');
        % Had to add these to Mathwork's suggestions for everything to work
        % right:
        set( hGhost, 'ActivePositionProperty', 'Position' ); % in case figure is resized
        set( hGhost, 'xlim',[0,1], 'ylim',cLim );
    end
    
    text( 'Parent', hGhost, 'Units', 'normalized', 'FontSize', fontSize,...
        'Position', [0.02,stdNormPos], 'String', 'std',...
        'VerticalAlignment','middle' );
    text( 'Parent', hGhost, 'Units', 'normalized', 'FontSize', fontSize,...
        'Position', [0.02,ductNormPos], 'String', 'duct',...
        'VerticalAlignment','top' );

    labelKFactor = [0.8,0.5]; % <- *** FUNCTION PARAMETER *** (TBD make it an input?)
        % Shouldn't list too many, or plot will get over-crowded
    convertTo    = ['d',refUnits,'dh'];
    labelGradVal = kfactor_convert( labelKFactor, 'k', convertTo, hgtUnits );
    if ( isGoodOldUiObjects )
        xLimCb = get(hCb,'xlim');
    else
        xLimCb = [0,1];
    end

    for i = 1:length(labelGradVal)
        labelStr = sprintf( '_{k<%0.1f}', labelKFactor(i) );
        text( 'Parent', hGhost, 'Units', 'data', 'FontSize', fontSize,...
        'Position', [mean(xLimCb),labelGradVal(i)], 'String', labelStr,...
        'VerticalAlignment','bottom', 'HorizontalAlignment','center' );
        line( 'Parent', hGhost, 'xdata',xLimCb, 'ydata', labelGradVal([i,i]),...
        'linestyle','-');
    end    

    % Set colorbar title
    axes(hGhost);
    title( gradUnits, 'interpreter','none' );
    
    if ( isGoodOldUiObjects )
        axes(hAx);
    else
        % R2014b still moves the main axes object in front of ghost whenever hAx
        % is made current. TODO: fix this.
        % For now, return the ghost handle so that calling code can hack around
        % this problem (e.g., see code at end of plot_ref.m).
        hCb = hGhost;
        % ALSO, the hack that Mathworks suggested ("ghost" axes) for solving
        % this particular problem also gets screwed up by any resizing of the
        % figure. Hack the hack here...
        uniqueTag = 'ref_grad_colormap ghost colorbar';
        actualCb = findobj(gcf,'Type','Colorbar');
        if length(actualCb) ~= 1
            error('Matlab glitch or code bug detected - expecting exactly 1 true colorbar object');
        end
        set( hGhost, 'Tag',uniqueTag, 'UserData',actualCb );
        rfn = get( hFig, 'Resizefcn' );
        if ~isempty( rfn ) && rfn(end) ~= ';', rfn(end+1) = ';'; end
        rfn = [rfn,...
            'try,',...
                'hGhost = findobj(gcbf,''Type'',''axes'',''Tag'',''',uniqueTag,''');',...
                'hCb = get(hGhost,''UserData'');',...
                'if ~ishghandle(hCb) && ~isempty(hGhost),',...
                    'delete(hGhost);',...
                'else,',...
                    'set(hGhost,''position'',get(hCb,''position''));',...
                'end;',...
            'catch,',....
                'disp(lasterr);',...
            'end;'];
        set( hFig, 'Resizefcn', rfn );
    end
    
return