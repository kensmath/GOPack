function updateVdata(obj)
%updateVdata(GOPacker obj) Update 'sectorTan' and 'conduct' data
%   Based on 'localradii', compute vectors of 'inRadii' and total 
%   'conduct's for vertices in 'layoutVerts'. These are part of
%   the random walk model for circle packings.
%   'inRadii' is a 'cell' of vectors, for each interior v 
%   inRadii{v}(j) is the radius of the incircle of the triangle
%   determined by the three entries in 'localradii' and is used 
%   to compute edge conductances. We also need 'conduct', the node 
%   conductances. Recall that matrices/vectors use sequential indexing;
%   use 'indx2v' and 'v2indx' to translate between these 
%   and original vertices.

layCount=length(obj.layoutVerts);
if layCount==0
    fprintf('Error: "layoutVerts" was empty.\n');
end    

%% update 'inRadii'
obj.inRadii=cell(layCount,1);
for k=1:layCount
    v=obj.indx2v(k);
    vrad=obj.localradii(v);
    flower=obj.flowers{v};
    data=zeros(1,obj.vNum(v));
    u=flower(1);
    urad=obj.localradii(u);
    for j=1:obj.vNum(v)
        wrad=urad;
        u=flower(j+1);
        urad=obj.localradii(u);
        data(j)=sqrt((vrad*urad*wrad)/(vrad+urad+wrad));
    end
    obj.inRadii{k}=data;
end

%% update total conductances for 'layoutVerts'
obj.conduct=zeros(1,layCount);
for k=1:layCount
    v=obj.indx2v(k);
    vrad=obj.localradii(v);
    iR=obj.inRadii{k};
    num=obj.vNum(v);
    flower=obj.flowers{v};
    w=flower(1);
    obj.conduct(k)=(iR(num)+iR(1))/(vrad+obj.localradii(w));
    for j=2:num
        t1=iR(j-1);
        t2=iR(j);
        w=flower(j);
    	obj.conduct(k)=obj.conduct(k)+(t1+t2)/(vrad+obj.localradii(w));
    end
end

end

