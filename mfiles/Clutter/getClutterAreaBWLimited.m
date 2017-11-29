function Ac = getClutterAreaBWLimited(bw, R, psi)
%Ac = getClutterAreaBWLimited(bw, R, psi)
%Inputs:
% bw - one way beamwidth
% R - slant range
% psi - grazing angle
%Outputs:
% AC - beamwidth limited clutter area

%convert BW to two way
bw = 1/sqrt(2)*bw;

Ac = pi*R.^2*(tan(bw/2*pi/180))^2.*csc(psi*pi/180);


