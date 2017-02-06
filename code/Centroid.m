function [normsq,X,Y,Z] = Centroid(P,trans)
% function [normsq,X,Y,Z] = Centroid(P,trans)
%[normsq,X,Y,Z]=Centroid(P,a,b,c) Find centroid of transformed points.
%   Given N-by-2 vector 'P' of complex points and list 'trans'
%   of three real numbers a, b, c, compute the centroid of the sterographic 
%   projection of the points to the unit sphere after applying 
%   transformation M given by
%       M(z) = a*z + b + i*c
%   Centroid in 3-space is (X,Y,Z), squared norm is 'normsq'.
%   Goal is to be able to minimize 'normsq' over all choices of a, b, c.
%
%   stereo projection of point (u,v) to (x,y,z) on the sphere is given by
%      x=u*2/(1+(u^2+v^2))
%      y=v*2/(1+(u^2+v^2))
%      z=(1-(u^2+v^2))/(1+(u^2+v^2))
%
%   Transformation is
%      M(u,v)=((au+b),(av+c))=(mu,mv)

mu = trans(1)*real(P(:)) + trans(2);
mv = trans(1)*imag(P(:)) + trans(3);

sq = mu.^2 + mv.^2;
denom = 1 + sq;
x = 2*mu./denom;
y = 2*mv./denom;
z = (1-sq)./denom;

X=mean(x);
Y=mean(y);
Z=mean(z);

normsq=X^2+Y^2+Z^2;

end

