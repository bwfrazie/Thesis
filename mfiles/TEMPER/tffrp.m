function varargout = tffrp(varargin)
%tffrp - TEMPER Field File Reader/Plotter GUI
%
%
% USE: hFig = tffrp;
%
%   Call without any inputs to launch the TEMPER Field Reader/Plotter GUI. See
%   the TFFRP User Guide for more information.
%
%
% USE: tffrp( 'callback_name', ...) 
%
%   Invoke the named callback. This mode is only used by GUI callbacks, it is
%   not intended for user calls.
%
%
% (c)2008-2016, Johns Hopkins University / Applied Physics Lab
% Contact: apl.temper@jhuapl.edu
% Last update: 2016-01-11



% Update list: (all TRH unless otherwise noted)
% -----------
% 2008-08-05 - Major capability update (v1.32).
% 2011-03-22 - Added widgets to accommodate new range/altitude selection
% capability of tdata31. Fixed numerous bugs and added capability to use slider
% on zoomed-in PFcut plots without changing axis settings.  Removed check for 
% redundant dependencies by placing needing files into "private" folder. 
% Replaced str2num() and str2double() with eval() to accept things like '2^4'.
% 2011-04-07 - Added Copy Fig. button to Coverage Cuts and added functionality 
% to limit the # of instances of tffrp to 1. Added case-handling code for when
% global 'temperdata' variable exists prior to opening GUI.
% 2014-12-19 - Added check of MATLAB version; exits if ver >= 8.4.0 (R2014b).
% 2014-12-27 - (JZG) Added edit() call to open .prt files when ~ispc.
% 2015-02-09 - (JZG) Changed the way multi-line plots look and removed 24-line
% limit. See the new get_colors_and_linetypes() subroutine for details.
% 2015-02-21 - (JZG) Removed 2014-12-19 exit when running in R2014b, shifted
% uipanels to top of tffrp_LayoutFcn() & created r2014b_fix_panels(), panels no
% longer obscur controls in new Matlab versions. Removed copy-&-paste code 
% from pushbutton13_Callback (Close plots) pushbutton15_Callback (Copy fig.) &
% fixed minor bugs in each of these subroutines. Made GUI automatically fill
% file lists for CD without making user hit "Select" button after starting GUI.
% 2016-01-11 - (JZG) Adapt to tdata31 update for partial .fld files.
% 2016-02-02 - (JZG) Fixed bug in my recent update for y-axis dir of OWPF plots.


%-------------------------------------------------------------------------------
% TODO: see comment block at end of function
%-------------------------------------------------------------------------------


%-------------------------------------------------
% Last Modified by GUIDE v2.5 27-Aug-2008 13:34:59
%-------------------------------------------------


global handles hd version pickfiles loadoverride
version = char('Version 3.2','21 February 2015',...
    'TR Hanley, KA Griffith, JZ Gehman, MH Newkirk');
loadoverride = 0;

hd = struct('h_window',  findobj(gcbf,'Tag','Fld_read_window'),...
    'foldername',findobj(gcbf,'Tag','edit1'),...
    'filelist',  findobj(gcbf,'Tag','listbox1'),...
    'picklist',  findobj(gcbf,'Tag','listbox2'),...
    'filesztxt', findobj(gcbf,'Tag','text3'),...
    'filesize',  findobj(gcbf,'Tag','text4'),...
    'propfact',  findobj(gcbf,'Tag','radiobutton1'),...
    'proploss',  findobj(gcbf,'Tag','radiobutton2'),...
    'prefalt',   findobj(gcbf,'Tag','radiobutton5'),...
    'prefrng',   findobj(gcbf,'Tag','radiobutton6'),...
    'despts',    findobj(gcbf,'Tag','radiobutton7'),...
    'totalpts',  findobj(gcbf,'Tag','radiobutton8'),...
    'autodb',    findobj(gcbf,'Tag','checkbox1'),...
    'autothin',  findobj(gcbf,'Tag','checkbox2'),...
    'rngsel',    findobj(gcbf,'Tag','checkbox3'),...
    'altsel',    findobj(gcbf,'Tag','checkbox4'),...
    'mindb',     findobj(gcbf,'Tag','edit2'),...
    'maxdb',     findobj(gcbf,'Tag','edit3'),...
    'pfcuts',    findobj(gcbf,'Tag','togglebutton1'),...
    'rngcut',    findobj(gcbf,'Tag','radiobutton3'),...
    'altcut',    findobj(gcbf,'Tag','radiobutton4'),...
    'slider',    findobj(gcbf,'Tag','slider1'),...
    'minsld',    findobj(gcbf,'Tag','text10'),...
    'maxsld',    findobj(gcbf,'Tag','text11'),...
    'step',      findobj(gcbf,'Tag','edit4'),...
    'value',     findobj(gcbf,'Tag','edit5'),...
    'units',     findobj(gcbf,'Tag','text16'),...
    'nptsrng',   findobj(gcbf,'Tag','text23'),...
    'nptshgt',   findobj(gcbf,'Tag','text24'),...
    'thinfac',   findobj(gcbf,'Tag','text25'),...
    'thinpref',  findobj(gcbf,'Tag','text29'),...
    'thnrngtxt', findobj(gcbf,'Tag','text31'),...
    'thnalttxt', findobj(gcbf,'Tag','text32'),...
    'thinrng',   findobj(gcbf,'Tag','edit6'),...
    'thinalt',   findobj(gcbf,'Tag','edit7'),...
    'desrng',    findobj(gcbf,'Tag','edit9'),...
    'desalt',    findobj(gcbf,'Tag','edit10'),...
    'destot',    findobj(gcbf,'Tag','edit11'),...
    'minrngsel', findobj(gcbf,'Tag','edit12'),...
    'maxrngsel', findobj(gcbf,'Tag','edit13'),...
    'text_to34', findobj(gcbf,'Tag','text34'),...
    'text_to35', findobj(gcbf,'Tag','text35'),...
    'minaltsel', findobj(gcbf,'Tag','edit16'),...
    'maxaltsel', findobj(gcbf,'Tag','edit17'),...
    'copyfig',   findobj(gcbf,'Tag','pushbutton15'),...
    'ff2f4',     findobj(gcbf,'Tag','popupmenu1'),...
    'funits',    findobj(gcbf,'Tag','popupmenu2'),...
    'rngselunits',findobj(gcbf,'Tag','popupmenu3'),...
    'altselunits',findobj(gcbf,'Tag','popupmenu5'));

 
if nargin == 0  % LAUNCH GUI    
    
    fig = openfig(mfilename,'reuse');
    if isempty(fig)  % 'temperdata' exists and user does not wish to overwrite 
        return
    end
    figure(fig); % Make this the current figure
    
    % Set figure position based on current screen size
    set(fig,'Units','pixels');
    a = get(0,'ScreenSize');
    pos = get(fig,'Position');
    p = round(pos);
    b = [(a(3)-p(3))/2, (a(4)-p(4))/2, p(3), p(4)];
    set(fig,'Position',b);

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    
    guidata(fig, handles);
    
    % New, as of 2015-02-21, populate GUI with current dir before returning
    set(hd.foldername,'string',cd)
    pushbutton12_Callback(findobj(gcbf,'Tag','pushbutton12'), 0, 0);
    % ^^^ see also pushbutton3_Callback()
    
    if nargout > 0
        varargout{1} = fig;
    end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end
end

return





%_________________________________________________________________________
%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and
%| sets objects' callback properties to call them through the FEVAL
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'Fld_read_window_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.Fld_read_window, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.
%_________________________________________________________________________





function varargout = pushbutton2_Callback(h, eventdata, handles, varargin) %HELP
helpdlg('See Users Guide or contact apl.temper@jhuapl.edu','FLD_Read Help');
return





function varargout = listbox1_Callback(h, eventdata, handles, varargin) %AVAILABLE FILES
global hd
n = get(hd.filelist,'value');
if length(get(hd.filelist,'string'))<1 || isempty(n)
    set(hd.nptshgt,'string','');
    set(hd.nptsrng,'string','');
    set(hd.filesize,'string','');
    set(hd.thinalt,'string','1');
    set(hd.thinrng,'string','1');
    return
end
set(hd.filesize,'Enable','on')
set(hd.filesztxt,'Enable','on')
x = get(hd.filelist,'string');
d = get(hd.foldername,'string');
for i=1:length(n)
    % tdata31( file, tha, thr, hdr==1 ) -> "Info" mode
    t = tdata31(fullfile(d,x{n(i)}),1,1,1);
    b = dir(x{n(i)});
    q(i) = round(b.bytes/1024);
    q1(i) = t.nr;
    q2(i) = t.nz;
end
if std(q)==0
    set(hd.filesize,'string',num2str(q(1)));
else
    set(hd.filesize,'string','mult.');
end
if std(q1)==0
    set(hd.nptsrng,'string',num2str(t.nr));
else
    set(hd.nptsrng,'string','mult.');
end
if std(q2)==0
    set(hd.nptshgt,'string',num2str(t.nz));
else
    set(hd.nptshgt,'string','mult.');
end
if strcmp(get(hd.thinalt,'string'),'mult.')
    set(hd.thinalt,'string','1');
end
if strcmp(get(hd.thinrng,'string'),'mult.')
    set(hd.thinrng,'string','1');
end

% double clicking on a file automatically moves it to the selected list
if strcmp(get(hd.h_window,'SelectionType'),'open')
    pushbutton4_Callback(findobj(gcbf,'Tag','pushbutton4'), 0, 0);
    set(hd.h_window,'SelectionType','normal');
    listbox2_Callback(hd.picklist, 0, 0, 0);
end
return





function varargout = listbox2_Callback(h, eventdata, handles, varargin) %SELECTED FILES
global pickfiles hd
n = get(hd.picklist,'value');
set(hd.filesize,'Enable','off')
set(hd.filesztxt,'Enable','off')
if length(get(hd.picklist,'string'))<1 || isempty(n)
    set(hd.pfcuts,'value',0);
    togglebutton1_Callback;
    return
end
for i=1:length(n)
    q1(i) = pickfiles(1,n(i)).data.head.thinned_nr;
    q2(i) = pickfiles(1,n(i)).data.head.thinned_nz;
    thinr(i) = pickfiles(1,n(i)).data.head.thinned_rinc / ...
               pickfiles(1,n(i)).data.head.rinc;
    thinz(i) = pickfiles(1,n(i)).data.head.thinned_zinc / ...
               pickfiles(1,n(i)).data.head.zinc;
end
if std(q1)==0
    set(hd.nptsrng,'string',num2str(q1(1)));
else
    set(hd.nptsrng,'string','mult.');
end
if std(q2)==0
    set(hd.nptshgt,'string',num2str(q2(1)));
else
    set(hd.nptshgt,'string','mult.');
end
if std(thinr)==0
    set(hd.thinrng,'string',num2str(thinr(1)));
else
    set(hd.thinrng,'string','mult.');
end
if std(thinz)==0
    set(hd.thinalt,'string',num2str(thinz(1)));
else
    set(hd.thinalt,'string','mult.');
end
% if get(hd.pfcuts,'value')
%     init_slider(hd);
%     plot_cuts(hd);
% end

% Double clicking on a file opens the multi-plot figure window
if strcmp(get(hd.h_window,'SelectionType'),'open')
    if get(hd.propfact,'value')
        type = 'factor';
    else
        type = 'loss';
    end
    if get(hd.autodb,'value')==0
        clim = [eval(get(hd.mindb,'string')), eval(get(hd.maxdb,'string'))];
    else
        clim = 'autodb';
    end
    if length(n)>1
        return
    end
    y = get(hd.picklist,'string');

    % search picklist for files that are restarted
    concat=0;
    thinzin=0;
    for i=1:length(n)
        if strcmp(pickfiles(n(i)).data.head.restart,'** not a restart **') == 0
            ipfile(i) = 1;
            for j = 1:length(pickfiles)
                xy = findstr(pickfiles(n(i)).data.head.restart,pickfiles(j).file);
                if ~isempty(xy)
                    concat(i) = j;
                end
            end
            % make sure that the concatenated files don't have different thinned altitudes
            if concat(i)~=0
                if pickfiles( n(i)      ).data.head.thinned_nz == ...
                   pickfiles( concat(i) ).data.head.thinned_nz
                    thinzin(i) = 1;
                end
            end
        end
    end
    if sum(concat)>0
        button = questdlg('Do you want to concatenate files?',...
            'Sequential Files Found',...
            'Yes','No','Help','Yes');
        if strcmp(button,'Help')
            helpdlg(['One of the files selected for display was created'... 
                ' using the TEMPER Restart option.  To display the data'... 
                ' from the original file in the same plot along with the'...
                ' restarted one, select "Yes" to concatenate files.'...
                ' Otherwise, the data will be displayed separately.'...
                ' The data will be concatenated for display purposes only.'],...
                'FLD_Read Help');
            uiwait
            button = questdlg('Do you want to concatenate files?','Sequential Files Found',...
                'Yes','No','Yes');
        elseif strcmp(button,'Yes')& thinzin==0
            warndlg('Files have different altitude thinning factors and cannot be concatenated')
            return
        end
    else
        button = [];
    end
    switch get(hd.ff2f4,'value')
        case 1
            Ftype='pattern';
        case 2
            Ftype='one-way';
        case 3
            Ftype='two-way';
    end
    switch get(hd.funits,'value')
        case 1
            conv='';
        case 2
            conv='feet';
        case 3
            conv='meters';   
        case 4
            conv='data miles';  
    end

    for i=1:length(n)
        if sum(concat)>0 & strcmp(button,'Yes') && thinzin==1
            if ipfile(i)==1 && concat(i)>0
                plot_field_2(pickfiles(n(i)).data,clim,'subp','new',...
                    conv,Ftype,type,'cat',pickfiles(concat(i)).data);
            elseif find(i==concat)==0
                plot_field_2(pickfiles(n(i)).data,clim,'subp','new',...
                    conv,Ftype,type);
            end
        else
            plot_field_2(pickfiles(n(i)).data,clim,'subp','new',...
                conv,Ftype,type);
        end
        hfm = findobj('Name','TEMPER Prop Factor Plot');
        newname=['TEMPER Multi Plot (' char(y(n)) ' - ' Ftype ' ' type ')'];
        set(hfm,'Name',newname)
    end

    subplot(2,3,4)
    if isempty(pickfiles(n).data.g)
        text(0,0.5,'No grazing data found in selected file')
    else
        hold on
        grid on
        set(gca,'box','on','tickdir','out','Position',[.05 .11 .26 .3412])
        if pickfiles(n(1)).data.head.units == 1
            if get(hd.funits,'value')~=2
                rlab = 'km';
                xcon = 1;
            else
                rlab = 'nmi';
                xcon = 1/1.852;
            end
        else
            if get(hd.funits,'value')~=3
                rlab = 'nmi';
                xcon = 1;
            else
                rlab = 'km';
                xcon = 1.852;
            end
        end
        if sum(concat)>0 & strcmp(button,'Yes')
            blendpoint=2*pickfiles(n).data.r(1)-pickfiles(n).data.r(2);
            for i=1:length(pickfiles(concat).data.r)
                if pickfiles(concat).data.r(i)>blendpoint
                    break
                end
            end
            Gr = [pickfiles(concat).data.g(1:i-1); pickfiles(n).data.g];
            Ra = [pickfiles(concat).data.r(1:i-1); pickfiles(n).data.r];
            plot(Ra*xcon,Gr,'b-','LineWidth',2)
        else
            plot(pickfiles(n).data.r*xcon,pickfiles(n).data.g,'b-',...
                'LineWidth',2)
        end
        
        ylabel('Grazing Angle [deg]')
        xlabel(['Range [',rlab,']'])
        title('Grazing Angle Plot')
    end
    
    subplot(2,3,[3 6])
    d=pickfiles(n).data.head;
    infor=display_info2(d);
    text(-0.1,0.5,infor(3:24,:),'Interpreter', 'none')
    axis off

    ss=get(0,'ScreenSize');
    set(hfm,'Position',[5 ss(4)*.5-75 ss(3)*.75 ss(4)*.5]);
    set(gcf,'Renderer','OpenGL','RendererMode','auto');

    [a,b,c] = fileparts(pickfiles(n(1)).file);
    t = [a,filesep,b,'.prt'];
    if exist(t,'file')~=2
        subplot(2,3,5)
        text(0,0.5,['.prt file cannot be found'],'Interpreter', 'none');
        fprintf(1,'File "%s" cannot be found\n',[b,'.prt']);
        axis off
    else
        D=plot_ref_from_prt3(t,'interp','3Dmove','subp',conv,'silence');
        if isempty(D)
            subplot(2,3,5)
            text(0,0.5,'Refractivity Information Not Displayed in .prt File')
            axis off
        elseif strcmp(D,'stdatm')
            subplot(2,3,5)
            text(0,0.5,'Standard 4/3-Earth Atmosphere')
            axis off            
        end
    end
end
return





function varargout = checkbox1_Callback(h, eventdata, handles, varargin) %AUTO DB
global hd
b = get(hd.autodb,'value');
if b==1
    set(hd.mindb,'enable','off')
    set(hd.maxdb,'enable','off')
else
    set(hd.mindb,'enable','on')
    set(hd.maxdb,'enable','on')
end
if ~isempty(get(hd.picklist,'value')) % make sure files are highlighted before trying to replot
    hfp = findobj('Name','TEMPER Prop Factor Line Plot');
    hfl = findobj('Name','TEMPER Prop Loss Line Plot');
    if ( ~isempty(hfp) && get(hd.propfact,'value') ) || ...
       ( ~isempty(hfl) && get(hd.proploss,'value') )
        plot_cuts(hd,0);
    end
end
return





function varargout = togglebutton1_Callback(h, eventdata, handles, varargin) %PF CUTS
global hd
state = get(hd.pfcuts,'value');
if state==1
    if ~isempty(get(hd.picklist,'value')) % make sure files are highlighted before trying to replot
        if length(get(hd.picklist,'string'))<1
            set(hd.pfcuts,'value',0)
            errordlg('Must highlight Selected File(s) first');
            return
        end
        set(hd.rngcut,'enable','on');
        set(hd.altcut,'enable','on');
        set(hd.slider,'enable','on');
        set(hd.step,'enable','on');
        set(hd.value,'enable','on');
        set(hd.copyfig,'enable','on');
        init_slider(hd);
        plot_cuts(hd,0);
    else
        set(hd.pfcuts,'value',0)
        errordlg('Must highlight Selected File(s) first');
        return
    end
else
    set(hd.rngcut,'enable','off');
    set(hd.altcut,'enable','off');
    set(hd.slider,'enable','off');
    set(hd.step,'enable','off','string','','value',0);
    set(hd.value,'enable','off','string','','value',0);
    set(hd.minsld,'string','');
    set(hd.maxsld,'string','');
    set(hd.units,'string','');
    set(hd.copyfig,'enable','off');
    close(findobj('Name','TEMPER Prop Factor Line Plot'));
    close(findobj('Name','TEMPER Prop Loss Line Plot'));
end
return





function varargout = radiobutton3_Callback(h, eventdata, handles, varargin) %SET RCUT
global hd
set(hd.altcut,'value',0)
set(hd.rngcut,'value',1)
if isempty(get(hd.picklist,'value')) % make sure files are highlighted before trying to replot
    errordlg('Must highlight Selected File(s) first');
    return
end
init_slider(hd);
plot_cuts(hd,0);
return





function varargout = radiobutton4_Callback(h, eventdata, handles, varargin) %SET HCUT
global hd
set(hd.altcut,'value',1)
set(hd.rngcut,'value',0)
if isempty(get(hd.picklist,'value')) % make sure files are highlighted before trying to replot
    errordlg('Must highlight Selected File(s) first');
    return
end
init_slider(hd);
plot_cuts(hd,0);
return





function varargout = slider1_Callback(h, eventdata, handles, varargin) %SLIDER
global pickfiles hd
minval = 9e9;
maxval = -9e9;
abscissa = [];
npx = 0;
y = get(hd.slider,'Value');
type = get(hd.altcut,'Value');
n = get(hd.picklist,'value');
if isempty(n) % make sure files are highlighted before trying to replot
    errordlg('Must highlight Selected File(s) first');
    return
end
unitchoice=get(hd.funits,'value');
[rlab zlab rconv zconv] = normalize_temper_units(pickfiles,n,unitchoice);
if rlab==0
    errordlg('Files contain different units.  Please specify plotting units.',...
        'Data Not Displayed')
    return
end
if type==1
    for i=1:length(n)
        minval = min(minval,pickfiles(n(i)).data.h(1)*zconv(i));
        maxval = max(maxval,pickfiles(n(i)).data.h(pickfiles(n(i)).data.head.thinned_nz)*zconv(i));
        aa = pickfiles(n(i)).data.h*zconv(i);
        abscissa = [abscissa', aa']';
    end
    hh = unique(abscissa);
    npx = length(hh);
    ix = round(y*(npx-1)+1);
    set(hd.step,'string',num2str(ix));
    set(hd.value,'string',num2str(hh(ix),'%6.2f'));
else
    for i=1:length(n)
        minval = min(minval,pickfiles(n(i)).data.r(1)*rconv(i));
        maxval = max(maxval,pickfiles(n(i)).data.r(pickfiles(n(i)).data.head.thinned_nr)*rconv(i));
        aa = pickfiles(n(i)).data.r*rconv(i);
        abscissa = [abscissa', aa']';
    end
    rr = unique(abscissa);
    npx = length(rr);
    ix = round(y*(npx-1)+1);
    set(hd.step,'string',num2str(ix));
    set(hd.value,'string',num2str(rr(ix),'%6.2f'));
end
init_slider(hd);
plot_cuts(hd,1);
return





function varargout = edit4_Callback(h, eventdata, handles, varargin) %PICK STEP
global pickfiles hd
minval = 9e9;
maxval = -9e9;
abscissa = [];
npx = 0;
ix = round(eval(get(hd.step,'string')));
n = get(hd.picklist,'value');
if isempty(n) % make sure files are highlighted before trying to replot
    errordlg('Must highlight Selected File(s) first');
    return
end
type = get(hd.altcut,'Value');
ix = max(ix,1);
unitchoice=get(hd.funits,'value');
[rlab zlab rconv zconv] = normalize_temper_units(pickfiles,n,unitchoice);
if rlab==0
    errordlg('Files contain different units.  Please specify plotting units.',...
        'Data Not Displayed')
    return
end
if type==1
    for i=1:length(n)
        minval = min(minval,pickfiles(n(i)).data.h(1)*zconv(i));
        maxval = max(maxval,pickfiles(n(i)).data.h(pickfiles(n(i)).data.head.thinned_nz)*zconv(i));
        aa = pickfiles(n(i)).data.h*zconv(i);
        abscissa = [abscissa', aa']';
    end
    hh = unique(abscissa);
    npx = length(hh);
    ix = min(ix,npx);
    set(hd.slider,'Value',(ix-1)/npx);
    set(hd.value,'string',num2str(hh(ix),'%6.2f'));
else
    for i=1:length(n)
        minval = min(minval,pickfiles(n(i)).data.r(1)*rconv(i));
        maxval = max(maxval,pickfiles(n(i)).data.r(pickfiles(n(i)).data.head.thinned_nr)*rconv(i));
        aa = pickfiles(n(i)).data.r*rconv(i);
        abscissa = [abscissa', aa']';
    end
    rr = unique(abscissa);
    npx = length(rr);
    ix = min(ix,npx);
    set(hd.value,'string',num2str(rr(ix),'%6.2f'));
    set(hd.slider,'Value',(ix)/npx);
end
set(hd.step,'string',num2str(ix));
plot_cuts(hd,0);
return





function varargout = edit5_Callback(h, eventdata, handles, varargin) %PICK VAL
global pickfiles hd
minval = 9e9;
maxval = -9e9;
abscissa = [];
npx = 0;
y = eval(get(hd.value,'string'));
n = get(hd.picklist,'value');
if isempty(n) % make sure files are highlighted before trying to replot
    errordlg('Must highlight Selected File(s) first');
    return
end
type = get(hd.altcut,'Value');
unitchoice=get(hd.funits,'value');
[rlab zlab rconv zconv] = normalize_temper_units(pickfiles,n,unitchoice);
if rlab==0
    errordlg('Files contain different units.  Please specify plotting units.',...
        'Data Not Displayed')
    return
end
if type==1
    for i=1:length(n)
        minval = min(minval,pickfiles(n(i)).data.h(1)*zconv(i));
        maxval = max(maxval,pickfiles(n(i)).data.h(pickfiles(n(i)).data.head.thinned_nz)*zconv(i));
        aa = pickfiles(n(i)).data.h*zconv(i);
        abscissa = [abscissa', aa']';
    end
    hh = unique(abscissa);
    npx = length(hh);
    [valu ix]=min(abs(y-hh));
    set(hd.slider,'Value',(ix-1)/npx);
    set(hd.value,'string',num2str(hh(ix),'%6.2f'));
else
    for i=1:length(n)
        minval = min(minval,pickfiles(n(i)).data.r(1)*rconv(i));
        maxval = max(maxval,pickfiles(n(i)).data.r(pickfiles(n(i)).data.head.thinned_nr)*rconv(i));
        aa = pickfiles(n(i)).data.r*rconv(i);
        abscissa = [abscissa', aa']';
    end
    rr = unique(abscissa);
    npx = length(rr);
    [valu ix]=min(abs(y-rr));
    set(hd.value,'string',num2str(rr(ix),'%6.2f'));
    set(hd.slider,'Value',(ix)/npx);

end
set(hd.step,'string',num2str(ix));
plot_cuts(hd,0);
return





function pushbutton3_Callback(h, eventdata, handles, varargin) %SELECT DIRECTORY
global hd
%PRE: d = uigetdir;
[f,d] = uigetfile('*.fld',['Click on any .fld file to select that',...
    ' file''s directory for ',mfilename]);
if isempty(d) | isnumeric(d) % PRE: d==0
    return
end
cd( d );
set(hd.foldername,'string',d)
pushbutton12_Callback(findobj(gcbf,'Tag','pushbutton12'), 0, 0);
return





function pushbutton12_Callback(hObject, eventdata, handles) %REFRESH FILE
% Function assumes that current directory has already been set to the desired
% directory prior to calling (see ***)

global hd loadoverride pickfiles

y = get(hd.picklist,'string');
d = get(hd.foldername,'string');

d = cd; % <------------------------ *** here's where the CD assumption is made
set(hd.foldername,'string',d);
b2 = dir('*.fld');
set(hd.filelist,'string',{b2.name},'value',length(b2));

if isempty(b2)
    helpdlg(['No field (*.fld) files found in directory ',d]);
    return
end

for i=1:length(b2)
    filedate2_2=b2(i).date;
    filedate2(i)=datenum(filedate2_2);
    x2{i}=b2(i).name;
end

ques=0;
for i=1:length(y)
    for k=1:length(x2)
        if strcmp(pickfiles(i).file,fullfile(d,x2{k})) & (pickfiles(i).timestamp~=filedate2(k))
            if pickfiles(i).timestamp>filedate2(k)
                button = questdlg(['An older version of file ',y{i},' has been found. '...
                    'Replace loaded data with that from the older file?  * If Yes, make '...
                    'sure to input the desired thinning conditions first. *'],...
                    'Older File Found','Yes','No','No');
                if strcmp(button,'Yes')
                    set(hd.filelist,'value',k);
                    loadoverride=i;
                    pushbutton4_Callback(findobj(gcbf,'Tag','pushbutton4'), 0, 0);
                end
            elseif ques == 0
                button = questdlg(['A newer version of file ',y{i},' has been found. '...
                    'Replace loaded data with that from the newer file?  * If Yes, make '...
                    'sure to input the desired thinning conditions first. *'],...
                    'Newer File Found','Yes','Yes to all','No','Yes');
                if strcmp(button,'Yes')
                    set(hd.filelist,'value',k);
                    loadoverride=i;
                    pushbutton4_Callback(findobj(gcbf,'Tag','pushbutton4'), 0, 0);
                elseif strcmp(button,'Yes to all')
                    set(hd.filelist,'value',k);
                    loadoverride=i;
                    pushbutton4_Callback(findobj(gcbf,'Tag','pushbutton4'), 0, 0);
                    ques=1;
                end
            else
                set(hd.filelist,'value',k);
                loadoverride=i;
                pushbutton4_Callback(findobj(gcbf,'Tag','pushbutton4'), 0, 0);
            end
        end
    end
end
return





function pushbutton13_Callback(hObject, eventdata, handles) %CLOSE ALL PLOTS

    allFigs = findobj('Type','Figure');
    
    if ~isempty(allFigs)
        button = questdlg('Close plots of which type?','Select Type of Plots',...
            'Refractivity','Coverage','All',...
            'All');
    else
        return
    end
    
    closeNames = {};
    
    if strcmp(button,'Refractivity') | strcmp(button,'All')
        closeNames = [closeNames,...
            { 'Refractivity Data Plot' } ];
    end
    
    if strcmp(button,'Coverage') | strcmp(button,'All')
        closeNames = [closeNames,...
            { 'TEMPER Prop Factor Plot', 'TEMPER Prop Loss Plot' } ];
    end
    
    if strcmp(button,'All')
        closeNames = [closeNames,...
            { 'TEMPER Grazing Angle Plot',...
              'TEMPER Terrain Height Plot',...
              'TEMPER Prop Loss Line Plot',...
              'TEMPER Prop Factor Line Plot',...
              'TEMPER Multi Plot' } ];
    end
    
    % Prior to 2015-02-21, there were copy-&-paste sections of code with some
    % inconsistencies, e.g. 'TEMPER Propagation Loss Line Plot' & 'TEMPER
    % Propagation Factor Line Plot' ("Propagation" vs. "Prop"). Code was changed
    % to generate a list of "closeNames" to avoid such issues.
    
    true  = (1==1);
    false = not(true);
    isToBeClosed = repmat( false, size(allFigs) );
    
    for iFig = 1:length(allFigs)
        thisName = get( allFigs(iFig), 'Name' );
        for iName = 1:length(closeNames)
            if strncmp( thisName, closeNames{iName}, length(closeNames{iName}) )
                isToBeClosed(iFig) = true;
                break;
            end
        end        
    end
    
    iClose = find( isToBeClosed );
    if ~isempty( iClose )
        closeFigs = allFigs(iClose);
        close( closeFigs );
    end
    
    %PRE: clear allFigs
    
return





function pushbutton4_Callback(hObject, eventdata, handles) %SELECT FILE
global pickfiles hd loadoverride
n = get(hd.filelist,'value');
x = get(hd.filelist,'string');
if isempty(x) || isempty(n)
    errordlg('Must highlight Available Files');
    return
end
if get(hd.rngsel,'value') == 1  % if range select enabled, get range values
    minrngsel = eval(get(hd.minrngsel,'string'));
    maxrngsel = eval(get(hd.maxrngsel,'string'));
    rngunitcnt = get(hd.rngselunits,'value');
    % check for valid units
    if rngunitcnt == 1 % Default, no units chosen
        if ~isinf(maxrngsel) | ~isinf(minrngsel)
            errordlg('Must select range units');
            return
        else
            rngunits = 'kilometers';
        end
    else
        rngunitcell = get(hd.rngselunits,'string');
        rngunits = rngunitcell{rngunitcnt,1};
    end
else
    rngunits = 'kilometers';
    minrngsel = -inf;
    maxrngsel = inf;
end
if get(hd.altsel,'value') == 1  % if altitude select enabled, get altitude values
    minaltsel = eval(get(hd.minaltsel,'string'));
    maxaltsel = eval(get(hd.maxaltsel,'string'));
    altunitcnt = get(hd.altselunits,'value');
    % check for valid units
    if altunitcnt == 1 % Default, no units chosen
        if ~isinf(maxaltsel) | ~isinf(minaltsel)
            errordlg('Must select altitude units');
            return 
        else
            altunits = 'meters';
        end
    else
        altunitcell = get(hd.altselunits,'string');
        altunits = altunitcell{altunitcnt,1};
    end
else
    altunits = 'meters';
    minaltsel = -inf;
    maxaltsel = inf;
end            
    
y = get(hd.picklist,'string');
m = length(y);
ds = cd;
d = get(hd.foldername,'string');
if (get(hd.autothin,'value'))
    if (get(hd.despts,'value'))
        if isempty(get(hd.desrng,'string'))||isempty(get(hd.desalt,'string'))
            error('Thinning # of points in range and/or altitude not inputted');
        else
            thr = -abs(round(eval(get(hd.desrng,'string'))));
            tha = -abs(round(eval(get(hd.desalt,'string'))));
        end
    elseif (get(hd.totalpts,'value'))
        if isempty(get(hd.destot,'string'))
            error('Thinning # of points not inputted');
        else
            tha = round(eval(get(hd.destot,'string')));
        end
        if get(hd.prefalt,'value')
            thr = 'A';
        elseif get(hd.prefrng,'value')
            thr = 'R';
        else
            error('Altitude or Range preference not selected')
        end
    else
        error('Auto-thinning mode not selected')
    end
else
    thr = round(eval(get(hd.thinrng,'string')));
    if isnan(thr)
        set(hd.thinrng,'string','1')
        thr=1;
    end
    tha = round(eval(get(hd.thinalt,'string')));
    if isnan(tha)
        set(hd.thinalt,'string','1')
        tha=1;
    end
end

if abs(thr)<1
    set(hd.thinrng,'string','1')
end
if abs(tha)<1
    set(hd.thinalt,'string','1')
end
cmd = ['cd ''',d,''''];
eval(cmd)
Notoall=0;
newloads=[];
for j = 1:length(n)
    q=0;
    Yes = 0;
    i = n(j);
    if loadoverride > 0
        Yes = 1;
    elseif ~isempty(pickfiles) & strfind([pickfiles.file],fullfile(d,x{i}))
        if Notoall == 0
            button = questdlg(['File ',x{i},' already loaded.  Replace?'],...
                'Replace File?','Yes','No','No to all','No to all');
            if strcmp(button,'No to all')
                Notoall = 1;
            elseif strcmp(button,'Yes')
                Yes = 1;
                for k=1:m
                    if strcmp(pickfiles(k).file,fullfile(d,x{i}))
                        q=k;
                    end
                end
            end
        end
    else 
        Yes = 1;
    end
    if Yes == 1  
        if evalin('base',['exist(','''temperdata''',',','''var''',')']) == 1
            if evalin('base','isstruct(temperdata)') == 0 | ...
               evalin('base',['isfield(temperdata,','''file''',')']) == 0
                button = questdlg(...
                    ['''temperdata''',' variable already exists - overwrite?'],...
                    'Overwrite?','Yes','No','Yes');
                if strcmp(button,'No')
                    loadoverride=0;
                    return
                end
            end
        end
        b = dir(x{i});
        if isempty(b)
            msgbox(['File ',x{i},' cannot be found.'],'File not found');
            loadoverride=0;
            return
        else
            filedate_2=b.date;
            filedate=datenum(filedate_2);
        end
        
        if loadoverride > 0
            y(loadoverride) = x(i);
            p = struct(...
                'file',fullfile(d,x{i}),...
                'data',tdata31(x{i},tha,thr,0,[minaltsel maxaltsel],altunits,[minrngsel maxrngsel],rngunits,'warning'),...
                'timestamp',filedate);
            [msz,nsz]=size(p.data.fdb);
            if msz==1 || nsz==1
                errordlg('Cannot load data sets with only one range or altitude data point');
                return
            end
            pickfiles(loadoverride) = p;      
            set(hd.picklist,'value',m,'string',y)  
            newloads=[newloads loadoverride];
        elseif m>0 && q==0
            y(length(y)+1) = x(i);
            p = struct(...
                'file',fullfile(d,x{i}),...
                'data',tdata31(x{i},tha,thr,0,[minaltsel maxaltsel],altunits,[minrngsel maxrngsel],rngunits,'warning'),...
                'timestamp',filedate);
            [msz,nsz]=size(p.data.fdb);
            if msz==1 || nsz==1
                errordlg('Cannot load data sets with only one range or altitude data point');
                return
            end
            pickfiles(length(y)) = p;
            set(hd.picklist,'value',m+1,'string',y)
            newloads=[newloads length(y)];
        elseif q > 0
            y(q) = x(i);
            p = struct(...
                'file',fullfile(d,x{i}),...
                'data',tdata31(x{i},tha,thr,0,[minaltsel maxaltsel],altunits,[minrngsel maxrngsel],rngunits,'warning'),...
                'timestamp',filedate);
            [msz,nsz]=size(p.data.fdb);
            if msz==1 || nsz==1
                errordlg('Cannot load data sets with only one range or altitude data point');
                return
            end
            pickfiles(q) = p;      
            set(hd.picklist,'value',m,'string',y)
            newloads=[newloads q];

        else
            y = x(i);
            pickfiles = struct(...
                'file',fullfile(d,y{1}),...
                'data',tdata31(y{1},tha,thr,0,[minaltsel maxaltsel],altunits,[minrngsel maxrngsel],rngunits,'warning'),...
                'timestamp',filedate);
            [msz,nsz]=size(pickfiles.data.fdb);
            if msz==1 || nsz==1
                errordlg('Cannot load data sets with only one range or altitude data point');
                return
            end
            set(hd.picklist,'value',m+1,'string',y)
            newloads=[newloads 1];
        end
        m = length(y);
        assignin('base','temperdata',pickfiles);
    end
end
if ~isempty(newloads)
    set(hd.picklist,'value',newloads);
end
loadoverride = 0;
cmd = ['cd ''',ds,''''];
eval(cmd)
return





function pushbutton5_Callback(hObject, eventdata, handles) %REMOVE FILE
global pickfiles hd
if isempty(get(hd.picklist,'value')) % make sure files are highlighted before trying to replot
    errordlg('Must highlight Selected File(s)');
    return
end
y = get(hd.picklist,'string');
m = length(y);
if m>0
    n = get(hd.picklist,'value');
    y(n) = [];
    set(hd.picklist,'value',length(y),'string',y)
    pickfiles(n) = [];
    if m>1
        assignin('base','temperdata',pickfiles);
    else
        evalin('base','clear temperdata');
    end
end
return





function pushbutton7_Callback(hObject, eventdata, handles) %FILE INFO
global hd
n = get(hd.filelist,'value');
if length(n)>1
    n = n(1);
    waitfor(warndlg('Only displaying info for first selection'));
end
x = get(hd.filelist,'string');
if isempty(x)
    errordlg('Must load files first');
    return
end
d = get(hd.foldername,'string');
% tdata31( file, tha, thr, hdr==1 ) -> "Info" mode
t = tdata31(fullfile(d,x{n}),1,1,1);
infor=display_info2(t);
msgbox(infor,'Field File Info','none');
return





function pushbutton8_Callback(hObject, eventdata, handles) %VIEW PRINT FILE
global hd
n = get(hd.filelist,'value');
x = get(hd.filelist,'string');
if isempty(x)
    errordlg('Must load files first');
    return
end
if length(n)>1
    n = n(1);
    waitfor(warndlg('Only displaying Print file for first selection'));
end
d = get(hd.foldername,'string');
[a,b,c] = fileparts(fullfile(d,x{n}));
t = [a,filesep,b,'.prt'];
if exist(t,'file')~=2
    errordlg(['File ',t, ' cannot be found']);
    return
end
if ispc
    WNT = exist('C:\Winnt');
    W98 = exist('C:\Windows');
    WXP = exist('C:\Windows') & strmatch('Windows_NT',getenv('OS'));
    if WNT==7 | WXP
        exe = 'C:\Program Files\Windows NT\Accessories\Wordpad.exe';
    elseif W98==7
        exe = 'C:\Program Files\Accessories\Wordpad.exe';
    else
        exe = 'notepad.exe';
    end
    dos(['"' exe '" "' t '" &']);
else
    %PRE: errordlg(['View *.prt functionality not supported outside of Windows OS']);
    edit( t ); % New, 2014-12-27
    % TODO: use windir.m for the PC case and make it a bit more robust by adding
    % a try-catch that falls back to edit( t )?
end
return





function pushbutton6_Callback(hObject, eventdata, handles) %COVERAGE
global pickfiles hd
if length(get(hd.picklist,'string'))<1
    set(hd.pfcuts,'value',0)
    errordlg('Must highlight a Selected File');
    return
end
y = get(hd.picklist,'string');
m = length(y);
if get(hd.propfact,'value')
    type = 'factor';
else
    type = 'loss';
end
if get(hd.autodb,'value')==0
    clim = [eval(get(hd.mindb,'string')), eval(get(hd.maxdb,'string'))];
else
    clim = 'autodb';
end
concat = zeros(m,1);
ipfile = concat;
thinzin = 0;
if m>0
    n = get(hd.picklist,'value');
    % search picklist for files that are restarted
    for i=1:length(n)
        if strcmp(pickfiles(n(i)).data.head.restart,'** not a restart **') == 0
            ipfile(i) = 1;
            for j = 1:length(n)
                xy = findstr(pickfiles(n(i)).data.head.restart,pickfiles(n(j)).file);
                if ~isempty(xy)
                    concat(i) = n(j);
                end
            end
            if concat(i)~=0
                % make sure that the concatenated files don't have different thinned altitudes
                if pickfiles(n(i)).data.head.thinned_nz==pickfiles(concat(i)).data.head.thinned_nz
                    thinzin(i) = 1;
                end
            end
        end
    end
    if sum(concat)>0
        button = questdlg('Do you want to concatenate files?','Sequential Files Found',...
            'Yes','No','Help','Yes');
        if strcmp(button,'Help')
            helpdlg(['One of the files selected for display was created'... 
                ' using the TEMPER Restart option.  To display the data'... 
                ' from the original file in the same plot along with the'...
                ' restarted one, select "Yes" to concatenate files.'...
                ' Otherwise, the data will be displayed separately.'...
                ' The data will be concatenated for display purposes only.'],'FLD_Read Help');
            uiwait
            button = questdlg('Do you want to concatenate files?','Sequential Files Found',...
                'Yes','No','Yes');
        elseif strcmp(button,'Yes') & thinzin==0
            warndlg('Files have different altitude thinning factors and cannot be concatenated')
            return
        end
    else
        button = [];
    end
    switch get(hd.ff2f4,'value')
        case 1
            Ftype='pattern';
        case 2
            Ftype='one-way';
        case 3
            Ftype='two-way';
    end
    switch get(hd.funits,'value')
        case 1
            conv='';
        case 2
            conv='feet';
        case 3
            conv='meters';   
        case 4
            conv='data miles';              
    end
    for i=1:length(n)
        if sum(concat)>0 & strcmp(button,'Yes')
            if ipfile(i)==1 && concat(i)>0
                plot_field_2(pickfiles(n(i)).data,clim,'new',conv,Ftype,type,'cat',pickfiles(concat(i)).data);
            elseif find(i==concat)==0
                plot_field_2(pickfiles(n(i)).data,clim,'new',conv,Ftype,type);
            end
        else
            plot_field_2(pickfiles(n(i)).data,clim,'new',conv,Ftype,type);
        end
        hfm = findobj('Name','TEMPER Prop Factor Plot');
        if strcmp(type, 'loss')
            newname=['TEMPER Prop Loss Plot (' char(y(n(i))) ' - ' Ftype ')'];
        else
            newname=['TEMPER Prop Factor Plot (' char(y(n(i))) ' - ' Ftype ')'];
        end
        set(hfm,'Name',newname)
    end
end
return





function radiobutton1_Callback(hObject, eventdata, handles) % SET PROP. FACTOR
global hd
set(hd.propfact,'value',1);
set(hd.proploss,'value',0);
set(hd.mindb,'string','-50');
set(hd.maxdb,'string','10');
if get(hd.pfcuts,'value') && ~isempty(get(hd.picklist,'value')) % make sure files are highlighted before trying to replot
    init_slider(hd);
    plot_cuts(hd,0);
end
return





function radiobutton2_Callback(hObject, eventdata, handles) % SET PROP. LOSS
global hd
set(hd.propfact,'value',0);
set(hd.proploss,'value',1);
set(hd.mindb,'string',num2str(40*get(hd.ff2f4,'value')));
set(hd.maxdb,'string',num2str(160*get(hd.ff2f4,'value')));
if get(hd.pfcuts,'value') && ~isempty(get(hd.picklist,'value')) % make sure files are highlighted before trying to replot
    init_slider(hd);
    plot_cuts(hd,0);
end
return





function pushbutton9_Callback(hObject, eventdata, handles) % GRAZING PLOT
global hd
if length(get(hd.picklist,'string'))<1 || isempty(get(hd.picklist,'value'))
    set(hd.pfcuts,'value',0)
    errordlg('Must highlight a Selected File');
    return
end
plot_ga(hd);
return





function pushbutton10_Callback(hObject, eventdata, handles) % TERRAIN PLOT
global hd
if length(get(hd.picklist,'string'))<1 || isempty(get(hd.picklist,'value'))
    set(hd.pfcuts,'value',0)
    errordlg('Must highlight a Selected File');
    return
end
plot_th(hd);
return





function pushbutton11_Callback(hObject, eventdata, handles) %INFO
global version
helpdlg(version,'Version Info')
return





function pushbutton1_Callback(hObject, eventdata, handles) %CLOSE
global hd 
dblcheck = questdlg([...
    'Are you sure you wish to close the TEMPER Field File Reader/Plotter?'...
    ],'Close program?','Only Close Progam',...
    'Close Program and Corresponding Plots','Cancel','Cancel');
if strcmp(dblcheck,'Cancel')
    return
elseif strcmp(dblcheck,'Close Program and Corresponding Plots')
    pushbutton13_Callback(findobj(gcbf,'Tag','pushbutton13'), 0, 0);
end
    clear global pickfiles
    if evalin('base',['exist(','''temperdata''',',','''var''',')']) == 1
        if evalin('base','isstruct(temperdata)') == 1 & evalin('base',['isfield(temperdata,','''file''',')']) == 1
            button = questdlg(['''temperdata''',' variable still in base workspace - delete?'],'Delete variable?','Yes','No','No');
            if strcmp(button,'Yes')
                evalin('base','clear temperdata');
            end
        end
    end
    set(hd.h_window,'HandleVisibility','Callback')
    clear global hd
    close
return





function edit1_Callback(hObject, eventdata, handles) % DIRECTORY NAME TEXTBOX
global hd
d = get(hd.foldername,'string');
cmd = ['cd ''',d,''''];
try
    eval(cmd);
    set(hd.foldername,'string',d)
    x = dir('*.fld');
    set(hd.filelist,'string',{x.name},'value',length(x))
catch
    disp(['Cannot CD to ' d ' (Name is nonexistent or not a directory).'])
    set(hd.foldername,'string',[]);
end
return





function varargout = checkbox3_Callback(h, eventdata, handles, varargin) %TURN ON RANGE SELECT
global hd
b = get(hd.rngsel,'value');
if b==1
    set(hd.text_to34,'enable','on')
    set(hd.minrngsel,'enable','on')
    set(hd.maxrngsel,'enable','on')
    set(hd.rngselunits,'enable','on')
else
    set(hd.text_to34,'enable','off')
    set(hd.minrngsel,'enable','off')
    set(hd.maxrngsel,'enable','off')
    set(hd.rngselunits,'enable','off')
end
return





function varargout = checkbox4_Callback(h, eventdata, handles, varargin) %TURN ON ALTITUDE SELECT
global hd
b = get(hd.altsel,'value');
if b==1
    set(hd.text_to35,'enable','on')
    set(hd.minaltsel,'enable','on')
    set(hd.maxaltsel,'enable','on')
    set(hd.altselunits,'enable','on')
else
    set(hd.text_to35,'enable','off')
    set(hd.minaltsel,'enable','off')
    set(hd.maxaltsel,'enable','off')
    set(hd.altselunits,'enable','off')
end
return





function checkbox2_Callback(hObject, eventdata, handles)  % AUTO THINNING
global hd
b = get(hd.autothin,'value');
if b==1
    set(hd.despts,'enable','on')
    set(hd.totalpts,'enable','on')
    if get(hd.despts,'value')==1
        set(hd.desrng,'enable','on')
        set(hd.desalt,'enable','on')
        set(hd.thnrngtxt,'enable','on')
        set(hd.thnalttxt,'enable','on')
    else
        set(hd.prefrng,'enable','on')
        set(hd.prefalt,'enable','on')
        set(hd.thinpref,'enable','on')
        set(hd.destot,'enable','on')
    end
    set(hd.thinfac,'enable','off')
    set(hd.thinrng,'enable','off')
    set(hd.thinalt,'enable','off')

else
    set(hd.desrng,'enable','off')
    set(hd.desalt,'enable','off')
    set(hd.prefrng,'enable','off')
    set(hd.prefalt,'enable','off')
    set(hd.despts,'enable','off')
    set(hd.thnrngtxt,'enable','off')
    set(hd.thnalttxt,'enable','off')
    set(hd.thinpref,'enable','off')
    set(hd.totalpts,'enable','off')
    set(hd.destot,'enable','off')
    set(hd.thinfac,'enable','on')
    set(hd.thinrng,'enable','on')
    set(hd.thinalt,'enable','on')
end
return





function radiobutton5_Callback(hObject, eventdata, handles) % THINNING PREF. ALT.
global hd
set(hd.prefalt,'value',1);
set(hd.prefrng,'value',0);
return





function radiobutton6_Callback(hObject, eventdata, handles) % THINNING PREF. RNG.
global hd
set(hd.prefalt,'value',0);
set(hd.prefrng,'value',1);
return





function radiobutton7_Callback(hObject, eventdata, handles) % THINNING MODE 1
global hd
set(hd.despts,'value',1);
set(hd.totalpts,'value',0);
set(hd.desrng,'enable','on')
set(hd.desalt,'enable','on')
set(hd.thnrngtxt,'enable','on')
set(hd.thnalttxt,'enable','on')
set(hd.prefrng,'enable','off')
set(hd.prefalt,'enable','off')
set(hd.thinpref,'enable','off')
set(hd.destot,'enable','off')
return





function radiobutton8_Callback(hObject, eventdata, handles) % THINNING MODE 2
global hd
set(hd.despts,'value',0);
set(hd.totalpts,'value',1);
set(hd.desrng,'enable','off')
set(hd.desalt,'enable','off')
set(hd.thnrngtxt,'enable','off')
set(hd.thnalttxt,'enable','off')
set(hd.prefrng,'enable','on')
set(hd.prefalt,'enable','on')
set(hd.thinpref,'enable','on')
set(hd.destot,'enable','on')
return





function pushbutton14_Callback(hObject, eventdata, handles)  % REFRACTIVITY
global hd pickfiles
y = get(hd.picklist,'string');
n = get(hd.picklist,'value');
if isempty(y) | isempty(n)
    set(hd.pfcuts,'value',0)
    errordlg('Must highlight a Selected File');
    return
end
switch get(hd.funits,'value')
    case 1
        conv='';
    case 2
        conv='feet';
    case 3
        conv='meters';
    case 4
        conv='data miles';
end

for i=1:length(n)
    [a,b,c] = fileparts(pickfiles(n(i)).file);
    t = [a,filesep,b,'.prt'];
    if exist(t,'file')~=2
        warndlg(['File ',t, ' cannot be found']);
    else
        D=plot_ref_from_prt3(t,'interp','ThreeD',conv);
        if isempty(D)
            errordlg('Refractivity Information Not Displayed in .prt File');
        elseif strcmp(D,'stdatm')
            helpdlg([pickfiles(n(i)).file,...
                ' only contains a standard 4/3-Earth atmosphere']);          
            % Changed from errordlg to helpdlg 2015-02-21 and put file name in
            % to make it less confusing than the old generaic "file" message.
        else
            hfm = findobj('Name','Refractivity Data Plot');
            newname=['Refractivity Data Plot (' char(y(n(i))) ')'];
            if ~isempty(hfm)
                set(hfm,'Name',newname);
    %         else
    %             figure('Name',newname,'NumberTitle','off');
            end
            hfm = findobj('Name','Refractivity Data Plot (3D)');
            if ~isempty(hfm)
                newname=['Refractivity Data Plot (3D - ' char(y(n(i))) ')'];
                set(hfm,'Name',newname)
            end
        end
    end
end
return





function pushbutton15_Callback(hObject, eventdata, handles)  % COPY PF CUTS FIGURE
    
    global hd
    
    if get(hd.proploss,'value')
        figName = 'TEMPER Prop Loss Line Plot';
    else
        figName = 'TEMPER Prop Factor Line Plot';
    end

    hCut = findobj('Name',figName);
    if isempty(hCut)
        return
    end
    
    % Code used to copy the axes & legend to a new figure. This had some hiccups
    % in R2014b. Cleaner in all versions to simply copy over the whole figure as
    % a child of the root Matlab object (0).
    hCopy = copyobj( hCut, 0 );
    
    % Bug fix: need to give the figure a different name to prevent errors if
    % user hits the slide arrows again (2015-02-21).
    %
    %   *** NOTE *** Due to the way pushbutton13_Callback() - the "Close plots"
    %   callback - works, if a string is added on to the end of the figure name
    %   here then the copied files *WILL* be closed. However, if a prefix is
    %   appended then the copied files will *NOT* be closed. For now, keeping
    %   with convention of past versions in that copies are to be closed.
    %
    newFigName = [figName,' (Copy)'];
    
    set( hCopy, 'Name',newFigName );
    
return





function edit6_Callback(hObject, eventdata, handles)
return





function edit7_Callback(hObject, eventdata, handles)
return





function edit2_Callback(hObject, eventdata, handles) % min dB
checkbox1_Callback;
return





function edit3_Callback(hObject, eventdata, handles) % max dB
checkbox1_Callback;
return





function edit9_Callback(hObject, eventdata, handles)  % DESIRED # POINTS IN RANGE
return





function edit10_Callback(hObject, eventdata, handles)  % DESIRED # POINTS IN ALT
return





function edit12_Callback(hObject, eventdata, handles)  % MIN. RANGE SELECTED
return





function edit13_Callback(hObject, eventdata, handles)  % MAX. RANGE SELECTED
return





function edit16_Callback(hObject, eventdata, handles)  % MIN. ALTITUDE SELECTED
return





function edit17_Callback(hObject, eventdata, handles)  % MAX. ALTITUDE SELECTED
return





function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return





function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return





function edit11_Callback(hObject, eventdata, handles)
return





function edit11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return





function edit12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return





function edit13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return





function edit16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return





function edit17_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return





function popupmenu1_Callback(hObject, eventdata, handles) % SELECT TYPE OF PLOT
global hd
if get(hd.pfcuts,'value')
    init_slider(hd);
    plot_cuts(hd,0);
end
return





function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return





function popupmenu2_Callback(hObject, eventdata, handles) % SELECT DISPLAY UNITS
global hd
if get(hd.pfcuts,'value')
    init_slider(hd);
    plot_cuts(hd,0);
end
return





function popupmenu2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return





function popupmenu3_Callback(hObject, eventdata, handles) % SELECT RANGE UNITS
return





function popupmenu3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return




function popupmenu5_Callback(hObject, eventdata, handles) % SELECT ALTITUDE UNITS
return




function popupmenu5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end    
return





%*******************************************************************
%*                                                                 *
%*  Slider initialization function                                 *
%*                                                                 *
%*******************************************************************
function init_slider(hd)
global pickfiles
type = get(hd.altcut,'value');
minval = 9e9;
maxval = -9e9;
abscissa = [];
npx = 0;
n = get(hd.picklist,'value');
if isempty(n) % make sure files are highlighted before trying to replot
    errordlg('Must highlight a Selected File');
    return
end
unitchoice=get(hd.funits,'value');
[rlab zlab rconv zconv] = normalize_temper_units(pickfiles,n,unitchoice);
if rlab==0
    return
end
if type==1
    for i=1:length(n)
        minval = min(minval,pickfiles(n(i)).data.h(1)*zconv(i));
        maxval = max(maxval,pickfiles(n(i)).data.h(pickfiles(n(i)).data.head.thinned_nz)*zconv(i));
        aa = pickfiles(n(i)).data.h*zconv(i);
        abscissa = [abscissa', aa']';
    end
    set(hd.units,'string',zlab);
else
    for i=1:length(n)
        minval = min(minval,pickfiles(n(i)).data.r(1)*rconv(i));
        maxval = max(maxval,pickfiles(n(i)).data.r(pickfiles(n(i)).data.head.thinned_nr)*rconv(i));
        aa = pickfiles(n(i)).data.r*rconv(i);
        abscissa = [abscissa', aa']';
    end
    set(hd.units,'string',rlab);
end
set(hd.minsld,'string',num2str(minval,'%5.2f'));
set(hd.maxsld,'string',num2str(maxval,'%5.2f'));
set(hd.slider,'Max',1,'Min',0);
hh=unique(abscissa);
npx = length(hh);

if isempty(get(hd.step,'string'))
    set(hd.slider,'Value',0,'SliderStep',[1/(npx-1) 0.1]);
    set(hd.step,'string','1');
    set(hd.value,'string',num2str(minval,'%5.2f'));
else
    y=get(hd.slider,'value');
    ix = round(y*(npx-1)+1);
    set(hd.slider,'SliderStep',[1/(npx-1) 0.1]);
    set(hd.value,'string',num2str(hh(ix),'%6.2f'));
    set(hd.step,'string',num2str(ix));
end
return




%*******************************************************************
%*                                                                 *
%*  Grazing angle plotting function                                *
%*                                                                 *
%*******************************************************************
function plot_ga(hd)

global pickfiles

m = get(hd.picklist,'value');
n = [];
for i=1:length(m)
    if ~isempty(pickfiles(m(i)).data.g)
        n = [n m(i)];
    end
end
if isempty(n)
    msgbox('No data found in selected file(s)')
    return
end
unitchoice=get(hd.funits,'value');
[rlab zlab rconv zconv] = normalize_temper_units(pickfiles,n,unitchoice);
if rlab==0
    errordlg('Files contain different units.  Please specify plotting units.','Data Not Displayed')
    return
end
hfp = findobj('Name','TEMPER Grazing Angle Plot');
if isempty(hfp)
    a = get(0,'ScreenSize');
    b = [a(3)*.65-5, 100, a(3)*.35, a(4)*.35];
    figure('Name','TEMPER Grazing Angle Plot','NumberTitle','off','Position',b)
else
    figure(hfp)
end
clf
hold on
grid on
set(gca,'box','on','tickdir','out')

% New, 2015-02-09 - see header comments in the subroutine
[colrs,lintyp] = get_colors_and_linetypes(length(n));

for i=1:length(n)
    %PRE: plttyp=strcat(colrs(mod(i,6)+1),lintyp(mod(ceil(i/6),4)+1,:));
    %PRE: plot(pickfiles(n(i)).data.r*rconv(i),pickfiles(n(i)).data.g,plttyp,'LineWidth',2)
    % New, 2015-02-09:
    thisColor = colrs{   mod(i-1,length(colrs) )+1 };
    thisStyle = lintyp{  mod(i-1,length(lintyp))+1 }; % <- now will cycle through line types faster than old code
    plot( pickfiles(n(i)).data.r*rconv(i), pickfiles(n(i)).data.g, ...
          'Color',thisColor, 'LineStyle',thisStyle, 'LineWidth',2 );            
end
ylabel('Grazing Angle [deg]')
xlabel(['Range [',rlab,']'])
title('Grazing Angle Plot')
% add legend, if more than one file is plotted
%if length(n)>1
    [a,b,c] = fileparts(pickfiles(n(1)).file);
    names = char(b);
    for i=2:length(n)
        [a,b,c] = fileparts(pickfiles(n(i)).file);
        names = char( names, b );
    end
    v = ver('Matlab');
    if eval(v.Version(1:3))<7
        hl=legend(names,0);
    else
        hl=legend(names,'Location','Best');
    end
    set(hl,'Interpreter','none')
%end
return





%*******************************************************************
%*                                                                 *
%*  Terrain height plotting function                               *
%*                                                                 *
%*******************************************************************
function plot_th(hd)

global pickfiles

m = get(hd.picklist,'value');
n = [];
for i=1:length(m)
    if ~isempty(pickfiles(m(i)).data.t)
        n = [n m(i)];
    end
end
if isempty(n)
    msgbox('No data found in selected file(s)')
    return
end
unitchoice=get(hd.funits,'value');
[rlab zlab rconv zconv] = normalize_temper_units(pickfiles,n,unitchoice);
if rlab==0
    errordlg('Files contain different units.  Please specify plotting units.','Data Not Displayed')
    return
end
hfp = findobj('Name','TEMPER Terrain Height Plot');
if isempty(hfp)
    a = get(0,'ScreenSize');
    b = [a(3)*.65-5, a(4)*.65-75, a(3)*.35, a(4)*.35];
    figure('Name','TEMPER Terrain Height Plot','NumberTitle','off','Position',b)
else
    figure(hfp)
end
clf
hold on
grid on
set(gca,'box','on','tickdir','out')

% New, 2015-02-09 - see header comments in the subroutine
[colrs,lintyp] = get_colors_and_linetypes(length(n));

for i=1:length(n)
    %PRE: plttyp=strcat(colrs(mod(i,6)+1),lintyp(mod(ceil(i/6),4)+1,:));
    %PRE: plot(pickfiles(n(i)).data.r*rconv(i),pickfiles(n(i)).data.t*zconv(i),plttyp,'LineWidth',2)
    % New, 2015-02-09:
    thisColor = colrs{   mod(i-1,length(colrs) )+1 };
    thisStyle = lintyp{  mod(i-1,length(lintyp))+1 }; % <- now will cycle through line types faster than old code
    plot( pickfiles(n(i)).data.r*rconv(i), pickfiles(n(i)).data.t*zconv(i), ...
          'Color',thisColor, 'LineStyle',thisStyle, 'LineWidth',2 );            
end
ylabel(['Terrain Height [',zlab,']'])
xlabel(['Range [',rlab,']'])
title('Terrain Height Plot')
% add legend, if more than one file is plotted
%if length(n)>1
    [a,b,c] = fileparts(pickfiles(n(1)).file);
    names = char(b);
    for i=2:length(n)
        [a,b,c] = fileparts(pickfiles(n(i)).file);
        names = char( names, b );
    end
    v = ver('Matlab');
    if eval(v.Version(1:3))<7
        hl=legend(names,0);
    else
        hl=legend(names,'Location','Best');
    end
    set(hl,'Interpreter','none')
%end
return





%*******************************************************************
%*                                                                 *
%*  Prop Factor line plotting function                             *
%*                                                                 *
%*******************************************************************
function plot_cuts(hd,holdaxis)

global pickfiles
type = get(hd.altcut,'value');
n = get(hd.picklist,'value');
if isempty(n)
    return
end
val = eval(get(hd.step,'string'));
valx = eval(get(hd.value,'string'));
cmin = [eval(get(hd.mindb,'string')), eval(get(hd.maxdb,'string'))];
unitchoice=get(hd.funits,'value');
[rlab zlab rconv zconv] = normalize_temper_units(pickfiles,n,unitchoice);
if rlab==0
    errordlg('Files contain different units.  Please specify plotting units.','Data Not Displayed')
    return
end
if get(hd.proploss,'value')
    hfp = findobj('Name','TEMPER Prop Loss Line Plot');
    if isempty(hfp)
        a = get(0,'ScreenSize');
        b = [a(3)*.3-5, a(4)*.65-75, a(3)*.35, a(4)*.35];
        figure('Name','TEMPER Prop Loss Line Plot','NumberTitle','off','Position',b)
        holdaxis = 0;
    else
        figure(hfp)
    end
else
    hfp = findobj('Name','TEMPER Prop Factor Line Plot');
    if isempty(hfp)
        a = get(0,'ScreenSize');
        b = [a(3)*.3-10, 100, a(3)*.35, a(4)*.35];        
        figure('Name','TEMPER Prop Factor Line Plot','NumberTitle','off','Position',b)
        holdaxis = 0;
    else
        figure(hfp)
    end
end
if holdaxis == 1
    %maintain current axis limits
    ax = axis(gca);
end
clf
hold on
grid on
set(gca,'box','on','tickdir','out')

% New, 2015-02-09 - see header comments in the subroutine
[colrs,lintyp] = get_colors_and_linetypes(length(n));

nplt = 0;
rind = [];
if get(hd.proploss,'value') % if plotting prop loss (TODO: here and elsehwere, add these kind of comments, or make code more clear)
    invertYAxis = 0; % KAG -- b/c of bug for vs height plots
    switch get(hd.ff2f4,'value')
        case 1
            fscale=1;
            xylbl='Pattern Propagation Loss [dB]';
        case 2
            fscale=2;
            xylbl='One-way Propagation Loss [dB]';
        case 3
            fscale=4;
            xylbl='Two-way Propagation Loss [dB]';
    end
else
    invertYAxis = 0; % JZG mod (fixed 2016-02-02)
    switch get(hd.ff2f4,'value')
        case 1
            fscale=1;
            xylbl='F [dB]';
        case 2
            fscale=2;
            xylbl='F^2 [dB]';
        case 3
            fscale=4;
            xylbl='F^4 [dB]';
    end
end
%  altitude vs. F^2
if type==0
    maxalt = 0;
    minalt = 9e9;
    for i=1:length(n)
        maxalt = max(maxalt, max(pickfiles(n(i)).data.h*zconv(i)));
        minalt = min(minalt, min(pickfiles(n(i)).data.h*zconv(i)));
    end
    if maxalt>5000
        ch = .001;
        pref = 'k';
    else
        ch = 1;
        pref = '';
    end
    for i=1:length(n)
        rr = pickfiles(n(i)).data.r*rconv(i) - valx;
        rrm = min(abs(rr));
        if rrm < .05
            irp = find(abs(rr)==rrm);
            if get(hd.proploss,'value')
                if strcmp(rlab,'km')
                    lambda = 299792.458 / pickfiles(n(i)).data.head.freq;
                else
                    lambda = (299792.458/1.852) / pickfiles(n(i)).data.head.freq;
                end
                rx = pickfiles(n(i)).data.r(irp)*rconv(i);
                F = fscale * (10 * log10(4*pi*rx/lambda) - pickfiles(n(i)).data.fdb(:,irp));
            else
                F = fscale * pickfiles(n(i)).data.fdb(:,irp);
            end
            %PRE: plttyp=strcat(colrs(mod(i,6)+1),lintyp(mod(ceil(i/6),4)+1,:));
            %PRE: plot(F,pickfiles(n(i)).data.h*ch*zconv(i),...
            %PRE:     plttyp,'LineWidth',2)
            % New, 2015-02-09 >>
            thisColor = colrs{   mod(i-1,length(colrs) )+1 };
            thisStyle = lintyp{  mod(i-1,length(lintyp))+1 }; % <- now will cycle through line types faster than old code
            plot( F, pickfiles(n(i)).data.h*ch*zconv(i),...
                'Color',thisColor, 'LineStyle',thisStyle, 'LineWidth',2 );            
            % << End New
            nplt = nplt+1;
            rind = [rind i];
        end
    end
    ylabel(['Height [',deblank(pref),zlab,']'])
    xlabel(xylbl)
    if nplt > 1
        title(['Range cut at ',num2str(valx,'%5.2f'),' ',rlab],...
            'interpreter','none')
    else
        [a,b,c] = fileparts(pickfiles(n(rind(1))).file);
        title(['File: ',b,'; range cut at ',num2str(valx,'%5.2f'),' ',rlab],...
            'interpreter','none')
    end
    if get(hd.autodb,'value')==0
        if holdaxis == 1 %keep axis limits the same as before.  Used only when clicking slider.
            axis(ax)
        else
            set(gca,'YLim',[minalt*ch, maxalt*ch]);
            set(gca,'XLim',cmin)
        end
    else
        axis auto
    end

    % F^2 vs. range
else
    maxrng = 0;
    minrng = 9e9;

    for i=1:length(n)
        maxrng = max(maxrng, max(pickfiles(n(i)).data.r*rconv(i)));
        minrng = min(minrng, min(pickfiles(n(i)).data.r*rconv(i)));
        maxalt = max(maxrng, max(pickfiles(n(i)).data.h*zconv(i)));
    end
    for i=1:length(n)
        hh = pickfiles(n(i)).data.h*zconv(i) - valx;
        hhm = min(abs(hh));
        if hhm < .05
            ihp = find(abs(hh)==hhm);
            if get(hd.proploss,'value')
                if strcmp(rlab,'km')
                    lambda = 299792.458 / pickfiles(n(i)).data.head.freq;
                else
                    lambda = (299792.458/1.852) / pickfiles(n(i)).data.head.freq;
                end
                rx = pickfiles(n(i)).data.r*rconv(i);
                F = fscale * (10 * log10(4*pi*rx'/lambda) - pickfiles(n(i)).data.fdb(ihp,:));
            else
                F = fscale * pickfiles(n(i)).data.fdb(ihp,:);
            end
            %PRE: plttyp=strcat(colrs(mod(i,6)+1),lintyp(mod(ceil(i/6),4)+1,:));
            %PRE: plot(pickfiles(n(i)).data.r*rconv(i),F,...
            %PRE:     plttyp,'LineWidth',2)
            % New, 2015-02-09 >>
            thisColor = colrs{   mod(i-1,length(colrs) )+1 };
            thisStyle = lintyp{  mod(i-1,length(lintyp))+1 }; % <- now will cycle through line types faster than old code
            plot( pickfiles(n(i)).data.r*rconv(i), F,...
                'Color',thisColor, 'LineStyle',thisStyle, 'LineWidth',2 );
            % << End New
            nplt = nplt + 1;
            rind = [rind i];
        end
    end
    xlabel(['Range [',rlab,']'])
    ylabel(xylbl)
    if maxalt>5000
        ch = 0.001;
        pref = 'k';
    else
        ch = 1;
        pref = '';
    end
    if nplt > 1
        title(['Altitude cut at ',num2str(valx*ch,'%6.2f'),' ',...
            pref,zlab],'interpreter','none')
    else
        [a,b,c] = fileparts(pickfiles(n(rind(1))).file);
        title(['File: ',b,'; altitude cut at ',num2str(valx*ch,'%6.2f'),' ',...
            pref,zlab],'interpreter','none')
    end
    if get(hd.autodb,'value')==0
        if holdaxis == 1 %keep axis limits the same as before.  Used only when clicking slider.
            axis(ax)
        else
            set(gca,'XLim',[minrng, maxrng]);
            set(gca,'YLim',cmin)
        end
    else
        axis auto
    end
end
% add legend, if more than one file is plotted
if nplt>1
    [a,b,c] = fileparts(pickfiles(n(rind(1))).file);
    names = char(b);
    for i=2:length(rind)
        [a,b,c] = fileparts(pickfiles(n(rind(i))).file);
        names = char( names, b );
    end
    v = ver('Matlab');
    warning off % don't warn about excess legend entries
    if eval(v.Version(1:3))<7
        hl=legend(names,0);
    else
        hl=legend(names,'Location','Best');
    end
    warning on
    set(hl,'interpreter','none');
end
% Flip y axis of propagation loss plots to make them easier to interpret
% (New, 2016-01-12)
if ( invertYAxis )
    set(gca,'ydir','reverse');
end
return





% --- Creates and returns a handle to the GUI figure. 
function h1 = openfig(filename, policy, varargin)
h1 = tffrp_LayoutFcn(policy);
return





function h1 = tffrp_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end

% Before laying out GUI, see if "temperdata" variable exists, and ask user about deleting it
if evalin('base',['exist(','''temperdata''',',','''var''',')']) == 1
    button = questdlg(['''temperdata''',' variable already exists and will be overwritten.'],'Clear ''temperdata'' Variable?','Proceed','Cancel','Proceed');
    if strcmp(button,'Cancel')
        h1 = [];
        return
    else
        evalin('base','clear(''temperdata'')');
    end
end

% Clear any data that may be stored in pickfiles
global pickfiles
pickfiles = [];

appdata = [];
appdata.lastValidTag = 'Fld_read_window';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'Fld_read_window');

h1 = figure(...
'Color',[0.831372549019608 0.815686274509804 0.784313725490196],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;...
0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;...
0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;...
0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;...
0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;...
0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;...
0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;...
0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;...
1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;...
1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;...
0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'MenuBar','none',...
'Name','TEMPER Field File Reader',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'Position',[520 694 611 416],...
'HandleVisibility','off',...
'Tag','Fld_read_window',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

% --- START OF UIPANEL CREATION ---
% As of 2015-02-21, uipanels are created first so that in R2014b+, they can be
% used as parent objects for the controls that are meant to go inside these
% panels.

appdata = [];
appdata.lastValidTag = 'uipanel2'; % Note that there is no uipanel1

h64 = uipanel(...
'Parent',h1,...
'Title','dB Scale',...
'Tag','uipanel2',...
'Clipping','on',...
'Position',[0.798690671031097 0.502403846153846 0.189852700490998 0.201923076923077],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel3';

h65 = uipanel(...
'Parent',h1,...
'Tag','uipanel3',...
'Clipping','on',...
'Position',[0.666121112929624 0.127403846153846 0.322422258592471 0.3125],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel4';

h66 = uipanel(...
'Parent',h1,...
'Tag','uipanel4',...
'Clipping','on',...
'Position',[0.669394435351882 0.713942307692308 0.286415711947627 0.122596153846154],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

% --- END OF UIPANEL CREATION ---

appdata = [];
appdata.lastValidTag = 'text1';

h2 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'FontSize',14,...
'ForegroundColor',[0 0 1],...
'ListboxTop',0,...
'Position',[0.160392798690671 0.913461538461539 0.657937806873977 0.0625],...
'String','TEMPER Field File Reader/Plotter',...
'Style','text',...
'Tag','text1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton1';
h3 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton1_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.617021276595745 0.00721153846153846 0.108019639934534 0.0552884615384616],...
'String','Close',...
'TooltipString','Closes the application',...
'Tag','pushbutton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton2';

h4 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton2_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.870703764320787 0.00721153846153846 0.108019639934534 0.0552884615384616],...
'String','Help',...
'TooltipString','Accesses help file (not yet available)',...
'Tag','pushbutton2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'listbox1';

h5 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''listbox1_Callback'',gcbo,[],guidata(gcbo))',...
'Max',2,...
'Position',[0.0409165302782324 0.221153846153846 0.220949263502455 0.557692307692308],...
'String',blanks(0),...
'Style','listbox',...
'TooltipString','Contains list of Field Files available in selected folder',...
'Value',1,...
'Tag','listbox1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edit1';

h6 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit1_Callback'',gcbo,[],guidata(gcbo))',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[0.193126022913257 0.848557692307693 0.6 0.0480769230769231],...
'String',blanks(0),...
'Style','edit',...
'TooltipString','Selected folder appears here',...
'Tag','edit1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton3';

h7 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton3_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.808510638297873 0.846153846153846 0.117839607201309 0.0504807692307692],...
'String','Select',...
'TooltipString','Click this button to select folder holding Field Files to be processed',...
'Tag','pushbutton3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'listbox2';

h8 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''listbox2_Callback'',gcbo,[],guidata(gcbo))',...
'Max',5,...
'Position',[0.436988543371522 0.223557692307693 0.220949263502455 0.557692307692308],...
'String',blanks(0),...
'Style','listbox',...
'TooltipString','This pane contains field files selected for display',...
'Value',1,...
'Tag','listbox2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton4';

h9 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton4_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.294599018003273 0.745192307692308 0.112929623567921 0.0552884615384616],...
'String','-->',...
'TooltipString','Use this to select file(s) to be displayed',...
'Tag','pushbutton4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton5';

h10 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton5_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.294599018003273 0.6875 0.112929623567921 0.0552884615384616],...
'String','<--',...
'TooltipString','Use this to remove file(s) from those to be displayed',...
'Tag','pushbutton5',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text3';

h11 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.0130932896890344 0.108173076923077 0.227495908346972 0.0384615384615385],...
'String','Selected File Size (kB):',...
'Style','text',...
'Tag','text3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text4';

h12 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.0834697217675942 0.0721153846153847 0.0834697217675941 0.0336538461538462],...
'String',blanks(0),...
'Style','text',...
'TooltipString','Displays the size of the selected Field file',...
'Tag','text4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton6';

h13 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton6_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.684124386252047 0.776442307692308 0.108019639934534 0.0528846153846154],...
'String','Coverage',...
'TooltipString','Click this to display converage diagram(s) of the selected file(s)',...
'Tag','pushbutton6',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton7';

h14 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton7_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.016366612111293 0.00961538461538462 0.104746317512275 0.0552884615384616],...
'String','File Info',...
'TooltipString','Click this to read header record of selected Field File in left pane',...
'Tag','pushbutton7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radiobutton1';

h15 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''radiobutton1_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.805237315875617 0.78125 0.127 0.0336538461538462],...
'String','Prop. Factor',...
'Style','radiobutton',...
'TooltipString','Select this for propagation factor display',...
'Value',1,...
'Tag','radiobutton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radiobutton2';

h16 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''radiobutton2_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.805237315875617 0.740384615384616 0.116 0.0336538461538462],...
'String','Prop. Loss',...
'Style','radiobutton',...
'TooltipString','Select this for propagation loss display',...
'Tag','radiobutton2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edit2';

h17 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit2_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.890343698854337 0.5625 0.0801963993453355 0.0456730769230769],...
'String','-50',...
'Style','edit',...
'TooltipString','Sets the minimum value for displays',...
'Tag','edit2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text6';

h18 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.811783960720131 0.567307692307692 0.0671031096563011 0.0360576923076923],...
'String','Min:',...
'Style','text',...
'Tag','text6',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text7';

h19 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.811783960720131 0.622596153846154 0.0671031096563011 0.0360576923076923],...
'String','Max:',...
'Style','text',...
'Tag','text7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edit3';

h20 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit3_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.890343698854337 0.615384615384615 0.0801963993453355 0.0456730769230769],...
'String','10',...
'Style','edit',...
'TooltipString','Sets the maximum value for displays',...
'Tag','edit3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'checkbox1';

h21 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''checkbox1_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.828150572831424 0.514423076923077 0.147299509001637 0.0336538461538462],...
'String','Auto Select',...
'Style','checkbox',...
'TooltipString','Check this to allow automatic scaling for output',...
'Value',1,...
'Tag','checkbox1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'togglebutton1';

h22 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''togglebutton1_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.672667757774143 0.350961538461538 0.137479541734861 0.0552884615384616],...
'String','Coverage Cuts',...
'Style','togglebutton',...
'TooltipString','Click this for line plots of selected file(s)',...
'Tag','togglebutton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radiobutton3';

h23 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''radiobutton3_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.829787234042554 0.338942307692308 0.082 0.0336538461538462],...
'String','Range',...
'Style','radiobutton',...
'TooltipString','Produces a line plot of range vs. PF at selected altitude',...
'Value',1,...
'Tag','radiobutton3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radiobutton4';

h24 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''radiobutton4_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.829787234042554 0.384615384615385 0.09 0.0336538461538462],...
'String','Altitude',...
'Style','radiobutton',...
'TooltipString','Produces a line plot of PF vs. altitude at selected range',...
'Tag','radiobutton4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'slider1';

h25 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''slider1_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.687397708674305 0.286057692307692 0.276595744680851 0.0384615384615385],...
'String',{  blanks(0) },...
'Style','slider',...
'TooltipString','Use this to adjust the range or altitude of the PF line plot',...
'Tag','slider1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text8';

h26 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.685761047463177 0.233173076923077 0.0458265139116203 0.0336538461538462],...
'String','Min',...
'Style','text',...
'Tag','text8',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text9';

h27 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.911620294599018 0.233173076923077 0.0458265139116203 0.0336538461538462],...
'String','Max',...
'Style','text',...
'Tag','text9',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text10';

h28 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[0.830999970436096 0.815999984741211 0.783999979496002],...
'ListboxTop',0,...
'Position',[0.67757774140753 0.194711538461539 0.0638297872340426 0.0384615384615385],...
'String',blanks(0),...
'Style','text',...
'Tag','text10',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text11';

h29 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[0.830999970436096 0.815999984741211 0.783999979496002],...
'ListboxTop',0,...
'Position',[0.909983633387889 0.194711538461539 0.0671031096563011 0.0384615384615385],...
'String',blanks(0),...
'Style','text',...
'Tag','text11',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text12';

h30 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'HorizontalAlignment','right',...
'ListboxTop',0,...
'Position',[0.765957446808513 0.211538461538462 0.0507364975450082 0.0360576923076923],...
'String','Step:',...
'Style','text',...
'Tag','text12',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text14';

h31 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'HorizontalAlignment','right',...
'ListboxTop',0,...
'Position',[0.759410801963994 0.149038461538462 0.0556464811783961 0.0360576923076923],...
'String','Value:',...
'Style','text',...
'Tag','text14',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edit4';

h32 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit4_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.819967266775779 0.206730769230769 0.0801963993453355 0.0456730769230769],...
'String',blanks(0),...
'Style','edit',...
'TooltipString','Sets/displays step within array',...
'Tag','edit4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edit5';

h33 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit5_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.819967266775779 0.144230769230769 0.0801963993453355 0.0456730769230769],...
'String',blanks(0),...
'Style','edit',...
'TooltipString','Sets/displays value within array',...
'Tag','edit5',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text16';

h34 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.903436988543372 0.149038461538462 0.07 0.0336538461538462],...
'String',blanks(0),...
'Style','text',...
'Tag','text16',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton8';

h35 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton8_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.124386252045827 0.00961538461538462 0.104746317512275 0.0552884615384616],...
'String','View *.prt',...
'TooltipString','Click this to display Print File associated with Field File selected in left pane',...
'Tag','pushbutton8',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text17';

h36 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.0540098199672668 0.795673076923078 0.193126022913257 0.0336538461538462],...
'String','Available Files',...
'Style','text',...
'Tag','text17',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text18';

h37 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.453355155482815 0.795673076923078 0.188216039279869 0.0336538461538462],...
'String','Selected Files',...
'Style','text',...
'Tag','text18',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text19';

h38 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.0671031096563012 0.855769230769231 0.124386252045827 0.0360576923076923],...
'String','Current Folder',...
'Style','text',...
'Tag','text19',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton9';

h39 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton9_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.674304418985271 0.651442307692309 0.108019639934534 0.0528846153846154],...
'String','Grazing',...
'TooltipString','Click this to display the grazing angle plots of the selected file(s)',...
'Tag','pushbutton9',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton10';

h40 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton10_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.674304418985271 0.58173076923077 0.108019639934534 0.0528846153846154],...
'String','Terrain',...
'TooltipString','Click this to display the terrain profiles of the selected file(s)',...
'Tag','pushbutton10',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text20';

h41 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.27986906710311 0.646634615384615 0.137479541734861 0.0360576923076923],...
'String','Number of Points',...
'Style','text',...
'Tag','text20',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text21';

h42 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.263502454991817 0.620192307692309 0.0834697217675941 0.0336538461538462],...
'String','Range',...
'Style','text',...
'Tag','text21',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text22';

h43 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.351882160392799 0.620192307692308 0.0834697217675941 0.0336538461538462],...
'String','Altitude',...
'Style','text',...
'Tag','text22',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text23';

h44 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'ListboxTop',0,...
'Position',[0.268412438625205 0.581730769230769 0.0736497545008183 0.0336538461538462],...
'String',blanks(0),...
'Style','text',...
'Tag','text23',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text24';

h45 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'ListboxTop',0,...
'Position',[0.356792144026187 0.581730769230769 0.0736497545008183 0.0336538461538462],...
'String',blanks(0),...
'Style','text',...
'Tag','text24',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text25';

h46 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'ListboxTop',0,...
'Position',[0.27986906710311 0.259615384615386 0.137479541734861 0.0360576923076923],...
'String','Thinning Factor',...
'Style','text',...
'Tag','text25',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edit6';

h47 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit6_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.276595744680851 0.213942307692309 0.0556464811783961 0.0456730769230769],...
'String','1',...
'Style','edit',...
'TooltipString','Enter Range Thinning Factor',...
'Tag','edit6',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edit7';

h48 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit7_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.364975450081833 0.213942307692309 0.0556464811783961 0.0456730769230769],...
'String','1',...
'Style','edit',...
'TooltipString','Enter Altitude Thinning Factor',...
'Tag','edit7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton11';

h49 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton11_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.743044189852701 0.00721153846153846 0.108019639934534 0.0552884615384616],...
'String','Info',...
'TooltipString','Select for GUI Version Info',...
'Tag','pushbutton11',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton12';

h50 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton12_Callback'',gcbo,[],guidata(gcbo))',...
'Position',[0.0801963993453355 0.15625 0.130932896890344 0.0552884615384616],...
'String','Refresh List',...
'TooltipString','Use this to refresh the list of files in the selected directory',...
'Tag','pushbutton12',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton13';

h51 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton13_Callback'',gcbo,[],guidata(gcbo))',...
'Position',[0.617021276595745 0.0697115384615385 0.361702127659574 0.0552884615384616],...
'String','Close Plots Generated by Plotter',...
'TooltipString','Closes the Open Plots Generated by the GUI',...
'Tag','pushbutton13',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edit9';

h52 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit9_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.276595744680851 0.0937500000000004 0.0556464811783961 0.0456730769230769],...
'Style','edit',...
'CreateFcn',{@(hObject,eventdata)tffrp('edit9_CreateFcn',hObject,eventdata,guidata(hObject))},...
'Tag','edit9');

local_CreateFcn(h52, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'edit10';

h53 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit10_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.364975450081833 0.0937500000000003 0.0556464811783961 0.0456730769230769],...
'String',blanks(0),...
'Style','edit',...
'CreateFcn',{@(hObject,eventdata)tffrp('edit10_CreateFcn',hObject,eventdata,guidata(hObject))},...
'Tag','edit10');

local_CreateFcn(h53, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'checkbox2';

h54 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''checkbox2_Callback'',gcbo,[],guidata(gcbo))',...
'Position',[0.445171849427169 0.100961538461539 0.155482815057283 0.0552884615384616],...
'String','Auto-thinning',...
'Style','checkbox',...
'TooltipString','Select to turn on Auto-thinning',...
'Tag','checkbox2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radiobutton5';

h55 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''radiobutton5_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.407528641571198 0.0432692307692311 0.1 0.0336538461538462],...
'String','Altitude',...
'Style','radiobutton',...
'TooltipString','Select this to more heavily thin altitude than range',...
'Value',1,...
'Tag','radiobutton5',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radiobutton6';

h56 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''radiobutton6_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.407528641571198 0.00480769230769234 0.1 0.0336538461538462],...
'String','Range',...
'Style','radiobutton',...
'TooltipString','Select this to more heavily thin range than altitude',...
'Tag','radiobutton6',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text29';

h57 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Enable','off',...
'HorizontalAlignment','left',...
'Position',[0.510638297872343 0.00480769230769234 0.0916530278232406 0.0721153846153846],...
'String',{  'Thinning'; 'Preference' },...
'Style','text',...
'Tag','text29',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edit11';

h58 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit11_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.286415711947627 0.00721153846153847 0.0932896890343699 0.0456730769230769],...
'Style','edit',...
'CreateFcn',{@(hObject,eventdata)tffrp('edit11_CreateFcn',hObject,eventdata,guidata(hObject))},...
'Tag','edit11');

local_CreateFcn(h58, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'radiobutton7';

h59 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''radiobutton7_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.243862520458265 0.175480769230769 0.24 0.0336538461538462],...
'String','Desired # of Points (max.)',...
'Style','radiobutton',...
'TooltipString','Select this to set range and altitude maximum number of points to keep after thinning',...
'Value',1,...
'Tag','radiobutton7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text31';

h60 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.265139116202946 0.139423076923077 0.0834697217675941 0.0336538461538462],...
'String','Range',...
'Style','text',...
'Tag','text31',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text32';

h61 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.353518821603929 0.139423076923077 0.0834697217675941 0.0336538461538462],...
'String','Altitude',...
'Style','text',...
'Tag','text32',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radiobutton8';

h62 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''radiobutton8_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.243862520458265 0.0528846153846156 0.16 0.0336538461538462],...
'String','Total # of Points',...
'Style','radiobutton',...
'TooltipString','Select this to specify the approximate total number of points to be kept after thinning',...
'Tag','radiobutton8',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text33';

h63 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'HorizontalAlignment','left',...
'Position',[0.7986906710311 0.454326923076923 0.195 0.033],...
'String','<-- Range/Altitude Units',...
'Style','text',...
'Tag','text33',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

% <-- this is where the uipanels used to be set, prior to 2015-02-21 -->

appdata = [];
appdata.lastValidTag = 'pushbutton14';

h67 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''pushbutton14_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Position',[0.674304418985271 0.512019230769231 0.108019639934534 0.0528846153846154],...
'String','Refractivity',...
'TooltipString','Click this to display the refractivity profiles of the selected file(s)',...
'Tag','pushbutton14',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popupmenu2';

h68 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''popupmenu2_Callback'',gcbo,[],guidata(gcbo))',...
'Position',[0.669394435351883 0.447115384615385 0.13 0.0480769230769231],...
'String',{  'File-Based'; 'nmi - ft'; 'km - m'; 'dmi - ft' },...
'Style','popupmenu',...
'TooltipString','Select units for plots',...
'Value',1,...
'CreateFcn',{@(hObject,eventdata)tffrp('popupmenu2_CreateFcn',hObject,eventdata,guidata(hObject))},...
'Tag','popupmenu2');

local_CreateFcn(h68, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'popupmenu1';

h69 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''popupmenu1_Callback'',gcbo,[],guidata(gcbo))',...
'Position',[0.680851063829788 0.723557692307693 0.12 0.0504807692307692],...
'String',{  'Pattern'; 'One-Way'; 'Two-Way' },...
'Style','popupmenu',...
'TooltipString','Coverage Type',...
'Value',2,...
'CreateFcn',{@(hObject,eventdata)tffrp('popupmenu1_CreateFcn',hObject,eventdata,guidata(hObject))},...
'Tag','popupmenu1');

local_CreateFcn(h69, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'checkbox3';

h70 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''checkbox3_Callback'',gcbo,[],guidata(gcbo))',...
'Position',[0.274959083469722 0.526442307692308 0.155482815057283 0.0552884615384616],...
'String','Range Select',...
'Style','checkbox',...
'TooltipString','Select to turn on Range Specification',...
'Tag','checkbox3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

local_CreateFcn(h70, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'checkbox4';

h71 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Callback','tffrp(''checkbox4_Callback'',gcbo,[],guidata(gcbo))',...
'Position',[0.274959083469722 0.389423076923077 0.155482815057283 0.0552884615384616],...
'String','Altitude Select',...
'Style','checkbox',...
'TooltipString','Select to turn on Altitude Specification',...
'Tag','checkbox4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

local_CreateFcn(h71, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'edit12';

h72 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit12_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.266775777414075 0.485576923076923 0.0638297872340426 0.0456730769230769],...
'String','-Inf',...
'Style','edit',...
'TooltipString','Input minimum desired range value',...
'CreateFcn',{@(hObject,eventdata)tffrp('edit12_CreateFcn',hObject,eventdata,guidata(hObject))},...
'Tag','edit12');

local_CreateFcn(h72, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'edit13';

h73 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit13_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.369885433715221 0.485576923076923 0.0638297872340426 0.0456730769230769],...
'String','Inf',...
'Style','edit',...
'TooltipString','Input maximum desired range value',...
'CreateFcn',{@(hObject,eventdata)tffrp('edit13_CreateFcn',hObject,eventdata,guidata(hObject))},...
'Tag','edit13');

local_CreateFcn(h73, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'popupmenu3';

h74 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''popupmenu3_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'Position',[0.274959083469722 0.432692307692308 0.153846153846154 0.0528846153846154],...
'String',{  'Range Units'; 'nautical miles'; 'kilometers'; 'data miles'; 'statute miles'; 'meters'; 'millimeters'; 'centimeters'; 'inches'; 'feet'; 'yards'; 'kilofeet' },...
'Style','popupmenu',...
'TooltipString','Select units for range',...
'Value',1,...
'CreateFcn',{@(hObject,eventdata)tffrp('popupmenu3_CreateFcn',hObject,eventdata,guidata(hObject))},...
'Tag','popupmenu3');

local_CreateFcn(h74, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'text34';

h75 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'HorizontalAlignment','center',...
'Enable','off',...
'Position',[0.333878887070377 0.487980769230769 0.0294599018003273 0.0360576923076923],...
'String','to',...
'Style','text',...
'Tag','text34',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edit16';

h76 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit16_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.266775777414075 0.350961538461538 0.0638297872340426 0.0456730769230769],...
'String','-Inf',...
'Style','edit',...
'TooltipString','Input minimum desired altitude value',...
'CreateFcn',{@(hObject,eventdata)tffrp('edit16_CreateFcn',hObject,eventdata,guidata(hObject))},...
'Tag','edit16');

local_CreateFcn(h76, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'edit17';

h77 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''edit17_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'ListboxTop',0,...
'Position',[0.369885433715221 0.350961538461538 0.0638297872340426 0.0456730769230769],...
'String','Inf',...
'Style','edit',...
'TooltipString','Input maximum desired altitude value',...
'CreateFcn',{@(hObject,eventdata)tffrp('edit17_CreateFcn',hObject,eventdata,guidata(hObject))},...
'Tag','edit17');

local_CreateFcn(h77, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'popupmenu5';

h78 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'BackgroundColor',[1 1 1],...
'Callback','tffrp(''popupmenu5_Callback'',gcbo,[],guidata(gcbo))',...
'Enable','off',...
'Position',[0.274959083469722 0.298076923076923 0.153846153846154 0.0528846153846154],...
'String',{  'Alt. Units'; 'feet'; 'meters'; 'kilometers'; 'millimeters'; 'centimeters'; 'inches'; 'yards'; 'kilofeet'; 'nautical miles'; 'statute miles'; 'data miles' },...
'Style','popupmenu',...
'TooltipString','Select units for altitude',...
'Value',1,...
'CreateFcn',{@(hObject,eventdata)tffrp('popupmenu5_CreateFcn',hObject,eventdata,guidata(hObject))},...
'Tag','popupmenu5');

local_CreateFcn(h78, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'text35';

h79 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'HorizontalAlignment','center',...
'Enable','off',...
'Position',[0.333878887070377 0.353365384615385 0.0294599018003273 0.0360576923076923],...
'String','to',...
'Style','text',...
'Tag','text35',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton15';

h80 = uicontrol(...
'Parent',h65,...
'Units','normalized',...
'Callback','tffrp(''pushbutton15_Callback'',gcbo,[],guidata(gcbo))',...
'ListboxTop',0,...
'Enable','off',...
'Position',[0.00518134715025907 0.00925925925925926 0.28 0.18],...
'String','Copy Fig.',...
'TooltipString','Click this to generate a static copy of the coverage cut figure',...
'Tag','pushbutton15',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );
% Prior to 2015-02-21: h80 'Position',[0.00518134715025907 0.00925925925925926 0.284974093264249 0.212962962962963],...
% Note that h80, unlike the other objects that were meant to be put into panels,
% was actually already in the h65 panel (child of h65) in this code prior to the
% R2014b changes, so h80 is not passed into r2014b_fix_panels() below.

if ~verLessThan('matlab', '8.4.0')
	r2014b_fix_panels( h64, [h17,h18,h19,h20,h21] );
	r2014b_fix_panels( h65, [h22,h23,h24,h25,h26,h27,h28,h29,h30,h31,h32,h33,h34] ); % FYI: h80 already in this panel (h65)
	r2014b_fix_panels( h66, [h13,h15,h16,h69] );
end

hsingleton = h1;
return





% --- New JZG function, 2015-02-21
function r2014b_fix_panels( hPanel, hWidgets )
% Input a handle to a UIPanel object "hPanel" and a vector of UIControl handles 
% "hWidgets". On input this function assumes that:
%   1) the input widgets have the full figure as their parent
%   2) the input widgets have normalized positions set within that figure
%
% On output, the follow modifications will have been made:
%   1) the widgets will now have the specified panel as their parent
%   2) the widgets will now have normalized positions set within that panel
%
% The appearance of the widgets - i.e., their positions in the GUI - will not
% have changed.

    if ~strcmpi( get(hPanel,'units'), 'normalized' )
        error('Panel position units must be ''normalized''');
    end
    
    % Get ppif = panel position in figure
    ppif = get(hPanel,'position');

    for i = 1:length( hWidgets )

        if ~strcmpi( get(hWidgets(i),'units'), 'normalized' )
            error('Only works for normalized units');
        end

        % Get wpif = widget position in figure
        wpif = get(hWidgets(i),'position');

        % Convert from wpif to wpip = widget position in panel
        wpip([1,2]) = ( wpif([1,2]) - ppif([1,2]) )./ppif([3,4]);
        wpip([3,4]) = wpif([3,4])./ppif([3,4]);

        set(hWidgets(i),'parent',hPanel);
        set(hWidgets(i),'position',wpip);

    end
    
return





% --- New JZG function, 2015-02-09
function[colrs,lintyp] = get_colors_and_linetypes( nLines )
% Prior to 2015-02-09
%
%	colrs = ['k','b','r','c','m','g'];
%	lintyp = ['--';'- ';': ';'-.'];
%
% Now:
%
%   colrs = Nx1 cell of [R,G,B] colors where N is min( # lines, 128 )
%   lintyp = 4x1 cellstr of line styles
%
% Last update: 2015-02-09

    EMULATE_OLD_CODE = 0;
    
    if ( EMULATE_OLD_CODE ) % mimics pre-2015-02-09 behavior using new code
        
        colrs = {'b','r','c','m','g','k'};
        lintyp = repmat( {'-',': ','-.','--'}, length(colrs), 1 );
        lintyp = [lintyp(:)];
        
    else
        
        nLines = min( nLines, 128 );
        
        if nLines < 3
            
            colrs = {'b','r'};
            
        else

            % You get better contrast between adjacent colors by loading
            % (2*n-1) colors, then thinning down to (n) colors.
            nCMapColors = 2*nLines - 1; % <- improves contrast
            colorArray = jet( nCMapColors ); % <- could use somemthing other than JET here
            colorArray(2:2:end,:) = [];

            % Ride the lightening #4:
            fadeFactor = 0.8; % 1.0 = no fading, 0.0 = all black
            colorArray = colorArray .* fadeFactor;

            colrs = num2cell( colorArray, 2 );
            
        end
        
        lintyp = {'-',':','-.','--'};
        
    end    

return





% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

    if ~isempty(appdata)
       names = fieldnames(appdata);
       for i=1:length(names)
           name = char(names(i));
           setappdata(hObject, name, getfield(appdata,name));
       end
    end

    if ~isempty(createfcn)
       eval(createfcn);
    end

return


% ------------------------------------------------------------------------------
% TODO:
% ------------------------------------------------------------------------------
%
% To consider:
%   - switch from global to persisent?
%   - what is the convention for ++ to version number?
%
% To do: address maintainability concerns
%   1) too few comments and obfuscated variable names.
%   2) lots of redundant code generated by copy-and-paste development
%
% For 1), note that as of 2016-01-11 tffrp.m had 2879 sloc and only 352 comment
% lines, a huge majority of which were the header comments and these "footnote"
% comments for TODO items and v1.32 updates. Not counting those large blocks of
% comments, this means the code is less than 1% commented. Suggest increasing to
% at least 20-30%. For variable names, for example, giving graphic objects more 
% descriptive names than "h##" in tffrp_LayoutFcn would make it easier to update
% the code. Also, the function names "[uitype]_Callback" make it very difficult
% to navigate and update the code. These are just two of many examples
% throughout this function where clearer names would help.
%
% For 2), although this metric is not always useful, the subroutines with high
% cyclomatic complexity are likely candidates for refactoring. Specifically,
% check these routines for copy-pasted code development and undo that by
% refactoring. This would make it much easier to update the code without having
% to check through for other copy-paste instances of the same lines that need
% manually concurrent changes to prevent creation of code errors.
%
%   cycomatic_complexity = 
% 
%                         main: 7
%         pushbutton2_Callback: 1
%            listbox1_Callback: 10    <-- refactor?
%            listbox2_Callback: 47    <-- refactor!
%           checkbox1_Callback: 7
%       togglebutton1_Callback: 4
%        radiobutton3_Callback: 2
%        radiobutton4_Callback: 2
%             slider1_Callback: 6
%               edit4_Callback: 6
%               edit5_Callback: 6
%         pushbutton3_Callback: 3
%        pushbutton12_Callback: 12    <-- refactor?
%        pushbutton13_Callback: 11    <-- refactor?
%         pushbutton4_Callback: 51    <-- refactor!
%         pushbutton5_Callback: 4
%         pushbutton7_Callback: 3
%         pushbutton8_Callback: 8
%         pushbutton6_Callback: 29    <-- refactor!
%        radiobutton1_Callback: 3
%        radiobutton2_Callback: 3
%         pushbutton9_Callback: 3
%        pushbutton10_Callback: 3
%        pushbutton11_Callback: 1
%         pushbutton1_Callback: 7
%               edit1_Callback: 2
%           checkbox3_Callback: 2
%           checkbox4_Callback: 2
%           checkbox2_Callback: 3
%        radiobutton5_Callback: 1
%        radiobutton6_Callback: 1
%        radiobutton7_Callback: 1
%        radiobutton8_Callback: 1
%        pushbutton14_Callback: 13    <-- refactor?
%        pushbutton15_Callback: 3
%               edit6_Callback: 1
%               edit7_Callback: 1
%               edit2_Callback: 1
%               edit3_Callback: 1
%               edit9_Callback: 1
%              edit10_Callback: 1
%              edit12_Callback: 1
%              edit13_Callback: 1
%              edit16_Callback: 1
%              edit17_Callback: 1
%              edit9_CreateFcn: 3
%             edit10_CreateFcn: 3
%              edit11_Callback: 1
%             edit11_CreateFcn: 3
%             edit12_CreateFcn: 3
%             edit13_CreateFcn: 3
%             edit16_CreateFcn: 3
%             edit17_CreateFcn: 3
%          popupmenu1_Callback: 2
%         popupmenu1_CreateFcn: 3
%          popupmenu2_Callback: 2
%         popupmenu2_CreateFcn: 3
%          popupmenu3_Callback: 1
%         popupmenu3_CreateFcn: 3
%          popupmenu5_Callback: 1
%         popupmenu5_CreateFcn: 3
%                  init_slider: 7
%                      plot_ga: 9
%                      plot_th: 9
%                    plot_cuts: 36    <-- refactor!
%                      openfig: 1
%              tffrp_LayoutFcn: 6
%            r2014b_fix_panels: 4
%     get_colors_and_linetypes: 3
%              local_CreateFcn: 4
%              
% ------------------------------------------------------------------------------


% -----------------------------------------------------------------------------
% 2008-08-05 updates for v1.32 (comments moved from top of file)
% -----------------------------------------------------------------------------
%
% If thinning factors less than 1 selected, then read_fld.m sends message
% dialog announcing "not allowed" and GUI resets values in thinning boxes
% to 1.  There are also new auto thinning options provided by
% tdata31.m
%
% Highlighting a file name in the Selected Files box will display the
% number of points of both range and altitude (useful for comparing to
% original file to know if it's been thinned.  This also works for
% selecting multiple files unless they have different numbers of points,
% then the respective range and/or altitude boxes are labled as "mult."
% Also, highlighting "Selected" files disables the file size box, since
% their size is ambiguous.
%
% A "Close All Coverage Plots" button has been added to do just that.
% Additionally, the figure naming convention for Coverage plots has been
% modified to include the file name.  Also, upon "Close" any open Terrain,
% Grazing or PF cut figures are closed (Coverage figures remain open).
% This can be avoided simply by clicking the "X" in the upper right corner.
%
% The center "Info" button was change to read "File Info" and shifted
% slightly toward the "Available Files" listbox along with "View Prt" to
% show that those actions only work on the files in that listbox.
%
% Grazing, Terrain, and PF cut figures have the added capability of
% uniquely plotting up to 24 files as opposed to the previous 6 (number of
% used colors), by allowing dashed, dotted and dash-dotted lines in
% addition to solid lines.
%
% Unique units can be specified apart from those in the TEMPER .fld file.
% The options are nmi-ft, km-m, dmi-ft, or the default of file-based.
%
% Refractivity profiles can be plotted if they are present in the
% accompanying .prt file.
%
% New Coverage plot options allow for pattern, one-way and two-way plots.
%
% 2011-03-22: added new capabilities to tffrp to accommodate new range/altitude
% selection capability of tdata31.  Also fixed numerous bugs throughout 
% script and added capability to use slider on zoomed-in PFcut plots 
% without changing axis settings.  Removed check for redundant dependent
% files by placing needing files into "private" folder.  Replaced all 
% instances of "str2num" and "str2double" with "eval" to accept inputs such 
% as '2^4' as well as '16'.
%
% 2011-04-07: Added Copy Fig. button to Coverage Cuts functionality and added
% functionality to limit the number of instances of tffrp to 1.  Added
% case-handling code for when 'temperdata' variable exists prior to opening
% GUI.
% -----------------------------------------------------------------------------
