function P = sph_tangent(ctr1,ctr2)
%P = sph_tangent(ctr1,ctr2) unit length vector tangent to sphere
%   Given two points on the sphere in (theta,phi) polar form,
%   return 3D vector in tangent space of the sphere at ctr1 and 
%   pointing towards ctr2. If pts are essentially equal or antipodal, 
%   return vector orthogonal to ctr1.

S_TOLER=.00000000001;
A=s_pt_to_vec(ctr1);
B=s_pt_to_vec(ctr2);
d=A(1)*B(1)+A(2)*B(2)+A(3)*B(3);  % dot product
% find proj of B on plane normal to A
P=B-d*A;

% A and B essentially parallel?
vn=sqrt(P(1)^2+P(2)^2+P(3)^2);
if vn<S_TOLER
    pn=sqrt(A(2)^2+A(3)^2);
    if pn>.001 % get orthogonal, with x-coord 0
        P=[0,A(2)/pn,(-1.0)*A(3)/pn];
    else
        P=[1,0,0];
    end
    return;
end

% else
P=P/vn;

end

