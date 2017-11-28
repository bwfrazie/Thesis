function infor=display_info2(d)
%
%  display_info2(D)
%
%  Compiles TEMPER Field File header information for display.  Information 
%  is contained within structure D, which is filled with routine tdata31
%

if d.units == 0
    hunit = 'feet';
    runit = 'nmi';
else
    hunit = 'meters';
    runit = 'km';
end
tm=[d.time(1:2) ':' d.time(3:4) ':' d.time(5:length(d.time))];
dt=[d.date(1:4) '/' d.date(5:6) '/' d.date(7:8)];
if isfield(d,'Lat') && isfield(d,'Lon')
    if d.Lat == -999 || d.Lon == -999
        pos = 'Location not specified';
    else
        pos = [num2str(d.Lat,'%9.4f'),'°, ',num2str(d.Lon,'%9.4f'),'°'];
    end
else
    pos = 'Location not specified';
end
switch d.ipat
    case 0
       cpat = 'Sinc';
    case {1,2,4}
       cpat = 'File';
    case 3
       cpat = 'Plane Wave';
    case 5
       cpat = 'Guassian';
end
if (d.pol==0)
   cpol = 'Vertical';
else
   cpol = 'Horizontal';
end
if (d.complex==0)
   ctyp = 'Magnitude';
else
   ctyp = 'Complex';
end
switch d.iter
    case 1
        cter = 'Knife Edge';
    case 2
        cter = 'Linear Shift';
    case 3
        cter = 'Hybrid';
    otherwise
        cter = 'None';
end
if d.perm == 0
    perm = 'ocean';
elseif d.perm == -99
    perm = 'from srf file';
elseif d.perm == -9999
    perm = 'perfect conductor';
else
    perm = num2str(d.perm);
end
if d.cond == 0
    cond = 'ocean';
elseif d.cond == -99
    cond = 'from srf file';
elseif d.cond == -9999
    cond = 'perfect conductor';
else
    cond = num2str(d.cond);
end
if d.roughness == -99
    roug = 'from srf file';
elseif d.roughness == 0
    roug = 'smooth';
else
    roug = num2str(d.roughness);
end
infor = char(['File:     ',d.file],...
    ['Title:    ',d.title],...
    ['Creation Date/Time:  ',dt,', at ',tm],...
    ['TEMPER Version:  ',num2str(d.version,'%5.2f')],...
    ['Frequency [MHz]:  ',num2str(d.freq*1.e-6,'%8.3f')],...
    ['Antenna Height [',hunit,']:  ',num2str(d.anthgt)],...
    ['Antenna Type :  ',cpat],...
    ['Antenna Beamwidth:  ',num2str(d.beamwidth,'%6.2f'),'°'],...
    ['Antenna Elevation:  ',num2str(d.beampoint,'%6.2f'),'°'],...
    ['Polarization:  ',cpol],...
    ['Problem Angle:  ',num2str(d.probangle,'%6.3f'),'°'],...
    ['Transform Size:    2^',num2str(d.transfsize)],...
    ['Data Type:  ',ctyp],...
    ['Compression Method:  ',num2str(d.compr)],...
    ['F^2 Threshold [dB]:  ',num2str(-180)],... %TBD the hard-coded -180 would need to be changed if read_temper_header is updated to include the threshold
    ['Terrain Method:  ',cter],...
    ['Position [N,E]:  ',pos],...
    ['Minimum/Maximum Range [',runit,']:  ',num2str(d.rmin,'%6.2f'),' / ',num2str(d.rmax,'%6.2f')],...
    ['Range Increment [',runit,'], # Points:  ',num2str(d.rinc,'%6.2f'),', ',num2str(d.nr)],...
    ['Minimum/Maximum Altitude [',hunit,']:  ',num2str(d.zmin,'%6.2f'),' / ',num2str(d.zmax,'%6.2f')],...
    ['Altitude Increment [',hunit,'], # Points:  ',num2str(d.zinc,'%6.2f'),', ',num2str(d.nz)],...
    ['Terrain Offset [',hunit,']:  ',num2str(d.teroff,'%8.2f')],...
    ['Previous Field File:  ',d.restart],...
    ['Surface Parameter File:  ',d.srffile],...
    ['Permittivity [F/m]:  ',perm],...
    ['Conductivity [S/m]:  ',cond],...
    ['Surface Roughness [',hunit,']:  ',roug]);

return