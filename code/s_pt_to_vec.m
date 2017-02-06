function vec = s_pt_to_vec(sz)
%vec = s_pt_to_vec(sz) Convert point on unit sphere to unit 3-vector.
%   sz is in spherical coords (theta,phi).

s=sin(imag(sz));
c=cos(real(sz));
vec=[s*c,s*sin(real(sz)),cos(imag(sz))]; % 3D vector

end

