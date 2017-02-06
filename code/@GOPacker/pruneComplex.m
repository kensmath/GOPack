function cutCount = pruneComplex(obj)
%cutCount=pruneComplex(GOpacker obj) modify data to remove orphan vertices.
%   We modify the data in a 'GOpacker' object to remove orphan vertices.
%   The 'orphan's vertices outside an interior component 'intV' and its 
%   immediate neighbors 'bdryV'. Currently this is only used when orphans
%   occur during creation of the 'GOPacker', and is currently used only 
%   for random rectangles and squares (though it may be useful in other
%   situations in the future). Return the number of vertices cut out.

cutCount=0;
if obj.orphanCount==0 % if no orphans, just return
    return;
end

%% set new indices
bdryCount=length(obj.bdryList)-1;
newNodeCount=obj.intCount+bdryCount;
v2indx=zeros(1,obj.nodeCount);
indx2v=zeros(1,newNodeCount);
for j=1:obj.intCount
    v=obj.intVerts(j);
    indx2v(j)=v;
    v2indx(v)=j;
end
for j=1:bdryCount
    w=obj.bdryList(j);
    indx2v(obj.intCount+j)=w;
    v2indx(w)=obj.intCount+j;
end

%% fix combinatorics

vNum=zeros(1,newNodeCount);
vAims=zeros(1,newNodeCount);
intCount=length(obj.intVerts);
faceCount=0;
newFlowers=cell(newNodeCount,1);

% go through the interiors
for nv=1:intCount
    v=obj.intVerts(nv);
    vNum(nv)=obj.vNum(v);
    vAims(nv)=obj.vAims(v);
    newflower=obj.flowers{v};
    for j=1:vNum(nv)+1
        w=newflower(j);
        newflower(j)=v2indx(w);
    end
    newFlowers{nv}=newflower;
    faceCount=faceCount+vNum(nv);
end

% go through the bdry
for nv=intCount+1:newNodeCount
    v=indx2v(nv);
    num=obj.vNum(v);
    newnum=0;
    flower=obj.flowers{v};
    
    % find first non-orphan
    tick=0;
    spot=0;
    while spot==0 && tick<num
        w=flower(tick+1);
        if (v2indx(w)>0)
            spot=tick+1;
        else
            tick=tick+1;
        end
    end
    
    % build the flower
    newflower=zeros(num+2-spot,1);
    countoff=0;
    for j=spot:num+1
        w=flower(j);
        nw=v2indx(w);
        if nw~=0
            countoff=countoff+1;
            newflower(countoff)=nw;
            newnum=newnum+1;
        else
            break;
        end
    end
    vNum(nv)=newnum-1;
    vAims(nv)=-1.0;
    newFlowers{nv}=newflower(1:countoff);
    faceCount=faceCount+vNum(nv);
end

% organize combinatorial stuff
cutCount=obj.nodeCount-newNodeCount;
obj.nodeCount=newNodeCount;
obj.orphanVerts=[];
obj.orphanCount=0;
obj.flowers=newFlowers;
obj.vAims=vAims;

% translate int and bdry lists ('bdryList' is already in order)
for v=1:intCount
    obj.intVerts(v)=v2indx(obj.intVerts(v));
end
for w=1:length(obj.bdryList)
    obj.bdryList(w)=v2indx(obj.bdryList(w));
end
obj.alpha=v2indx(obj.alpha);
obj.gamma=obj.bdryList(1);

% main organization
obj.complex_count();

%% translate various data

% non-empty 'vlist'?
vlist=obj.vlist;
obj.vlist=[];
if ~isempty(vlist)
    for j=1:length(vlist)
        v=obj.vlist(j);
        nv=v2indx(v);
        if nv>0
            obj.vlist(end+1)=nv;
        end
    end
end

% various centers/radii
origCenters=zeros(1,newNodeCount);
centers=zeros(1,newNodeCount);    
localcenters=zeros(1,newNodeCount);    
origRadii=zeros(1,newNodeCount);
radii=zeros(1,newNodeCount);
localradii=zeros(1,newNodeCount);
for nv=1:newNodeCount
    v=indx2v(nv);
    if ~isempty(obj.origRadii) && ~isempty(obj.origCenters)
        origRadii(nv)=obj.origRadii(v);
        origCenters(nv)=obj.origCenters(nv);
    end
    radii(nv)=obj.radii(v);
    centers(nv)=obj.centers(v);
    localradii(nv)=obj.localradii(v);
    localcenters(nv)=obj.localcenters(v);
end

%% attach all new stuff
obj.origRadii=origRadii;
obj.origCenters=origCenters;
obj.radii=radii;
obj.centers=centers;
obj.localradii=localradii;
obj.localcenters=localcenters;

%% outdated stuff
obj.angsumMonitor=[];
obj.l2Monitor=[];
obj.visErrMonitor=[];
obj.ticMonitor=[];
obj.corners=[];
obj.sides=[];

%% report and return
fprintf('Packing %s was pruned of %d orphan vertices\n',obj.fileName,cutCount);

end