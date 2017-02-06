function setEffective(obj)
%setEffective(GOPacker obj) Set 'localradii' to 'effective' values.
%   Based on circle centers,  sum aims, and 'mode', use 
%   'localcenters' to compute 'effective' radii and put them 
%   in 'localradii'. We moderate boundary radii adjustments to avoid 
%   oscillations --- don't know if this is necessary or always helpful.
%   TODO: there are other options to consider for setting effective
%     radii: e.g. may want option of using old repacking computation.
%   TODO: may also want to put limits on the rate of change of radii
%     to prevent oscillation problems.

%% interior adjustments 

for k=1:length(obj.layoutVerts)
    v=obj.indx2v(k);
    targetArea=obj.vAims(v)/2.0; % often negative for bdry vertices  
    area=0;
    num=obj.vNum(v);
    z=obj.localcenters(v);
    flower=obj.flowers{v};
    for j=1:num
        jr=flower(j);
        jl=flower(j+1);
        zr=obj.localcenters(jr);
        zl=obj.localcenters(jl);
        r=.5*(abs(zr-z)+abs(zl-z)-abs(zr-zl));
        cC=cosCorner(obj.localcenters(v),obj.localcenters(jr),obj.localcenters(jl));
        ang=acos(cC);
        area=area+.5*r*r*ang; % add area of sector
    end
    
    % effective interior radius
    if targetArea>0.001 % this one needs adjustment
        obj.localradii(v)=real(sqrt(area/targetArea));
    end
end

%% bdry adjustments 

for k=1:obj.bdryCount
    w=obj.bdryList(k);
    % targetArea related to aim
    targetArea=obj.vAims(w)/2.0; % often negative for bdry vertices
    angsum=0;
    area=0;
    num=obj.vNum(w);
    z=obj.localcenters(w);
    flower=obj.flowers{w};
    for j=1:num
        jr=flower(j);
        jl=flower(j+1);
        if obj.bdryFlags(jr)>=0 && obj.bdryFlags(jl)>=0 % neither is orphan
            zr=obj.localcenters(jr);
            zl=obj.localcenters(jl);
            r=.5*(abs(zr-z)+abs(zl-z)-abs(zr-zl));
            cC=cosCorner(obj.localcenters(w),obj.localcenters(jr),obj.localcenters(jl));
            ang=acos(cC);
            angsum=angsum+ang;
            area=area+.5*r*r*ang; % add area of sector
        end
    end
    
    % effective radii
    if targetArea>0.001 % this one needs adjustment
        obj.localradii(w)=real(sqrt(area/targetArea));
       
        % the following is for (usually) bdry radii which would not 
        %   be adjusted in traditional packing method, but are
        %   adjusted in the GO approach. Change is averaged to moderate.
    elseif targetArea < -0.001 % e.g., bdry case in max packing
        obj.localradii(w)=(real(sqrt(2*area/angsum))+obj.localradii(w))/2.0; 
    end

    % Note: if 'targetArea' is between -.001 and .001, then that
    %   local radius does not change. (E.g., with 3 bdry circles
    %   in the spherical case.)
end
end

