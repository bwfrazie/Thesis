function sigma0 = NRL_Clutter_Reflectivity(polarization,alpha,f,SS)
%sigma0 = NRL_Clutter_Reflectivity(polarization,alpha,f,SS)
%Inputs:
% polarization - string defining the polarization as H or V
% alpha - grazing angle in degrees
% f - frequency in GHz
% SS - sea state
%Outputs:
% sigma0 - clutter reflectivity in dBsm

if strcmpi(polarization,'H')
    c1 = -73.0;
    c2 = 20.78;
    c3 = 7.351;
    c4 = 25.65;
    c5 = 0.00540;
elseif strcmpi(polarization,'V')
    c1 = -50.79;
    c2 = 25.93;
    c3 = 0.7093;
    c4 = 21.58;
    c5 = 0.00211;
else
    error('Error, polarization type must be "H" or "V", "%s" selected',polarization);
end

sigma0 = c1 + c2.*log10(sin(alpha.*pi/180)) + ...
         (27.5 + c3*alpha)*log10(f)./(1 + 0.95*alpha) + ...
         c4*(1+SS).^(1./(2+0.085*alpha+0.033*SS)) +c5*alpha.^2;