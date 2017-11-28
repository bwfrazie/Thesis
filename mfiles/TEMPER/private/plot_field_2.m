function plot_field_2(varargin)
%
%  plot_fld(D,clim)
%
%  Plots the TEMPER Field File data contained within structure D, where
%  D.fdb contains the pattern propagation factor F in dB
%
%  MH Newkirk: 18 APR 2002

%  Updated 3/17/11 (TRH)
%
%  Added additional capabilities in support of fld_read_2.m TEMPER Field
%  File Reader/Plotter GUI, including supporting user-chosened units and
%  various types of coverage plots (prop loss vs. factor, one-way, two-way,
%  etc.)
%
%  Enhanced the autodb option to not include data points that fall outside
%  of the problem angle, thus giving better color resolution to the area of
%  interest.
%
%  Repositioned the plot to overcome the plotting behavior of pcolor and
%  surf such that the last row and column of data are included in the plot
%  and the data rectangles are centered about the data point instead of the
%  data occupying the lower left corner.
%
%  Fixed function to be compatible with newest tdata31 field names.  Also
%  included fix for axes limits based on actual range/altitude limits, and
%  not what is stored in the header.  This supports the range/altitude
%  limit functionality in the new tdata31.


newfig = 0;
disp_pl = 0;
autodb = 0;
cat = 0;
clrbar = 1;
subp=0;
fscale=1;
disp_units=0;
for i=1:length(varargin)
    if ischar(varargin{i})
        if strmatch(varargin{i},'new')
            newfig = 1;
        elseif strmatch(varargin{i},'loss')
            disp_pl = 1;
        elseif strmatch(varargin{i},'autodb')
            autodb = 1;
        elseif strmatch(varargin{i},'cat')
            cat = 1;
        elseif strmatch(varargin{i},'nobar')
            clrbar = 0;
        elseif strmatch(varargin{i},'subp')
            subp = 1;
        elseif strmatch(varargin{i},'one-way')
            fscale = 2;
        elseif strmatch(varargin{i},'two-way')
            fscale = 4;
        elseif strmatch(varargin{i},'feet')
            disp_units = 1;
        elseif strmatch(varargin{i},'meters')
            disp_units = 2;
        elseif strmatch(varargin{i},'data miles')
            disp_units = 3;            
        end
    elseif isstruct(varargin{i})
        if exist('d')==0
            d = varargin{i};
        else
            e = varargin{i};
        end
    elseif length(varargin{i})==2
        clim = varargin{i};
    end
end
if exist('d')==0
    d = read_tdata31_2;
end
%replace Inf with NaN
d.fdb(isinf(d.fdb)) = NaN;
%load pfm
pfm=[.1:-.00625:0 zeros(1,79) 0:0.015625:1 ones(1,63) 1:-0.015625:.515625;...
    zeros(1,16) 0:0.015625:1 ones(1,79) 1:-0.015625:0 zeros(1,31); ones(1,16) 1:-0.015625:0 zeros(1,175)]';
if exist('e') && cat==1
    %replace Inf with NaN
    e.fdb(isinf(e.fdb)) = NaN;
    f = d;
    blendpoint=2*f.r(1)-f.r(2);
    for i=1:length(e.r)
        if e.r(i)>blendpoint
            break
        end
    end
    d.head.probangle=e.head.probangle;
    F2 = [e.fdb(:,1:i-1) f.fdb];
    d.r = [e.r(1:i-1); f.r];
    d.t = [e.t(1:i-1); f.t];
    d.head.rmin = e.head.rmin;
    d.head.nr = length(unique([d.r]));
else
    F2 = d.fdb;
end
Fscaled=fscale*F2;   % convert F to F^2 or F^4 (in dB)
clear F2
if max(d.h>5000)%d.head.zmax>5000
    ch = 1/1000;
    hprefix = 'k';
else
    ch = 1;
    hprefix = [];
end

% if requesting display of Prop Loss, convert F2 array
if disp_pl==1
    pfm=flipud(pfm);  % switch coloraxis
    lambda = 299792458/d.head.freq;   % in meters
    if d.head.units==1
        rx = d.r * 1000;          % km -> meters
    else
        rx = d.r * 1852;          % nmi -> meters
    end
    for i = 1:length(d.r)
        Fscaled(:,i) = fscale * 10 * log10(4*pi*rx(i)/lambda) - Fscaled(:,i);
    end
    %    clim = [50 150];
end

if d.head.units==1 
    Range2HeightUnits=1000;
    if disp_units==2||disp_units==0
        rlab = 'km';
        zlab = 'm';
        xcon = 1;
        ycon = 1;
    elseif disp_units==1
        rlab = 'nmi';
        zlab = 'ft';
        xcon = 1/1.852;
        ycon = 1/0.3048;
    elseif disp_units==3
        rlab = 'dmi';
        zlab = 'ft';
        xcon = 1/1.8288;
        ycon = 1/0.3048;
    end
else
    Range2HeightUnits=6076.1155;
    if disp_units==1||disp_units==0
        rlab = 'nmi';
        zlab = 'ft';
        xcon = 1;
        ycon = 1;    
    elseif disp_units==2
        rlab = 'km';
        zlab = 'm';
        xcon = 1.852;
        ycon = 0.3048;
    elseif disp_units==3
        rlab = 'dmi';
        zlab = 'ft';
        xcon = 1.852/1.8288;
        ycon = 1;        
    end
end

land = [216 193 156]/256;

% Find the areas of Fscaled that lie outside of the problem angle, so they
% can be excluded in determining the color bounds.  This gives better color
% resolution to the problem space of interest.  (TRH)
%--------------------------------------------------------------------------
q=0;
InsideProbAngle=ones(length(d.h),length(d.r));
for i=1:length(d.r)
    h_thresh_high=Range2HeightUnits*d.r(i)*tand(d.head.probangle)+d.head.anthgt;
    h_thresh_low=-Range2HeightUnits*d.r(i)*tand(d.head.probangle)+d.head.anthgt;
    for j=1:length(d.h)
        if d.h(j) > h_thresh_high || d.h(j) < h_thresh_low
            InsideProbAngle(j,i)=NaN;
            q=1;
        end
    end
    if q==0
        break
    end
    q=0;
end
%--------------------------------------------------------------------------

maxF2 = max(max(Fscaled.*InsideProbAngle));
minF2 = min(min(Fscaled.*InsideProbAngle));
clear InsideProbAngle
if exist('clim','var')==0
    if d.head.compr==3
        d.head.pf_thresh = -180; % TBD fix this when read_temper_header is updated
        if disp_pl==0 && ~autodb
            clim = [d.head.pf_thresh 10];
        else
            clim = [d.head.pf_thresh 10*ceil(maxF2/10)];
        end
    else
        clim = [10*floor((minF2)/10) 10*ceil(maxF2/10)];
    end
end

[m,n]=size(Fscaled);
if m==1 || n==1
    errordlg('Cannot plot data sets with only one range or altitude data point'); 
    return
end
hfm = findobj('Name','TEMPER Prop Factor Plot');
if isempty(hfm) || newfig==1
    figure('Name','TEMPER Prop Factor Plot','NumberTitle','off')
    hfm = findobj('Name','TEMPER Prop Factor Plot');
else
    figure(hfm(1))
end
clf
if subp==1  % subplot used for multi-plot mode of TEMPER Field Reader GUI
    subplot(2,3,[1 2])
    set(gca,'Position',[.06 .5838 .5642 .3412]);
    ss=get(0,'ScreenSize');
    set(hfm,'Position',[5 ss(4)*.5-75 ss(3)*.75 ss(4)*.5]);
end
hold on
% 
% if length(d.pf)>1.e6
%     if clrbar==1
%         ha = pcolor_fast_fld3(d.r(1:n)*xcon,ch*d.h(1:m)*ycon,Fscaled,'Colormap',pfm,...
%             'CLim',clim,'colorbar','horiz');
%     else
%         ha = pcolor_fast_fld3(d.r(1:n)*xcon,ch*d.h(1:m)*ycon,Fscaled,'Colormap',pfm,...
%             'CLim',clim);
%     end
% else
    Fnew=[Fscaled Fscaled(:,n); Fscaled(m,:) Fscaled(m,n)];
    clear Fscaled
    plotrange=[d.r; 2*d.r(n)-d.r(n-1)];
    plotheight=[d.h; 2*d.h(m)-d.h(m-1)];
    plotrange2=zeros(length(plotrange),1);
    plotheight2=zeros(length(plotheight),1);
    plotrange2(1)=plotrange(1)-(plotrange(2)-plotrange(1))/2;
    plotheight2(1)=plotheight(1)-(plotheight(2)-plotheight(1))/2;
    for i=2:length(plotrange)
        plotrange2(i)=plotrange(i)-(plotrange(i)-plotrange(i-1))/2;
    end
    for i=2:length(plotheight)
        plotheight2(i)=plotheight(i)-(plotheight(i)-plotheight(i-1))/2;
    end    
    surf(plotrange2*xcon, ch*plotheight2*ycon, zeros(m+1,n+1),double(Fnew));
    view(2);
%     set(gca,'XLim',[d.head.rmin*xcon d.head.rmax*xcon])
%     set(gca,'YLim',ch*[(d.head.zmin+d.head.teroff)*ycon (d.head.zmax+d.head.teroff)*ycon])
    set(gca,'XLim',[d.r(1)*xcon d.r(end)*xcon])
    set(gca,'YLim',ch*[d.h(1)*ycon d.h(end)*ycon])    
    
    set(gca,'Box','on','Tickdir','out')
    set(gcf,'renderer','zbuffer','backingstore','on')
    set(gca,'color',land);
    shading flat
    grid on
    colormap(pfm)
    caxis(clim)
    if ~isempty(d.t)
        plot(d.r*xcon,ch*d.t*ycon,'k')
    end
    if clrbar==1
        hc = colorbar('Location','EastOutside');
        hb = findobj(get(hc,'Title'),'type','text');
        set(hb,'Units','Normalized');
        set(hb,'VerticalAlignment','middle','HorizontalAlignment','center','Rotation',90);
        if fscale==2
            if disp_pl==0
                set(hb,'String','One-Way Propagation Factor (F^2) [dB]');
            else
                set(hb,'String','One-Way Propagation Loss [dB]');
            end
        elseif fscale==4
            if disp_pl==0
                set(hb,'String','Two-Way Propagation Factor (F^4) [dB]');
            else
                set(hb,'String','Two-Way Propagation Loss [dB]');
            end
        else
            if disp_pl==0
                set(hb,'String','Pattern Propagation Factor (F) [dB]');
            else
                set(hb,'String','Pattern Propagation Loss [dB]');
            end
        end
        set(hb,'Position',[2.5 0.5 0]);
    end
%end

xlabel(['Range [',rlab,']'])
ylabel(['Altitude [',deblank(hprefix),zlab,']'])
title(deblank(d.head.title),'Interpreter','none')

if cat==1
    v = [f.head.rmin, f.head.rmin]*xcon;
    w = [f.head.zmin, f.head.zmax]*ch*ycon;
    plot(v,w,'w--')
    title([deblank(e.head.title),'; ',deblank(f.head.title)],'Interpreter','none')
end
return
