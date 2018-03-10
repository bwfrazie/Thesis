

g = 20000;
h1 = 15;
h2 = 15;
ae= 4/3*6371000;
dh1 = 3*0.65;
dh2 = -3*0.65;

f = 35e9;
lambda = 3e8/f;

h2corr = h2 + g/(2*ae);

testVal = (sqrt( g^2 + (h1+h2corr)^2) - sqrt( g^2 + (h1-h2corr)^2))/(pi*lambda);

testVal2 = (sqrt( g^2 + (h1+ 2*dh1 + h2corr)^2) - sqrt( g^2 + (h1-h2corr)^2))/(pi*lambda);

testVal3 = (sqrt( g^2 + (h1+ 2*dh2 + h2corr)^2) - sqrt( g^2 + (h1-h2corr)^2))/(pi*lambda);