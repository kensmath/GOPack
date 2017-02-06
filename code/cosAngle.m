function [cosang] = cosAngle(r,r1,r2)
%[cosang] = cosAngle(r,r1,r2) Compute cosine of angle at r for radii {r,r1,r2}
%   Given euclidean radii r, r1, r2, find cos of angle
%   formed at r in a triple of tangent circles of these radii

c=r1*r2;
cosang=1-2*c/(r*r+r*(r1+r2)+c);
 
end

