function indxMatrices(obj,varlist)
%indxMatrices(GOPacker obj,[varlist]). Various important initializations.
%   If 'varlist' is provided, then 'obj.layoutVerts' is reset to include
%   all the interior vertices in 'varlist'. If 'varlist' is not provided,
%   then we use 'obj.layoutVerts' as it exists.
%   Matrices involve neighbor relationships among vertices. We 
%   must list neighbors of 'layoutVerts' (not in 'layoutVerts') in the
%   closed (not necessarily oriented) list 'rimVerts'. Then we reindex 
%   the vertices in 'layoutVerts' to go from 1 to 'layCount', which 
%   is length(layoutVerts), then reindex 'rimVerts' to go from layCount 
%   to length(rimVerts): these are the neighbor verts required in the 
%   right hand side matrices.
% 
%   Note: This is the only method where we change 'layoutVerts' and 
%   'rimVerts', the only place we create 'v2indx' and 'indx2v' for 
%   translating between true indices and new indices of vertices. 

%% Create 'layoutVerts' and 'rimVerts'
if nargin<2 || isempty(varlist) % no varlist, then use 'layoutVerts'
    if isempty(obj.layoutVerts)
        obj.layoutVerts=obj.intVerts;
        obj.rimVerts=obj.bdryList;
    end
else % create 'layoutVerts' from interior vertices in 'varlist'
    status=zeros(1,obj.nodeCount);
    if obj.hes==1 % have to avoid faux bdry vertices, set status = 2
        for j=1:length(obj.bdryList)
            status(obj.bdryList(j))=2;
        end
    end
    
    % mark interiors of 'varlist' and nghbs
    obj.layoutVerts=[];
    for j=1:length(varlist);
        v=varlist(j);
        flower=obj.flowers{v};
        % want interior, avoid repeats and faux bdry
        if flower(1)==flower(end) && status(v)<=0 
            for k=1:(obj.vNum(v)+1);
                w=flower(k);
                if status(w)==0
                    status(w)=-1;
                end
            end
            obj.layoutVerts(end+1)=v; % build up 'layoutVerts'
            status(v)=1;
        end
    end
    
    % other marked ones are in 'rimVerts'
    obj.rimVerts=[];
    for v=1:obj.nodeCount
        if status(v)<0
            obj.rimVerts(end+1)=v;
        end
    end
    
    % if we got all interiors, revert to 'intVerts' and 'bdryList'
    if length(obj.layoutVerts)==obj.intCount
        obj.layoutVerts=obj.intVerts;
        obj.rimVerts=obj.bdryList;
    end
end

lolong=length(obj.layoutVerts);

%% build 'indx2v' and 'v2indx'; 'layoutVerts' first, then 'rimVerts'
obj.v2indx=zeros(1,obj.nodeCount);
obj.indx2v=[];
for j=1:lolong;
    obj.indx2v(end+1)=obj.layoutVerts(j);
    obj.v2indx(obj.layoutVerts(j))=j;
end

% and finish with 'rimVerts'
for j=1:length(obj.rimVerts)-1
    w=obj.rimVerts(j);
    obj.indx2v(end+1)=w;
    obj.v2indx(w)=length(obj.indx2v);
end

if nargin==1 && min(obj.v2indx)==0
    fprintf('Warning: not all vertices have interior neighbors;\n');
    fprintf('  there may be packing or layout problems.\n');
end

%% set up tranI/J/Jindx, rhsI/J/Jindx; cut down to right size later
ijCount=0;
for k=1:lolong
    ijCount=ijCount+obj.vNum(obj.indx2v(k))+1;
end

tranI=zeros(1,ijCount);
tranJ=zeros(1,ijCount);
tranJindx=zeros(1,ijCount);
rhsI=zeros(1,ijCount);
rhsJ=zeros(1,ijCount);
rhsJindx=zeros(1,ijCount);

kj=1; % count the tran entries
kw=1; % count the rhs entries
for k=1:lolong
    v=obj.indx2v(k);
    
    % diagonal entry first
    tranI(kj)=k;
    tranJ(kj)=k;
    tranJindx(kj)=-1; % indicates edge to self
    kj=kj+1;
    
    % now petal entries
    flower=obj.flowers{v};
    num=size(flower,2)-1;
    for j=1:num
        w=flower(j);
        if (obj.v2indx(w)<=lolong) % interior petal
            tranI(kj)=k;
            tranJ(kj)=obj.v2indx(w);
            tranJindx(kj)=j;
            kj=kj+1;
        else % bdry petal 
            rhsI(kw)=k;
            rhsJ(kw)=obj.v2indx(w)-lolong; % offset by layCount for later use
            rhsJindx(kw)=j;
            kw=kw+1;
        end
    end
end

% store this info at the proper sizes
obj.tranIJcount=kj-1;
obj.rhsIJcount=kw-1;
obj.tranI=tranI(1:kj-1);
obj.tranJ=tranJ(1:kj-1);
obj.tranJindx=tranJindx(1:kj-1);
obj.rhsI=rhsI(1:kw-1);
obj.rhsJ=rhsJ(1:kw-1);
obj.rhsJindx=rhsJindx(1:kw-1);

end
