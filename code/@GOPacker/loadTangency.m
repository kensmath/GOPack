function T = loadTangency(obj,centers,radii)
%T=loadTangency(GOPacker obj,centers,radii) Find points of tangency.
%   Given euclidean centers and radii for this packing (e.g., as computed
%   for a spherical triangulation), find the vector of tangency points
%   for use in normalization.

%% First count the number of tangency points
tcount=0;
for v=1:obj.nodeCount;
    flower=obj.flowers{v};
    n=length(flower);
    if (flower(1)==flower(end))
        n=n-1;
    end
    for j=1:n
        k=flower(j);
        if k>v
            tcount=tcount+1;
        end
    end
end
T=zeros(1,tcount);

%% Find the tangency points
tick=1;
for v=1:obj.nodeCount;
    flower=obj.flowers{v};
    n=length(flower);
    if (flower(1)==flower(end))
        n=n-1;
    end
    Z=centers(v);
    R=radii(v);
    for j=1:n
        w=flower(j);
        if w>v
            W=centers(w);
            s=radii(w)+R;
            T(tick)=Z+(R/s)*(W-Z);
            tick=tick+1;
        end
    end
end

return;
end


