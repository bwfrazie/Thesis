function create2DOceanSurfaces(L,alpha,M,U10,age)
%create2DOceanSurfaces(L,alpha, M,U10,age)

N = alpha*L;
minTime = 9e10;
maxTime = 0;
avgTime = 0;
totalTime = 0;

dx = L/N;
x = (0:N-1)*dx;
    for counter = 1:M
        t1 = cputime;
        dispstring = sprintf('Creating Surface %d of %d',counter,M);
        disp(dispstring);
        [h,k,S,V,kx,ky] = generateSeaSurface2D(L, N, U10, age);
        fname = sprintf('surface%d.hd5',counter);
        
       if(exist(fname))
        delete(fname);
        h5create(fname,'/surface',[N N]);
        h5create(fname,'/x',[1 N]);
       end
        h5write(fname,'/surface',h);
        h5write(fname,'/x',x);
        t2 = cputime-t1;
        
        totalTime = totalTime + t2;
        avgTime = totalTime/counter;
        if t2 > maxTime
            maxTime = t2;
        end
        if t2 < minTime
            minTime = t2;
        end
        
        dispstring = sprintf('Total Time: %0.2f s, Average Time: %0.2f s, Max Time: %0.2f s, Min Time; %0.2f s',totalTime,avgTime,maxTime,minTime);
        disp(dispstring);
    end

end

