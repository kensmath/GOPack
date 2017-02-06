function gop = randomTri(intN,bdryN,graphX,graphY,cent)
%GOPacker gop=randomTri(intN,[bdryN,graphX,graphY,[cent]]) 
%   Create a 'GOPacker' object with a geometrically random triangulation 
%   of a plane region. 
%   "Geometrically" random refers to Delaunay triangulations of points
%   chosen with a Poisson Point Process. See 'randTriangulation.m' for
%   details.

%% Is this a sphere triangulation? want a random sphere.
if nargin==1
    gop=randomSphere(intN);
    gop.hes=1;
    return;
% not enough arguments?
elseif nargin<4 || nargin<1
    fprintf('Usage: randomTri(intN,bdryN,graphX,graphY,[cent])\n');
    gop=GOPacker();
    return
end

%% Else this is a plane region
gop=GOPacker();
gop.alpha=-1;
if nargin==5
    [Tri,Z,alpha]=randTriangulation(intN,bdryN,graphX,graphY,cent);
else
    [Tri,Z,alpha]=randTriangulation(intN,bdryN,graphX,graphY);    
end
if alpha>0
    gop.alpha=alpha;
end

% things look okay?
szt=size(Tri);
mxindx=max(max(Tri));
if isempty(Tri) || isempty(Z) || length(Z)<mxindx
    fprintf('Error in generating the random triangulation.\n');
    return;
end

% reindex all the indices that occur
indxhits=zeros(mxindx,1);
tick=0;
for i=1:szt(1)
    face=Tri(i,:);
    for j=1:3
        k=face(j);
        if indxhits(k)==0
            tick=tick+1;
            indxhits(k)=tick;
        end
    end
end
nodecount=tick;

% reindex the triangles
tList=Tri;
for i=1:szt(1)
    tList(i,1)=indxhits(Tri(i,1));
    tList(i,2)=indxhits(Tri(i,2));
    tList(i,3)=indxhits(Tri(i,3));
end

% use only the necessary centers
newZ=zeros(nodecount,1);
for i=1:length(indxhits)
    k=indxhits(i);
    if k>0
        newZ(k)=Z(i);
    end
end

% now create the 
gop.parse_triangles(tList,newZ);
gop.indxMatrices();
gop.hes=0;
gop.mode=1;
return;

end


