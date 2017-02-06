function sz = proj_vec_to_s(vec)
%sz = proj_vec_to_s(vec) project a 3D vector to sz on the sphere
%   sz is form (theta,phi). if the norm of 'vec' is too small,
%   return 0.0 (the north pole).

% default for things near origin 
S_TOLER=.0000000000001;
dist=norm(vec,2);
if dist<S_TOLER
    sz=0.0;
    return;
end

sz=atan2(vec(2),vec(1))+acos(vec(3)/dist)*1i;

end

