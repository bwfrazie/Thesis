function generateEnsembleRMSCurves(varargin)

saveFigs = 0;

if (nargin == 1)
    saveFigs = varargin{1};
end

U10 = [1 3 5 8 10 12 15 17 20];
%data collected from ensemble runs
% U10                     1        3         5       8        10       12       15       17       20
case_1d_L10k_N100L_084 = [0.00548  0.05771  0.16195  0.41821  0.65565  0.94539  1.47126  1.89289  2.60784];
case_1d_L10k_N10L_084 =  [0.00535  0.05770  0.16199  0.41846  0.65510  0.94346  1.47265  1.89249  2.61864];
case_1d_L10k_N2L_084 =   [0.00241  0.05719  0.16199  0.41848  0.65731  0.94488  1.47641  1.89127  2.60586];

case_1d_L1k_N100L_084 =  [0.00548  0.05770  0.16175  0.41937  0.65613  0.94387  1.46217  1.87639  2.65930];
case_1d_L1k_N10L_084 =   [0.00535  0.05759  0.16162  0.41989  0.65316  0.94510  1.48107  1.90273  2.60860];
case_1d_L1k_N2L_084 =    [0.00241  0.05713  0.16110  0.41711  0.65669  0.94677  1.46192  1.91702  2.57761];

h(1) = figure;
plot(U10,case_1d_L10k_N100L_084,'LineWidth',2);
hold on
plot(U10,case_1d_L10k_N10L_084,'LineWidth',2);
plot(U10,case_1d_L10k_N2L_084,'LineWidth',2);
plot(U10,case_1d_L1k_N100L_084,'LineWidth',2);
plot(U10,case_1d_L1k_N10L_084,'LineWidth',2);
plot(U10,case_1d_L1k_N2L_084,'LineWidth',2);
grid on
legend('L=10km, N=100L','L=10km, N=10L','L=10km, N=2L','L=1km, N=100L','L=1km, N=10L','L=1km, N=2L','Location','NorthWest');

xlabel('Wind Speed at 10 m Altitude (m/s)');
ylabel('\sigma_h (m)')

set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

if(saveFigs == 1)
    saveas(h(1),'1d_ensemble_rms','png')
end