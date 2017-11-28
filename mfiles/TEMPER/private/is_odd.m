function isItOdd = is_odd( n )
%is_odd - Returns (TRUE/FALSE) when integer input is (ODD/EVEN).
%
% Last update: 2005-03-23 (JZG)

    isItOdd = ( mod(n,2) == 1 );
    
return