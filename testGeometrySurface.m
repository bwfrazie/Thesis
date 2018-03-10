[h, k, S, V, kx, ky,xx,yy] = generateSeaSurface2D(3000, 6000, 10, 0.84);

xx = xx*11.5;
yy = yy*11.5 - 3000;
[XX,YY] = meshgrid(xx,yy);
xq = linspace(xx(1),xx(end),500);
yq = linspace(yy(1),yy(end),500);
[Xq,Yq] = meshgrid(xq,yq);
hq = interp2(XX,YY,h,Xq,Yq);
