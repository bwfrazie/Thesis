function plotSignal2Clutter(varargin)
%plotSignal2Clutter()
%plotSignal2Clutter(f)
%plotSignal2Clutter(f,SS)
%plotSignal2Clutter(f,SS,bw)
%plotSignal2Clutter(f,SS,bw,tgt)
%Inputs:
% f - frequency in GHz (35 GHz by default)
% SS - Sea State (3 by default)
% bw - one way 3dB beamwidth in degress (8 degress by default)
% tgt - Target RCS in dBsm (45 dBsm by default);

%check the inputs
if nargin == 0
    f = 35;
    SS = 3;
    bw = 8;
    tgt = 45;
elseif nargin == 1
    f = varargin{1};
    SS = 3;
    bw = 8;
    tgt = 45;
elseif nargin == 2
    f = varargin{1};
    SS = varargin{2};
    bw = 8; 
    tgt = 45;
elseif nargin == 3
    f = varargin{1};
    SS = varargin{2};
    bw = varargin{3};
    tgt = 45;
elseif nargin == 4
    f = varargin{1};
    SS = varargin{2};
    bw = varargin{3};
    tgt = varargin{4};
else
    error('Invalid number of arguments (%d), can only input up to 4',nargin);
end

%setup initial parameters
psi = linspace(1,90,1000);
R = linspace(1000,60000,1000);
rcs = zeros(length(psi),length(R));

%"target RCS" values to draw lines
RCS1 = 35;
RCS2 = 50;

%loop over the slant range and get the clutter area and sigma0, then
%combine for the average rcs
for i = 1:length(R)
    ac = getClutterAreaBWLimited(bw, R(i), psi);
    sigma0 = NRL_Clutter_Reflectivity('H',psi,f,SS);
    rcs(:,i) = 10*log10(ac.*10.^(sigma0/10));
end

[px1,rx1] = find(abs(tgt-rcs-12) <0.05);
[px2,rx2] = find(abs(tgt-rcs-6) <0.05);
[px3,rx3] = find(abs(tgt-rcs-3) <0.05);
[px4,rx4] = find(abs(tgt-rcs) <0.05);

%plot stuff
figure
imagesc(R/1000,psi,tgt-rcs);
xlabel('Range (km)')
ylabel('Grazing Angle (deg)')
colormap(flipud(jet(256)))
% colormap(flipud(colormap('jet')));
grid on;
set(gca,'YDir','normal');
caxis([-20 20])
colorbar
hold on
h(1) = scatter(R(rx1)/1000,psi(px1),1,'filled','o','MarkerEdgeColor','green','MarkerFaceColor','green');
h(2) = scatter(R(rx2)/1000,psi(px2),1,'filled','o','MarkerEdgeColor','black','MarkerFaceColor','black');
h(3) = scatter(R(rx3)/1000,psi(px3),1,'filled','o','MarkerEdgeColor','magenta','MarkerFaceColor','magenta');
h(4) = scatter(R(rx4)/1000,psi(px4),1,'filled','o','MarkerEdgeColor','red','MarkerFaceColor','red');
legend(h,'12dB','6dB','3dB','0dB');
tstring = sprintf('SCR (dB) at %0.0f GHz, Sea State %d, %0.1f%c BW %d dBsm Target',f,SS,bw, char(176),tgt);
title(tstring);
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')