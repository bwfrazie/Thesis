function [ pd,pfa ] = getSwerlingPd( SNRdB, N, SwerlingType, TdB )

%convert the SNR to linear units
SNR = 10.^(SNRdB/10);
T = 10.^(TdB/10);

%determine the Pfa from the Number of pulses and the threshold
pfa = 1-gammainc(T,N);

%initialize the pd;
pd = 0;

switch SwerlingType
    
    case 0
        A = log(0.62./pfa);
        Z = (SNRdB + 5*log10(N))/(6.2 + (4.54/sqrt(N+0.44)));
        B = (10.^Z - A)./(1.7+0.12*A);
        pd = 1./(1+exp(-B));
    case 1
        pd = (1 + 1./(N*SNR)).^(N-1).*exp(-T./(1+N*SNR));
    case 2
        pd = 1 - gammainc(T./(1 + SNR),N);
    case 3
        pd = (1 + 2./(N*SNR)).^(N-2).*(1 + T./(1 + N*SNR/2) - 2*(N-2)./(N*SNR)).*exp(-T./(1 + N*SNR/2));
    case 4
        c = 1./(1 + SNR/2);
        
        if (T > N*(2-c))
            
            for k = 0:N
                tempval = 0;
                for l = 0:2*N-1-k
                    tempval = tempval + exp(-c*T).*(c*T).^l/factorial(l);
                end
                pd = pd + factorial(N)/(factorial(k)*factorial(N-k)).*((1-c)./c).^(N-k) .* tempval;
            end
            
            pd = c.^N.*pd;
        else
            pd = 0; %infinite sum, should never hit this case
        end
    otherwise
        errstring = sprintf('Swerling Type %d not handled yet',SwerlingType);
        error(errorstring);
end


end

