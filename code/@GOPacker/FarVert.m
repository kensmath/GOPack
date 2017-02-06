function farvert = FarVert(obj,seeds)
%farvert=FarVert(GOPacker gop,seeds) Find vertex far from 'seeds'. 
%   Intention is to get a vertex which is far from 'seeds' list of
%   vertices. We look up to 10 generations deep. If we haven't reached
%   all vertices, we randomly choose from those deeper than 10. 
%   Return -1 on error (e.g., 'seeds' empty, obj problems, etc.)

nodecount=obj.nodeCount;
marks=zeros(nodecount,1);
if isempty(seeds)
    farvert=-1;
    return;
end

%% juggle two lists, 'curr' and 'nextlist'
nextlist=seeds;
gennum=1;
farvert=seeds(1);
nothits=nodecount;
while ~isempty(nextlist) && (gennum<10 || nothits<100)
    % debug    fprintf('gennum=%d\n',gennum);
    getnonz=0;
    for j=1:length(nextlist)
        if nextlist(j)>0
            getnonz=getnonz+1;
        end
    end
    curr=nextlist(1:getnonz);
    nextlist=zeros(getnonz*5,1);
    nextend=0;
    for j=1:length(curr)
        k=curr(j);
        if marks(k)<1
            nothits=nothits-1;
        end
        marks(k)=gennum;
        farvert=k;
        flower=obj.flowers{k};
        for m=1:length(flower)
            p=flower(m);
            if marks(p)==0
                nextlist(nextend+1)=p;
                nextend=nextend+1;
            end
        end
    end
    nextlist=nextlist(1:nextend); % trim zeros
    gennum=gennum+1;
end

% if we visited most vertices, current 'farvert' should be deep
if nothits<=100
    return;
end

%% reaching here, should have searched to depth 10 with lots 
%   of vertices yet unreached. So we choose 'farvert' randomly 
%   among the unreached vertices.
farvert=0;
while farvert==0
    k=randi(nodecount);
    if marks(k)==0
        farvert=k;
        return;
    end
end
return;
end

