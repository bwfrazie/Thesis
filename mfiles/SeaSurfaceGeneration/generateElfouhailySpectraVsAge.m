function generateElfouhailySpectraVsAge(varargin)

saveFigs = 0;

if nargin == 1
    saveFigs = varargin{1};
end

p = linspace(-4,4,10000);
k = 10.^p;

U10 = 10;

age = [0.84 1.0 1.5 2.0 2.5 3.0 4.0 5.0];
h(1) = figure('pos',[50 50 1000 400]);
subplot(1,2,1)
for (j = 1:length(age)) 
   S = Elfouhaily(k,U10,age(j));
   loglog(k,S, 'LineWidth',2);
   hold on
end

l1 = linspace(-16,3,26);
l = 10.^l1;
plot(370*ones(size(l)),l,'k','LineWidth',2);

lstring = [];
for (j = 1:length(age))
    lstring{j} = sprintf('\\Omega = %0.2f', age(j));
end

grid on
xlim([10^-3 10^5]);
ylim([10^-15 10^3])
xlabel('k (rad/m)');
ylabel('S(k) (m^3/rad)')
text(370,10^-5,'\leftarrow k = 370 rad/m','FontWeight','bold','FontSize',12)
title('Elfouhaily Variance Spectrum')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
legend(lstring);

subplot(1,2,2)
for (j = 1:length(age)) 
   S = Elfouhaily(k,U10,age(j));
   loglog(k,k.^3.*S, 'LineWidth',2);
   hold on
end

grid on
xlim([10^-3 10^5]);
ylim([10^-4 10^0])
xlabel('k (rad/m)');
ylabel('k^3S(k) (rad^2)')
l1 = linspace(-16,3,26);
l = 10.^l1;
plot(370*ones(size(l)),l,'k','LineWidth',2);
text(370,10^-1.8,'\leftarrow k = 370 rad/m','FontWeight','bold','FontSize',12)
title('Elfouhaily Curvature Spectrum')
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
legend(lstring);

if(saveFigs)
 saveas(h(1),'elf_variance_curvature_spectrum_age.png','png')
end