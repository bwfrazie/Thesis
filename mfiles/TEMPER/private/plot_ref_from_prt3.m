function D = plot_ref_from_prt3(varargin)
%  Displays a plot of refractivity profiles read from a .prt file
%
%  Use:    D = plot_ref(file,...);
%
%  Optional Input parameters:
%
%  file   = string containing TEMPER "PRT" file to be plotted
%
%  interp = 0 (no interpolation lines), or
%         = 1 (draw interpolation lines)
%
%  ThreeD = 0 (don't draw 3D plot of data - if applicable)
%         = 1 (draw 3D plot of data - if applicable)
%         = 2 (draw 3D plot of data and view it in motion - if applicable)
%
%  subp = 0 (normal mode)
%       = 1 (used for Multi-Plot mode in TEMPER Field File GUI)
%
%  disp_units = 0 (default) use what was used in the original .ref file
%             = 1 use units of ft/nmi
%             = 2 use units of m/km
%             = 3 use units of ft/dmi
%
%  If no input parameters specified, dialog box will come up to
%  allow interactive selection of PRT file, and interp is set to 0
%
%  All data is returned in structure D:
%
%      file: name of data file plotted
%   reffile: name of original refractivity file
%     distu: units of distance: english (nmi/feet) or metric (meters/km)
%      refu: units of refractivity: M- or N-units
%     range: vector of ranges for each profile
%  altitude: vector of altitudes for each profile
%    refrac: vector of refractivity for each profile
%      extn: type of extension to higher altitude (4/3-earth or top-most
%            gradient)
%
%  last modified 20 Aug 2008 (TRH)

subp=0;
interp=0;
ThreeD=1;
disp_units=0;
silence=0;
extrap=0;
extrap2=0;
if nargin==0
    [fname,pname] = uigetfile({'*.prt'},'Load TEMPER Print File');
    if fname == 0
        file = '';
        return
    else
        file = [pname fname];
    end
else
    file=varargin{1};
    for i=2:length(varargin)
        if ischar(varargin{i})
            if strmatch(varargin{i},'interp')
                interp = 1;
            elseif strmatch(varargin{i},'ThreeD')|strmatch(varargin{i},'3D')|strmatch(varargin{i},'3d')
                ThreeD = 1;
            elseif strmatch(varargin{i},'3Dmove')
                ThreeD = 2;
            elseif strmatch(varargin{i},'no3D')|strmatch(varargin{i},'no3d')|strmatch(varargin{i},'noThreeD')
                ThreeD = 0;                
            elseif strmatch(varargin{i},'subp')
                subp = 1;
            elseif strmatch(varargin{i},'feet')
                disp_units = 1;
            elseif strmatch(varargin{i},'meters')
                disp_units = 2;
            elseif strmatch(varargin{i},'data miles')
                disp_units = 3;
            elseif strmatch(varargin{i},'silence')
                silence = 1;
            end
        end
    end
end
fsize = 12; % font size

%----------------------------------------------------------------
%  Load the data
%----------------------------------------------------------------

fid = fopen(file, 'rt');
y = 0;
stdatm = 0;
while feof(fid) == 0
    junk = fgetl(fid);
    match = findstr(junk, '   ***  Refractivity Information  ***');
    if match == 1
        break
    end
end
junk = fgetl(fid); % blank line
junk = fgetl(fid);
reffilename = junk(38:length(junk));
junk = fgetl(fid);
nprof = str2double(junk(23:length(junk)));
junk = fgetl(fid);
refunits = junk(34);
junk = fgetl(fid);
hgtunits = junk(34:length(junk));
while feof(fid) == 0
    junk = fgetl(fid);
    if ~isempty(junk)
        if strmatch(junk(2:5),'When')
            break
        elseif strmatch(junk(1:14),' This is a 4/3')
            D = ['stdatm'];
            return
            break
        end
    end
    y=y+1;
end
if y == 1 && silence == 0
    warndlg('Refractivity Information Not Displayed in .prt File')
    D=[];
    return
elseif y == 1
    D=[];
    return
end
npts=(y-1)/nprof-3;
fseek(fid,0,-1);
while feof(fid) == 0
    junk = fgetl(fid);
    match = findstr(junk, '   ***  Field File Output Parameters  ***');
    if match == 1
        break
    end
end
for i=1:6
    junk = fgetl(fid);
end
maxalt=sscanf(junk(19:length(junk)),'%f');
maxaltunits=sscanf(junk(30:33),'%c');
if strmatch(hgtunits,maxaltunits)
elseif strmatch(hgtunits,'m   ')
    maxalt=maxalt*0.3048;
else
    maxalt=maxalt/0.3048;
end
while feof(fid) == 0
    junk = fgetl(fid);
    match = findstr(junk, '   ***  Refractivity Information  ***');
    if match == 1
        break
    end
end
for i=1:6
    junk = fgetl(fid);
end
if strmatch(hgtunits,'m   ') 
    dru(2)=1;
else
    dru(2)=0;
end
if strmatch(refunits,'N   ')
    dru(1)=0;
else
    dru(1)=1;
end
rng=zeros(nprof,1);
alt=zeros(nprof,npts);
ref=zeros(nprof,npts);
for i=1:nprof
    junk = fgetl(fid);
    rng(i)=sscanf(junk(19:length(junk)),'%f');
    junk = fgetl(fid);
    tmp = fscanf(fid,'%f %f %f %f',[4 1]);
    alt(i,1) = tmp (dru(2)+1,1);
    ref(i,1) = tmp (dru(1)+3,1);
    junk = fgetl(fid);
    tmp=fscanf(fid,'%f %f %f %f %f %f',[6,npts-1]);
    alt(i,2:npts)=tmp(dru(2)+1,:);
    ref(i,2:npts)=tmp(dru(1)+3,:);
    junk = fgetl(fid);
    junk = fgetl(fid);
    clear junk tmp
end
junk = fgetl(fid);
exten = sscanf(junk(52),'%c');
if strcmp(exten,'4')
    extension_type = '4/3-earth';
    extrap2=1;
elseif strcmp(exten,'t')
    extension_type = 'top-most gradient';
    extrap2=2;
end
fclose(fid);
clear junk tmp

for i = 1:npts
    if alt(:,i) >= maxalt
        npts2=i;
        break
    end
end
if max(alt(:,npts)) < maxalt % specified refractivity profile not high enough, extrapolation used
    extrap = 1;
else
    npts = npts2;
    tempalt=alt;
    clear alt
    tempref=ref;
    clear ref
    alt=tempalt(:,1:npts);
    ref=tempref(:,1:npts);
end

if strmatch(hgtunits,'m   ') 
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
hmax = max(alt(:,npts))*ycon;

% put in structure
clen = char('English','Metric'); cref = char('N-units','M-units');

D = struct('file',file,'reffile',reffilename,'distu',clen(dru(2)+1,:),'refu',cref(dru(1)+1,:),...
    'range',rng,'altitude',alt,'refrac',ref,'extn',extension_type);

x=findstr(filesep,file);
y=findstr(filesep,reffilename);
if isempty(y)
    tfile = [file(x(length(x))+1:length(file)) ' (' reffilename ')'];
    if length(tfile > 40)
        tfile = [reffilename ' (from .prt)'];
    end
else
    tfile = [file(x(length(x))+1:length(file)) ' (' reffilename(y(length(y))+1:length(reffilename)) ')'];
    if length(tfile > 40)
        tfile = [reffilename(y(length(y))+1:length(reffilename)) ' (from .prt)'];
    end
end

%----------------------------------------------------------------
%  Plot the data
%----------------------------------------------------------------
if subp==0
    hfm = findobj('Name','Refractivity Data Plot');
    if isempty(hfm)
        hfm = figure('Name','Refractivity Data Plot','NumberTitle','off');
        set(hfm,'units','normalized','position',[0.61      0.39333      0.33625      0.51667])
    else
        figure(hfm)
    end
    clf
else
    subplot(2,3,5)
    fsize=10;
end
hold on
grid on
zoom on

if hmax>1000
    scale = 1/1000;
    ymod = 'k';
else
    scale = 1;
    ymod = [];
end

% the case when there is more than one profile (i.e. range-dependent)
if nprof>1
    if subp == 0
        rat = 0.4;	% conversion constant: how many M units per range unit
        for i=1:nprof
            plot( rng(i)*xcon+rat*(ref(i,:)-(ref(i,1))), alt(i,:)*scale*ycon )
        end

        %  This plots "interpolation" lines
        if interp==1
            nstrt = 5;
            while alt(1,nstrt)<0.05*alt(1,npts)
                nstrt = nstrt + 1;
            end
            for i=nstrt:5:npts
                plot( rng(:)*xcon+rat*(ref(:,i)-(ref(:,1))), alt(:,i)*scale*ycon, 'm' )
            end
        end
        
        hold off
        set(gca,'Box','on','Ylim',[0 hmax*scale],'FontSize',fsize)	% fixes the y-axis scale
        xlabel(['Range [',rlab,']'],'FontSize',fsize)
        ylabel(['Altitude [',deblank(ymod),zlab,']'],'FontSize',fsize)
        title(tfile,'FontSize',fsize,'interpreter','none')
        orient landscape

        %----------------------------------------------------------------
        %  M-units scale
        %----------------------------------------------------------------

        hmax = hmax*scale;
        xlim = get(gca,'Xlim');
        dx = xlim(2) - xlim(1);
        mscale = 10;
        while mscale < 0.5*dx
            mscale = 2*mscale;
        end
        rat = rat/2;
        xloc(1,1) = xlim(1);
        xloc(2,1) = xlim(1) + mscale * rat;
        yloc(1,1) = hmax + .02 * hmax;
        yloc(2,1) = yloc(1,1);
        hlinea = line(xloc, yloc, 'clipping','off');

        xloc(1,1) = xlim(1);
        xloc(2,1) = xlim(1);
        yloc(1,1) = hmax + .02 * hmax;
        yloc(2,1) = hmax + .04 * hmax;
        hlineb = line(xloc, yloc, 'clipping','off');

        xloc(1,1) = xlim(1) + mscale * rat;
        xloc(2,1) = xlim(1) + mscale * rat;
        yloc(1,1) = hmax + .02 * hmax;
        yloc(2,1) = hmax + .04 * hmax;
        hlinec = line(xloc, yloc, 'clipping','off');

        text(xlim(1), hmax+.06*hmax, '340',...
            'HorizontalAlignment','Center','FontSize',fsize)
        text(xlim(1)+mscale*rat, hmax+.06*hmax, ...
            num2str(340+mscale/2), 'HorizontalAlignment','Center','FontSize',fsize)
        text(xlim(1)+mscale*rat/2, hmax+.06*hmax, 'M',...
            'HorizontalAlignment','Center','FontSize',fsize)
    end
    if ThreeD==1||ThreeD==2
        if subp == 0
            hfm = findobj('Name','Refractivity Data Plot (3D)');
            if isempty(hfm)
                hfm = figure('Name','Refractivity Data Plot (3D)','NumberTitle','off');
                set(hfm,'units','normalized','position',[0.61-.337      0.39333      0.33625      0.51667])
            else
                figure(hfm)
            end
            clf
            zoom on
        end
        hmax = max(alt(:,npts))*ycon;
        if hmax>1000
            scale = 1/1000;
            ymod = 'k';
        else
            scale = 1;
            ymod = [];
        end
        hold on
        grid on
        if strcmp(zlab,'ft')
            dru(2)=0;
        else
            dru(2)=1;
        end
        mesh(rng*ones(1,npts)*xcon,ref,alt*scale*ycon,ref)
        xlabel(['Range [',rlab,']'],'FontSize',fsize)
        zlabel(['Altitude [',deblank(ymod),zlab,']'],'FontSize',fsize)
        shading interp
        maxalt=maxalt*ycon;
        rgrad = [-11.9 -39; 36 118];
        if extrap2 == 2
            rgrad = (ref(npts)-ref(npts-1))/((alt(npts)-alt(npts-1))*ycon)*1000*ones(2,2);
        end
        if extrap ~= 0
            for i=1:nprof
                ref2(i,:)=linspace(ref(i,npts),ref(i,npts)+((maxalt-hmax)*rgrad(dru(1)+1,dru(2)+1)/1000),2);
                alt2(i,:)=linspace(hmax*scale,maxalt*scale,2);
            end
            mesh(rng*ones(1,2)*xcon,ref2,alt2,ref2,'LineStyle','--')
            refmin=min([min(ref) min(ref2)]);
            refmax=max([max(ref) max(ref2)]);
        else
            refmin=min(min(ref));
            refmax=max(max(ref));
        end
        shading interp        
        set(gca,'Zlim',[0 maxalt*scale],'Xlim',[rng(1) rng(length(rng))]*xcon*1.1,'Ylim',[refmin-(refmax-refmin)*0.1 refmax+(refmax-refmin)*0.1])
        refstr = char('Refractivity [N]','Modified Refractivity [M]');
        ylabel(refstr(dru(1)+1,:),'FontSize',fsize)
        hidden off
        rotate3d on
        title(tfile,'FontSize',fsize,'interpreter','none')

        if ThreeD==2  % Used for multi-plots
            for i=130:-5:60
                view(i,7)
                pause(0.05)
            end
        else
            view(78,13)
        end
    end
    
    % the case where there is only one profile
else
    maxalt=maxalt*ycon;
    rgrad = [-11.9 -39; 36 118];
    refstr = char('Refractivity [N]','Modified Refractivity [M]');
    if strcmp(zlab,'ft')
        dru(2)=0;
    else
        dru(2)=1;
    end
    plot(ref(1,:),alt(1,:)*scale*ycon,'-bo','MarkerFaceColor','b','MarkerSize',3)
    sa2 = [[ref(1,1) ref(1,1)+(maxalt*rgrad(dru(1)+1,dru(2)+1)/1000)]' [0 maxalt]'];
    plot(sa2(:,1),sa2(:,2)*scale,'r--');
    if extrap2 == 2
        rgrad = (ref(npts)-ref(npts-1))/((alt(npts)-alt(npts-1))*ycon)*1000*ones(2,2); 
    end
    if extrap ~= 0
        sa = [[ref(1,npts) ref(1,npts)+((maxalt-hmax)*rgrad(dru(1)+1,dru(2)+1)/1000)]' [hmax maxalt]'];
        plot(sa(:,1),sa(:,2)*scale,'b--');
        legend('Data','4/3-earth','Extrapolation',0)
    else
        legend('Data','4/3-earth',0)
    end
    hold off
    set(gca,'Box','on','Ylim',[0 maxalt*scale],'FontSize',fsize)	% fixes the y-axis scale
    ylabel(['Altitude [',deblank(ymod),zlab,']'],'FontSize',fsize)
    xlabel(refstr(dru(1)+1,:),'FontSize',fsize)
    title(tfile,'FontSize',fsize,'interpreter','none')
    orient tall
end
return
