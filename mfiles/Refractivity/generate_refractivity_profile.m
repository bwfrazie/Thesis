function [M,mz] = generate_refractivity_profile(M0, layer_thickness, max_altitude,gradient, varargin)
%generate_refractivity_profile(layer_thickness, max_altitude,gradient, varagin)
%generate_refractivity_profile(layer_thickness, max_altitude,gradient, duct_start,duct_stop,duct_gradient)
%refractivity

use_standard_atmos = 0;
if use_standard_atmos == 1
    mz = 0:layer_thickness:max_altitude;
    [~,~,T,P,~,~] = atmos(mz);
    Tc = T - 273.15;

    es = 6.1121*exp(17.502*Tc./(Tc + 240.97));
    Rh = 0.9;
    e = Rh*es/100;

    P = 0.01*P;%convert from Pa to mbar
    N = 77.6./T.*(P + 4810*e./T);
    n = N*1e-6 + 1;
    M = 30 + (n-1 + mz/(4/3*6370e3))*10^6;

    if (nargin > 4) %working with a duct
        duct_start = varargin{1};
        duct_stop = varargin{2};
        duct_gradient = varargin{3};
        start = floor(duct_start/layer_thickness) + 1;
        stop = floor(duct_stop/layer_thickness) + 1;

        mzt = mz(start:stop);
        Mt = M(start) + duct_gradient*(mzt - mzt(1));
        M(start:stop) = Mt;

        diff = M(stop + 1) - Mt(end);

        M(stop+1:end) = M(stop+1:end) - diff;
    end

else
    if (nargin > 4) %duct
        duct_start = varargin{1};
        duct_stop = varargin{2};
        duct_gradient = varargin{3};
        mz = 0:layer_thickness:duct_start;
        M = M0 + gradient*mz;
        M = M';
        mz = mz';
        
        mzt = mz(end) + layer_thickness:layer_thickness:duct_stop;
        Mt = M(end) + duct_gradient*(mzt - mz(end));
        M = [M;Mt'];
        mz = [mz;mzt'];
        
        mzt =  mz(end) + layer_thickness:layer_thickness:max_altitude;
        Mt = M(end) + gradient*(mzt - mz(end));
        M = [M;Mt'];
        mz = [mz;mzt'];
        
    else %not working with a duct
        mz = 0:layer_thickness:max_altitude;
        M = M0 + gradient*mz;
        mz = mz';
        M = M';
    end
end