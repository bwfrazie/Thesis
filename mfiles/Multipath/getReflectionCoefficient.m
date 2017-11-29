function [ rho] = getReflectionCoefficient( graz,sigma,lambda)
    g = sigma*sin(graz)/lambda;
    u = 2*(2*pi*g).^2;
    rho = besseli(0,u)./exp(u);
    
    %now get the "smooth" reflection coefficient
    f = 2.997e8/lambda;
    
    Re = 64.18/(1 + 3.30523e-21*f^2) + 4.9;
    Im = 3.68972e-9*f/(1 + 3.30523e-21*f^2) + 9.4e10/f;
    epsr = 80 - 1j*lambda*4.3;%dielectric function of seawater
    
    epsr = Re + 1j*Im;
    
    num = sin(graz) - sqrt(epsr - cos(graz).^2);
    den = sin(graz) + sqrt(epsr - cos(graz).^2);
    
    gammas = num./den; %magnitude of reflection coefficient will be close to 1
    
    rho = rho.*gammas;
   
end

