function layoutCenters(obj)
%layoutCenters(GOPacker obj) Tutte-style embedding of interior verts
%   Use 'localradii' and bdry 'localcenters' to compute
%   'localcenters' for the 'layoutVerts'.
%   Recall that matrices/vectors use sequential indexing;
%   use 'indx2v' and 'v2indx' to translate between these 
%   and original vertices.

%% First update 'inRadii' (cells) for layoutVerts using
% sequential indexing.
% inRadii{v} is vector of radii of incircles for faces
% based on 'localradii'.
updateVdata(obj);

layCount=length(obj.layoutVerts);
colCount=length(obj.indx2v)-layCount;

%% create sparse matrix A, m-by-m, where m=layCount
Aentries=zeros(1,obj.tranIJcount);
for k=1:obj.tranIJcount
    v=obj.indx2v(obj.tranI(k));
    vrad=obj.localradii(v);
    num=obj.vNum(v);
    iR=obj.inRadii{obj.v2indx(v)};
    flower=obj.flowers{v};
    j=obj.tranJindx(k);
    if j>0 
        if j==1
            t1=iR(num);
        else
            t1=iR(j-1);
        end
        if j>length(iR)
            continue;
        end
        t2=iR(j);
        w=flower(j);
        Aentries(k)=((t1+t2)/(vrad+obj.localradii(w)))/obj.conduct(obj.v2indx(v));
    else % edge to self if j=-1
        Aentries(k)=-1.0;
    end
end

obj.transMatrix=sparse(obj.tranI,obj.tranJ,Aentries);

%% create matrix B, m x n where m=layCount, n=colCount
Bentries=zeros(1,obj.rhsIJcount);
for k=1:obj.rhsIJcount
    v=obj.indx2v(obj.rhsI(k));
    vrad=obj.localradii(v);
    j=obj.rhsJindx(k);
    num=obj.vNum(v);
    iR=obj.inRadii{obj.v2indx(v)};
    flower=obj.flowers{v};
    if j==1
        t1=iR(num);
    else
        t1=iR(j-1);
    end
    t2=iR(j);
    w=flower(j);
    Bentries(k)=-1.0*((t1+t2)/(vrad+obj.localradii(w)))/obj.conduct(obj.v2indx(v));
end

obj.rhsMatrix=sparse(obj.rhsI,obj.rhsJ,Bentries,layCount,colCount);

%% right hand side is B * vector of bdry centers
zb=zeros(1,colCount);
for m=1:colCount
    zb(m)=obj.localcenters(obj.indx2v(layCount+m));
end
obj.rhs=obj.rhsMatrix*zb.'; % note the non-conjugate transpose

%% set centers
Z=obj.transMatrix\obj.rhs;
for k=1:layCount
    obj.localcenters(obj.indx2v(k))=Z(k);
end
end
