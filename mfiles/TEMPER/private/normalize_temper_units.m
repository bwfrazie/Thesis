function [rlab zlab rconv zconv] = normalize_temper_units(pickedfiles,n,unitchoice)
%normalize_temper_units - handles unit strings and conversion factors for tffrp
%
% See also: unitflag2str.m, convert_length.m

multiunit=0;
for i=1:length(n)
    if pickedfiles(n(1)).data.head.units==pickedfiles(n(i)).data.head.units
    elseif unitchoice==1
        multiunit=1;
    end
end
if multiunit==1
    rlab=0;
    zlab=0;
    rconv=1;
    zconv=1;
    return
end
if unitchoice==1
    if pickedfiles(n(1)).data.head.units==1
        rlab = 'km';
        zlab = 'm';
    else
        rlab = 'nmi';
        zlab = 'ft';
    end
elseif unitchoice==2
    rlab = 'nmi';
    zlab = 'ft';
elseif unitchoice==3
    rlab = 'km';
    zlab = 'm';
elseif unitchoice==4
    rlab = 'dmi';
    zlab = 'ft';    
end
rconv = ones(length(n),1);
zconv = ones(length(n),1);
for i=1:length(n)
    if pickedfiles(n(i)).data.head.units==1
        if unitchoice==2
            rconv(i)=1/1.852;
            zconv(i)=1/0.3048;
        elseif unitchoice==4
            rconv(i)=1/1.8288;
            zconv(i)=1/0.3048;           
        end
    elseif unitchoice==3
        rconv(i)=1.852;
        zconv(i)=0.3048;
    elseif unitchoice==4
        rconv(i)=1.852/1.8288;       
    end
end