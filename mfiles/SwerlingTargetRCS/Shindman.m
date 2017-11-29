function [SNR,SNRdb] = Shindman(Pd,Pfa,N,SwerlingType)


%first calculate the K value based on the SwerlingType
switch(SwerlingType)
    case 0
        K = 'inf';
    case 1
        K = 1;
    case 2
        K = N;
    case 3
        K = 2;
    case 4
        K = 2*N;
    otherwise
        error('Invalid Swerling Type, Selected %d, must be 0-5',SwerlingType);
end

%next, determine the alpha parameter
if N < 40
    alpha = 0;
else
    alpha = 0.25;
end

%now determine aida
aida = sqrt(-0.8*log(4*Pfa*(1 - Pfa))) + sign(Pd - 0.5)*sqrt(-0.8*log(4*Pd*(1-Pd)));

%and Xinf
Xinf = aida*(aida + 2*sqrt(N/2 + (alpha - 0.25)));

%now the C's, C1, C2, Cdb and C

if SwerlingType == 0
    C1 = 0;
    C2 = 0;
else
    C1 = (((17.7006*Pd - 18.4496)*Pd + 14.5339)*Pd -3.525)/K;
    C2 = 1/K*(exp(27.31*Pd - 25.14) + (Pd - 0.8)*(0.7*log(10^-5/Pfa) + (2*N - 20)/80));
end

if Pd >= 0.1 && Pd <= 0.872
    Cdb = C1;
elseif Pd > 0.872 && Pd < 0.99
    Cdb = C1 + C2;
else
    error('Pd invalid (%0.2f) must be between 0.1 and 0.9',Pd)
end

C = 10^(Cdb/10);

SNR = C*Xinf/N;
SNRdb = 10*log10(SNR);
