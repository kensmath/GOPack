function [Tri,Z,alpha] = randTriangulation(intN,bdryN,graphX,graphY,cent)
%[Tri,Z,alpha]=randTriangulation(intN,[bdryN,graphX,graphY,[cent]]) 
%   Create a geometrically random triangulation of a plane region. 
%   "Geometrically" random refers to Delaunay triangulations of points
%   chosen with a Poisson Point Process.
%   If 'intN' is only argument, then create a Delaunay triangulation of 
%   the sphere based on 'intN' random points. Otherwise, the number of 
%   boundary points and vectors coordinates are given for a plane
%   region. The  Delaunay triangulation is based on 'bdryN' points 
%   uniformly (w.r.t. polygonal length) along the boundary and 'intN' 
%   random interior points. If 'cent' is given, it should be interior to
%   the region and we place the 'alpha' vertex near it, else return 
%   'alpha'=-1. Return the Delaunay triangulation and centers. Calling 
%   routine must convert results to a 'GOPack' object, pruning it if 
%   necessary.

%% Is this a sphere triangulation? Randomly choose points
if nargin==1
    % choose intN random points in rectangle [0,2pi]x[-1,1]
    a=rand(intN,1)*2*pi;
    z=rand(intN,1)*2.-1.0;
    
    % project to sphere, by giving z heights
    sphPts=zeros(intN,3);
    Z=zeros(intN,1);
    for i=1:intN
        sphPts(i,3)=z(i);
        r=sqrt(1-z(i)^2);
        sphPts(i,1)=r*cos(a(i));
        sphPts(i,2)=r*sin(a(i));
        Z(i)=proj_vec_to_s(sphPts(i,:));
    end
    
    % get the convex hull in 3D
    Tri=convhulln(sphPts);
    return;
end
    

%% Else this is a plane region
alpha=-1;
graphNum=length(graphX);
if graphNum<3 || length(graphY)~=graphNum || bdryN<3 || intN<1
    fprintf('usage: randTriangulation(intN,bdryN,graphX,graphY)\n');
    Tri=[];
    Z=[];
    alpha=-1;
    return;
end

% find bdryN random points on the graph
[bdryX,bdryY] = rand_bdry_pts(graphX,graphY,bdryN);

% find rectangle circumscribing the graph
minx=min(graphX);
xrange=max(graphX)-minx;
miny=min(graphY);
yrange=max(graphY)-miny;

% set up for interior lists
intX=zeros(intN,1);
intY=zeros(intN,1);

% if cent is given and inside region, choose it as first point
if nargin==5
    center=cent;
    if inpolygon(real(center),imag(center),graphX,graphY)~=1
        alpha=-1;
    else
        alpha=1;
    end
end

% randomly choose points in the rectangle, keep those in the region
hits=1;
count=1;

% put alpha at center
if alpha==1;
    intX(1)=real(center);
    intY(1)=imag(center);
    hits=hits+1;
    count=count+1;
end

while hits<=intN && count<100*intN
    x=minx+rand(1,1)*xrange;
    y=miny+rand(1,1)*yrange; 
    in=inpolygon(x,y,graphX,graphY);
    if in==1
        intX(hits)=x;
        intY(hits)=y;
        hits=hits+1;
    end
end
if count==100*intN
    fprintf('overran saftey check in randTriangulation\n');
end

%% Create the constrained Delaunay triangulation
X=[intX;bdryX];
Y=[intY;bdryY];

% Contraint is closed list of index pairs of bdry edges
lgth=length(bdryX);
C=zeros(lgth,2);
for k=1:lgth-1
    C(k,1)=intN+k;
    C(k,2)=intN+k+1;
end
C(lgth,1)=intN+lgth; % close up
C(lgth,2)=intN+1;
DT=delaunayTriangulation(X,Y,C);
Tri=DT.ConnectivityList;

%% Region non-convex? trim any faces outside the boundary

convex=true;
    
% check that corners are convex
k=1;
while k<lgth && convex==true
    % get oriented edge vectors for segment k and k+1
    ed1X=X(C(k,2))-X(C(k,1));
    ed1Y=Y(C(k,2))-Y(C(k,1));
    ed2X=X(C(k+1,2))-X(C(k+1,1));
    ed2Y=Y(C(k+1,2))-Y(C(k+1,1));
    % get sign z-coord of cross product 
    zcoord=ed1X*ed2Y-ed1Y*ed2X;
    if zcoord<=0.0
        convex=false;
    end
    k=k+1;
end
    
% check last corner angle
ed1X=X(C(lgth,2))-X(C(lgth,1));
ed1Y=Y(C(lgth,2))-Y(C(lgth,1));
ed2X=X(C(1,2))-X(C(1,1));
ed2Y=Y(C(1,2))-Y(C(1,1));
% get sign z-coord of cross product 
zcoord=ed1X*ed2Y-ed1Y*ed2X;
if zcoord<=0.0
    convex=false;
end
    
% Not convex? consider trimming faces identified by:
%   * faces with all vertices on bdry; among these
%     trim only those with 3 contiguous vertices and
%     negatively oriented. 
%   * faces with one or more 'interior' vertices which
%     are actually outside the curve (bdryX,bdryY).
if ~convex
    N=length(X);
    newTri=Tri;
    sz=size(Tri);
    n=sz(1);
    count=0; % where next valid entry goes
    for j=1:n
        bad=false;
        tri=sort(newTri(j,:));
        a=tri(1);
        b=tri(2);
        c=tri(3);
        
        if a<=intN && ~inpolygon(X(a),Y(a),bdryX,bdryY) % not inside 
            bad=true;
        elseif min(tri)>=intN+1; % all are bdry
            contig=false;
            if tri==[intN+1,intN+2,N]
                a=N;
                b=intN+1;
                c=intN+2;
                contig=true;
            elseif tri==[N-2,N-1,intN+1]
                a=N-2;
                b=N-1;
                c=intN+1;
                contig=true;
            elseif c==a+2
                contig=true;
            end

            % not contiguous? then bad
            if ~contig
                bad=true;                

            % Contiguous, order <a, b, c>; bad if positively oriented.
             else
                ed1X=X(b)-X(a);
                ed1Y=Y(b)-Y(a);
                ed2X=X(c)-X(a);
                ed2Y=Y(c)-Y(a);
                % get sign z-coord of cross product 
                zcoord=ed1X*ed2Y-ed1Y*ed2X;
                if zcoord<=0.0
                    bad=true;
                end
            end
            
        end
        if ~bad % skip non-oriented bdry-only faces
            count=count+1;
            newTri(count,:)=[a,b,c];
        end
    end
    Tri=newTri(1:count,:); % may have removed some faces
end

Z=X+1i*Y; % there may be some points not appearing in any face now.
%plot(X,Y,'.r'); % for testing, see the points
return;

end

