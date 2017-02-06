function gop = randomDisc(N)
%@GOPacker gop=randomDisc(N) Create geometrically random triangulation.
%   Create a 'GOpacker' object for a geometrically random triangulation
%   of the unit disc with 'N' points. We use uniformly random points on 
%   unit circle and points chosen with a Poisson Point Process inside,
%   then create the Delaunay triangulation.

%% N total points: for intN interior, want roughly pi*sqrt(intN) bdry
intN=1+floor((sqrt(pi^2+4*N)/2-pi/2)^2);
bdryN=N-intN;

%% distribute bdryN uniformly on the unit circle
args=2*pi.*rand(bdryN,1);
bdryX=zeros(bdryN,1);
bdryY=zeros(bdryN,1);
for j=1:bdryN
    bdryX(j)=cos(args(j));
    bdryY(j)=sin(args(j));
end

%% randomly choose points interior to the unit disc
intX=zeros(intN,1);
intY=zeros(intN,1);

% random one near origin to act as alpha
invN=1/N;
intX(1)=invN*(-1+2*rand(1,1));
intY(1)=invN*(-1+2*rand(1,1));

% now the rest
hits=2;
count=2;
while hits<=intN && count<100*intN
    x=-1+2*rand(1,1);
    y=-1+2*rand(1,1);
    if (x^2+y^2)<1
        intX(hits)=x;
        intY(hits)=y;
        hits=hits+1;
    end
end
if count==100*intN
    fprintf('overran saftey check in randDisc\n');
end

%% Create the Delaunay triangulation
X=[intX;bdryX];
Y=[intY;bdryY];
Z=X+1i*Y;

DT=delaunayTriangulation(X,Y);
tri=DT.ConnectivityList;

%plot(X,Y,'.r'); % for testing, see the points

%% Create the GOPacker
gop=GOPacker();
gop.alpha=1;
gop.parse_triangles(tri,Z);
gop.indxMatrices();
gop.hes=-1;
gop.mode=1;
return;

end

