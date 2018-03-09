filepath = '/Volumes/Data/Thesis_Data/complex_data_sinc_10mps_35GHz/';

% datapath{1} = 'data_10mps_unfiltered';
% datapath{2} = 'data_10mps_filtered_088';
% datapath{3} = 'data_10mps_filtered_50';
% datapath{4} = 'data_10mps_filtered_75';
% %datapath{5} = 'data_10mps_filtered_25';
% 
% fname = '10mps_run_0.srf';
% 
% for i = 1:length(datapath)
%     testName = strcat(filepath,datapath{i},'/',fname);
%     dispstring = sprintf('Loading Surface %d of %d',i,length(datapath));
%     disp(dispstring);
%     tempData = importdata(testName);
%     h(:,i) = tempData.data(:,2);
%     x = tempData.data(:,1);
% end
% 
% figure
% plot(x*1000,h(:,1),'LineWidth',2);
% hold on
% plot(x*1000,h(:,2),'LineWidth',2);
% plot(x*1000,h(:,3),'LineWidth',2);
% plot(x*1000,h(:,4),'LineWidth',2);
% grid on
% xlabel('Downrange (m)')
% ylabel('Height (m)')
% set(gca,'LineWidth',2)
% set(gca,'FontSize',12)
% set(gca,'FontWeight','bold')
% title ('Example Surfaces')
% xlim([0 250])
% legend('Unfiltered','10dB','6dB','3dB');

[h1, k1, S1, V1, x1, kp1, lambda_p1] = generateSeaSurface(20000, 40000, 10, 0.84,568194,false);
[h2, k2, S2, V2, x2, kp2, lambda_p2] = generateSeaSurface(20000, 40000, 10, 0.84,568194,true,0.08);
[h3, k3, S3, V3, x3, kp3, lambda_p3] = generateSeaSurface(20000, 40000, 10, 0.84,568194,true,0.25);
[h4, k4, S4, V4, x4, kp4, lambda_p4] = generateSeaSurface(20000, 40000, 10, 0.84,568194,true,0.5);
[h5, k5, S5, V5, x5, kp5, lambda_p5] = generateSeaSurface(20000, 40000, 10, 0.84,568194,true,0.75);

figure
plot(k1,S1,'LineWidth',3);
hold on
plot(k2,S2,'-.','LineWidth',3);
plot(k3,S3,'-.','LineWidth',3);
plot(k4,S4,'-.','LineWidth',3);
plot(k5,S5,'-.','LineWidth',3);
grid on
xlabel('k (rad/m)')
ylabel('Power Density (m^3/rad)')
set(gca,'LineWidth',2)
set(gca,'FontSize',28)
set(gca,'FontWeight','bold')
title('Example Spectra')
xlim([0 0.25])
%legend('Unfiltered','10dB','6dB','3dB','1.2dB');

sf = sum(S1);
dispString = sprintf('S2: %0.3f, S3: %0.3f, S4: %0.3f, S5: %0.3f',sum(S2)/sf, sum(S3)/sf, sum(S4)/sf, sum(S5)/sf);
disp(dispString);