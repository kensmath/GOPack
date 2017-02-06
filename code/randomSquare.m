function gop = randomSquare(N)
%GOPacker gop = randomSquare(N) 
%   Create a 'GOPacker' object for a geometrically random 
%   triangulation of a square with 'N' total vertices 
%   (int and bdry). 

% with intN interior, want about 4*sqrt(intN) on bdry
intN=1+floor((-2+sqrt(4+N))^2);
bdryN=N-intN;

% details handled in this call
gop=randomRectangle(intN,1.0,bdryN);

end

