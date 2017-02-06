function aspect = getAspect(obj)
%aspect=getAspect(GOPacker obj) Return aspect for rectangular packings.
%   If GOPacker is in mode 2 with 4 corners, then compute
%   the aspect, usually after packing and laying out.
%   Aspect is ratio of lengths: (top+bot)/(left+right).

aspect =-1;
if obj.mode~=2 || length(obj.corners)~=4
    fprintf('Aspect usage: should be mode 2 and have 4 corners\n');
    return;
end

top=abs(obj.localcenters(obj.corners(2))-obj.localcenters(obj.corners(1)));
rend=abs(obj.localcenters(obj.corners(4))-obj.localcenters(obj.corners(1)));
lend=abs(obj.localcenters(obj.corners(3))-obj.localcenters(obj.corners(2)));
bot=abs(obj.localcenters(obj.corners(4))-obj.localcenters(obj.corners(3)));
aspect =(top+bot)/(rend+lend);

end

