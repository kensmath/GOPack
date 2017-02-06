function diffs = angsumErrors(obj,radii)
%diff=angsumErrors(GOPacker obj,[rad]) Vector of angle sum errors.
%   Use vector 'radii' if given (length should be nodeCount), 
%   else use 'localradii'. Return vector (length of 'layoutVerts') 
%   of angle sum errors: In particular, diffs(k) = anglesum(v)-2*pi, 
%   where v=obj.indx2v(k)

% default to 'localradii'
if nargin<2
    radii=obj.localradii;
end

target = -2.0*pi;
diffs=zeros(1,length(obj.layoutVerts));
for k=1:length(obj.layoutVerts)
    v=obj.indx2v(k);
    diff=target;
    r=radii(v);
   	num=obj.vNum(v);
    flower=obj.flowers{v};
    u=flower(1);
    for j=1:num 
        w=u;
        u=flower(j+1);
        diff=diff+acos(cosAngle(r,radii(w),radii(u)));
    end
    diffs(k)=diff;
end

end

