function nodecount = complex_count(obj)
%nodecount=complex_count(GOPacker obj) Extract combinatoric info from flowers.
%   Loosely parallel to the java 'complex_count'. The GOPacker must
%   already have 'nodeCount', 'flowers' in place, vertices must be 
%   contiguously numbered from 1, and we assume the complex is simply 
%   connected.

%   First, go through vertices to find interior/bdry/other.
%   Vertices without interior neighbors can be a headache (e.g. 
%   vert with just 2 neighbors trying to be flat). 
%   Find the component of interior vertices containing 'alpha', the
%   cclw ordered closed list of vertices surrounding this component, 
%   and the list of 'orphanV', those neither interior nor bdry.

%   Here we set 'nodeCount', 'faceCount', 'edgeCount', 'vNums', 
%   'bdryFlags', 'intVerts', 'bdryList', and initialize 'layoutVerts'
%   to 'intVerts'; 'v2indx' and 'indx2v' are emptied. If there are 
%   orphans, we set 'orphanEdges'.

%   Return 'nodeCount' or -1 on error.

%% set 'tmpBdryFlags', 'alpha', and 'gamma'
alpha=obj.alpha;
flower=obj.flowers{alpha};
if flower(1)~=flower(end)
    alpha=-1; % not interior, must reset
end
gamma=obj.gamma;
if gamma==alpha
    gamma=-1; % avoid setting to 'alpha'
end

hasbdry=false;
tmpBdryFlags=zeros(1,obj.nodeCount);
for v=1:obj.nodeCount
    flower=obj.flowers{v};    
    if flower(1)==flower(end) % interior?
        tmpBdryFlags(v)=0;
        if alpha==-1
            alpha=v; % alpha defaults to first interior
        end
    else
        tmpBdryFlags(v)=1;
        if gamma==-1
            gamma=v; % gamma to first non-interior
        end
        hasbdry=true;
    end
end

if alpha==-1
    fprintf('Error: complex has no interior vertex\n');
    nodecount=-1;
    return;
end
obj.alpha=alpha;

%% sort and mark vertices 
obj.bdryList=[];
obj.layoutVerts=[];
obj.orphanVerts=[];
obj.orphanEdges=[];

%% spherical case
if ~hasbdry
    obj.hes=1;
    % cclw faux bdry {a,b,c}, some face far from alpha
    a=obj.FarVert([obj.alpha]);
    flower=obj.flowers{a};
    b=flower(2);
    c=flower(1);
    obj.bdryList=[a,b,c,a];
    obj.gamma=a;
    obj.intVerts=zeros(1,obj.nodeCount-3);
    tick=1;
    for v=1:obj.nodeCount
        if v~=a && v~=b && v~=c
            obj.intVerts(tick)=v;
            tick=tick+1;
        end
    end
    obj.orphanVerts=[];
else
    %% non-spherical
    
    % 'status' helps processing: first, find interiors component of alpha
    %    status(v)<0 ==> v interior, has been touched
    %    status(v)>0 ==> v interior, has been processed
    status=zeros(1,obj.nodeCount); 
    % 'hitlist' contains vertices we need to process and is
    %    renewed as we process it.
    hitlist(1)=alpha; 
    status(alpha)=-1;
    obj.intVerts=[];
    obj.intVerts(1)=alpha;

    while ~isempty(hitlist)
    
        % pick off the next vert to process
        v=hitlist(1);
        hitlist=hitlist(2:end);
        flower=obj.flowers{v};
        for k=1:length(flower)
            w=flower(k);
            if tmpBdryFlags(w)==0 && status(w)==0 % interior, not hit before
                status(w)=-1;
                hitlist(end+1)=w;
                obj.intVerts(end+1)=w;
            end
        end
        status(v)=1; % finished with v
    end

    % create 'tmpBdryV' list
    % Set status(w)=-1 if w neighbors interior vert
    lolong=length(obj.intVerts);
    tmpBdryV=[];
    for j=1:lolong
        flower=obj.flowers{obj.intVerts(j)};
        for k=1:length(flower)
            w=flower(k);
            if status(w)==0 % w not yet encountered
                status(w)=-1;
                tmpBdryV(end+1)=w;
            end
        end
    end

    % Organize 'bdryList' so it is cclw order
    
    % try to start with 'gamma', else set 'gamma'
    obj.bdryList=zeros(1,length(tmpBdryV)+1);
    firstbdry=obj.gamma;
    if firstbdry<1 || firstbdry>obj.nodeCount || status(firstbdry)~=-1 % choose new start
        firstbdry=tmpBdryV(1); % first bdry encountered
        obj.gamma=firstbdry;
    end
    
    % fill 'bdryList'; next nghb is first petal with contact
    tick=1;
    obj.bdryList(tick)=firstbdry;
    
    % start with 'firstbdry'
    flower=obj.flowers{firstbdry};
    for j=1:length(flower)
        nextb=flower(j);
        if status(nextb)==-1
            tick=tick+1;
            obj.bdryList(tick)=nextb;
            break;
        end
    end
       
    % cycle through from 'nextb'
    while nextb~=firstbdry && tick<2*length(tmpBdryV)
        flower=obj.flowers{nextb};
        for j=1:length(flower)
            nextb=flower(j);
            if status(nextb)==-1 % first downstream neighboring interior
                tick=tick+1;
                obj.bdryList(tick)=nextb;
                break;
            end
        end
    end
    if nextb~=firstbdry || obj.bdryList(end)~=obj.bdryList(1)
        fprintf('Error forming bdryList\n');
    end
    if tick==2*length(tmpBdryV)
        fprintf('Error in bdryList, too long\n');
    end

    % are there orphans?
    for i=1:obj.nodeCount
        if status(i)==0
            obj.orphanVerts(end+1)=i;
        end
    end
end

%% set the counts
nodecount=obj.nodeCount;
obj.intCount=length(obj.intVerts);
obj.bdryCount=length(obj.bdryList)-1;
obj.orphanCount=length(obj.orphanVerts);

obj.edgeCount=0;
obj.faceCount=0;
obj.vNum=zeros(1,obj.nodeCount);
obj.bdryFlags=zeros(1,obj.nodeCount);
totNum=0;
for v=1:obj.nodeCount
    flower=obj.flowers{v};
    num=length(flower)-1;
    obj.vNum(v)=num;
    totNum=totNum+obj.vNum(v);
    for k=1:num
        w=flower(k);
        if w>v
            obj.edgeCount=obj.edgeCount+1;
        end
    end
    if flower(1)~=flower(end)
        w=flower(end);
        if w>v
            obj.edgeCount=obj.edgeCount+1;
        end
        obj.bdryFlags(w)=1;
    end
end
obj.faceCount=totNum/3;

%% set up orphanEdges
if ~isempty(obj.orphanVerts)
    obj.orphanEdges=zeros(obj.orphanCount,2);
    
    % keep track with ctlg = -2 for interior, -1 for bdryList, 
    ctlg=zeros(1,obj.nodeCount);
    for j=1:length(obj.intVerts)
        v=obj.intVerts(j);
        ctlg(v)=-2;
    end
    for j=1:length(obj.bdryList)-1
        w=obj.bdryList(j);
        ctlg(w)=-1;
    end
    
    % find verts next to just two bdry verts, catalog them
    % and store their bdry edges.
    tick=0;
    for j=1:obj.orphanCount
        v=obj.orphanVerts(j);
        flower=obj.flowers{v};
        for k=1:obj.vNum(v)
            m=flower(k);
            n=flower(k+1);
            if ctlg(m)==-1 && ctlg(n)==-1 % successive bdryList nghbs
                obj.orphanEdges(j,:)=[n,m];
                ctlg(v)=j;
                tick=tick+1;
                break;
%           elseif ctlg(m)>0
%                obj.orphanEdges(j,:)=obj.orphanEdges(ctlg(m),:);
%            elseif ctlg(n)>0
%                obj.orphanEdges(j,:)=obj.orphanEdges(ctlg(n),:);
            end
        end
    end

    % rest eventually next to catalogued ones and inherit their bdry edges
    hit=1;
    while hit>0
        hit=0;
        for j=1:obj.orphanCount
            v=obj.orphanVerts(j);
            flower=obj.flowers{v};
            if ctlg(v)<=0
                for k=1:length(flower)
                    w=flower(k);
                    if ctlg(w)>0 % neighbor is catalogued orphan
                        hit=hit+1;
                        tick=tick+1;
                        ctlg(v)=ctlg(w);
                        obj.orphanEdges(j,:)=obj.orphanEdges(ctlg(w),:);
                    end
                end
            end
        end
    end
    if tick<obj.orphanCount;
        fprintf('Error: seem to have missed some orphans\n');
    end
    
end

% default 'layoutVerts', 'rimVerts'
obj.layoutVerts=obj.intVerts; 
obj.rimVerts=obj.bdryList;
obj.v2indx=[];
obj.indx2v=[];

end

