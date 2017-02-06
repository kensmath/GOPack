function gop = randomRectangle(intN,Aspect,bdryN)
%GOPacker obj=randomRectangle(intN,[Aspect,[bdryN]])
%   Create a 'GOPacker' object for a geometrically random 
%   triangulation of a rectangle using 'intN' interior points of the
%   rectangle [-Aspect,Aspect]x[-1,1]. See 'randTriangulation.m' for
%   details. The triangulation may need to be pruned of orphan
%   vertices.
%   Default: Aspect=1, bdryN = 4*Aspect*sqrt(intN).

%% create the 'GOPacker'
gop=GOPacker();
if nargin<1 || intN<1
    fprintf('random rectangle should have at least 1 interior point\n');
    return;
end

%% set the aspect
asp=1.0;
bN=floor(4*sqrt(intN));
if nargin>1
    asp=abs(Aspect);
    bN=floor(bN*asp);
    if nargin>2
        bN=bdryN;
    end
end
if bN<4
    bN=4;
end

%% create the path, points, and delaunay triangulation
% define rectangle path
gX=[asp;-asp;-asp;asp;asp];
gY=[1;1;-1;-1;1];

% choose random target point near the origin for alpha
iN=1/intN;
center=iN*(-1+2*rand(1,1))+1i*iN*(-1+2*rand(1,1));

% create random triangulation
[tri,Z,alpha]=randTriangulation(intN,bN,gX,gY,center);
if alpha>0
    gop.alpha=alpha;
end
gop.parse_triangles(tri,Z);

% triangulation may need pruning for vertices cut off from interior
gop.pruneComplex();
gop.indxMatrices();

%% find vertices closest to corners, 'gamma' is upper right corner
ur=asp;
ul=asp;
ll=asp;
lr=asp;
urV=gop.bdryList(1);
ulV=gop.bdryList(1);
llV=gop.bdryList(1);
lrV=gop.bdryList(1);
for i=1:length(gop.bdryList)-1
    v=gop.bdryList(i);
    z=gop.centers(v);
    distur=abs(z-(asp+1i));
    distul=abs(z-(-asp+1i));
    distll=abs(z-(-asp-1i));
    distlr=abs(z-(asp-1i));
    if distur<ur
        urV=v;
        ur=distur;
    end
     if distul<ul
        ulV=v;
        ul=distul;
    end   
    if distll<ll
        llV=v;
        ll=distll;
    end
    if distlr<lr
        lrV=v;
        lr=distlr;
    end
end

% list of corners in cclw order
gop.vlist=[urV,ulV,llV,lrV];
gop.gamma=urV;

% set 'alpha' if not already set
if alpha<0
    alpha=gop.intVerts(1);
    mindist=abs(gop.centers(alpha));
    for j=1:gop.intCount
        v=gop.intVerts(j);
        dist=abs(gop.centers(v));
        if dist<mindist
            mindist=dist;
            alpha=v;
        end
    end
    gop.alpha=alpha;
end

% set 'mode' to rectangle pack
gop.setMode(2,gop.vlist);
fprintf('GOpacker started with random rectangle, aspect %f, %d vertices\n',asp,gop.nodeCount);

end

