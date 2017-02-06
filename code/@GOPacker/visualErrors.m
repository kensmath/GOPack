function visualErr = visualErrors(obj)
%visualErr=visualErrors(GOPacker obj) Vector of visual errors for 'layoutVerts'.
%   Using 'localradii' and localcenters', return array of max 
%   relative visual error (RVE) for vertices v in 'layoutVerts'. 
%   RVE for edge (v,w) is 
%         abs(|zv-zw|-(rv+rw))/rv; 
%   that is, compare diff between centers and sum of eucl radii 
%   (in perfect world, zero) to radius of v. 

llong=length(obj.layoutVerts);
visualErr=zeros(1,llong);
for k=1:llong
    v=obj.layoutVerts(k);
    centv=obj.localcenters(v);
    radv=obj.localradii(v);
    flower=obj.flowers{v};
    num=obj.vNum(v);
    maxerr=0;
    for j=1:num
        w=flower(j);
        cdiff=abs(centv-obj.localcenters(w));
        raddiff=radv+obj.localradii(w);
        me=abs(cdiff-raddiff)/radv;
        if me>maxerr;
            maxerr=me;
        end
    end
    visualErr(k)=maxerr;
end
end

