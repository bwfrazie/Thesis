%pd.m
SNRdB = linspace(-2,16,100);
Pfa = 1e-8;
N = 10;
%compute the threshold - make sure to switch to normal form rather than
%Pearson's form
%I(u,p) = P(u*sqrt(p+1),p+1)
if N == 1
    T = -1*log(Pfa);
else
    T = gammaincinv(1-Pfa,N);
end
Pfa = 1-gammainc(T,N);
TdB = db(T,'power');

[pd0,pfa0] = getSwerlingPd(SNRdB,N,0,TdB);
[pd1,pfa1] = getSwerlingPd(SNRdB,N,1,TdB);
[pd2,pfa2] = getSwerlingPd(SNRdB,N,2,TdB);
[pd3,pfa3] = getSwerlingPd(SNRdB,N,3,TdB);
[pd4,pfa4] = getSwerlingPd(SNRdB,N,4,TdB);

h = figure;
h0 = plot(SNRdB,pd0,'--');
hold on
h1 = plot(SNRdB,pd1);
set(h1,'Marker','x');
set(h1,'MarkerSize',6);
h2 = plot(SNRdB,pd2);
h3 = plot(SNRdB,pd3);
set(h3,'Marker','o');
set(h3,'MarkerSize',6);
h4 = plot(SNRdB,pd4);
xlim([-2 15])
legend('Nonfluctuating','Swerling 1','Swerling 2', 'Swerling 3', 'Swerling 4')
grid on
xlabel('SNR (dB)')
ylabel('Probability of Detection')
tstring = sprintf('Threshold = %0.1f dB, Pfa = %0.3e, N = %d',TdB,Pfa, N);
title(tstring);