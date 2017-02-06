function gop = randomSphere(intN)
%GOPacker gop=randomSphere(intN) Start GOPacker with random sphere.
%   Create a 'GOPacker' object for a geometrically random triangulation 
%   of a sphere with 'intN' vertices. This is done by selecting 'intN' 
%   random points via a Poisson Point Process and then computing the 
%   Delaunay triangulation of these points. See 'randTriangulation.m'
%   for details.

gop=GOPacker();
if intN<4
    printf('randomSphere should have at least 4 points\n');
    return;
end

% Note: Z has (theta,phi) values, but not useful in GOpacker
[tri,~]=randTriangulation(intN);
gop.parse_triangles(tri);
gop.indxMatrices();

fprintf('GOpacker started with random spherical triangulation, %d vertices\n',gop.nodeCount);

end

