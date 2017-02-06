function [cosang] = cosCorner(z1,z2,z3)
%[cosang] = cosCorner(z1,z2,z3) Get cos of angle at z1 in given triangle
%   Find cosine of angle at z1 in triangle with given centers

l2=abs(z2-z1);
l3=abs(z3-z1);
l23=abs(z3-z2);
denom=2*l2*l3;
cosang=(l2*l2+l3*l3-l23*l23)/denom;
cosang = max(min(cosang,1),-1);  % force to be between -1 and 1

end

