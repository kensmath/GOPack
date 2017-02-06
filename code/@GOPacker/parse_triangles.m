function [facecount,newIndx,oldIndx] = parse_triangles(obj,tList,cents)
%[facecount,newIndx,oldIndx]=parse_triangles(GOPacker obj,tList,[cents]) 
%   Convert n x 3 triangulation matrix to a GOpacker; vector 'cents'
%   of centers is optional. We generate the combinatoric data and 
%   initialize our GOpacker. The orientation is determined by the first 
%   face and all connected faces go into the result; at the end, we ensure 
%   the vertices are contiguously numbered from 1, the user can refer to
%   'newIndx' and 'oldIndx' vectors to convert to original numbering.
%   Also return obj.faceCount. 
%   If 'cents' is given, it should have complex entry for every index
%   from 1 to the maximal vertex number encountered in 'tList'; these 
%   may represent (theta,phi) in spherical case.
%   
%   This code is taken from CirclePack's Java 'parse_triangles'.

holdalpha=obj.alpha;
obj.cleanse(); % clear out old data
obj.alpha=holdalpha;

%% number of faces and range of indices encountered
s=size(tList);
N=s(1);
obj.edgeCount=0;
obj.faceCount=N;
bottom=tList(1,1); % first vertex

% CHECK
top=0;
for f=1:N
    for j=1:3
        v=tList(f,j);
        if (v<bottom)
            bottom=v;
        end
        if (v>top)
            top=v;
        end
    end
end

%% store initial count of faces containing each node
clicks=zeros(1,top);
for f=1:N
    for j=1:3
        v=tList(f,j);
        clicks(v)=clicks(v)+1;
    end
end

%% make list of faces for each node
nodefaces=cell(1,top);
vnum=zeros(1,top);
for f = 1:N
    for j=1:3
        v = tList(f,j);
		% first visit to this vertex? allocate space
        if vnum(v) == 0
    		nodefaces{v} = zeros(1,clicks(v));
        end
        % add face to list for this vertex and increment the index
		vnum(v)=vnum(v)+1;
        nodefaces{v}(vnum(v)) = f;
    end
end

%% Start with first vertex of first face, build its flower,
% noting with 'utilFlag=-1/-2' when it's done (int/bdry). 
% Each petal's 'utilFlag' indicates which face generated it 
% Now search vertices for one that's been hit but is not done
% and repeat the processing until all vertices discovered are 
% have their 'tmpflower' done. (Some may not be discovered if 
% the triangulation is disconnected.)
% After getting the flowers, we have to go through and check
% orientations.
tmpflower=cell(1,top); % this will hold flowers until renumberd
utilFlag=zeros(1,top); % 0, not yet encountered; -1, done (interior); 
    % -2, done (bdry); f, added by face f
faceOrder=zeros(1,N);  % 1 ==> face touched (hence reoriented, if necessary)

target = tList(1,1); % first vertex of first face
faceOrder(1)=1;
utilFlag(target) = 1;
while target ~= 0
	first_face = utilFlag(target);
	fvert = tList(first_face,1:3);

    % must find first_face's index in target's nodefaces
	ffindx = 0;
    for i=1:vnum(target)
        if nodefaces{target}(i) == first_face
            ffindx = i;
            break;
        end
    end
    % make room, allowing for growth forward or back
    preflower=zeros(1,2*vnum(target)+4);

    % handle first face separately: put verts in middle of preflower space
	front = 0;
	back = 0;
    for j=1:3
        if fvert(j) == target
            % put first two neighbors in middle and in proper order
            v1=fvert(1+mod(j,3));
            v2=fvert(1+mod(j + 1,3));
            back = vnum(target);
			front = back + 1;
            preflower(back) = v1;
            preflower(front) = v2;
            
			% indicate which face was used
            if utilFlag(preflower(back)) == 0
        		utilFlag(preflower(back)) = first_face;
            end
            if utilFlag(preflower(front)) == 0
				utilFlag(preflower(front)) = first_face;
            end
			nodefaces{target}(ffindx) = 0; % this face has been used
            break;
        end
    end

    % now add petals forward (counterclockwise), then backward.

    % forward
	hit = 1;
    while hit ~= 0 && preflower(front) ~= preflower(back)
        hit = 0;
		v = preflower(front);
        for i=1:vnum(target)
            next_face=nodefaces{target}(i);
            if next_face > 0 && hit==0 % face not yet used
				fvert = tList(next_face,1:3);
                w=0;
                % find edge (target,v) or (v,target)
                for j=1:3
                    if fvert(j)==target
                        va=fvert(1+mod(j,3));
                        vb=fvert(1+mod(j+1,3));
                        if va==v
                            w=vb;
                            faceOrder(next_face)=1;
                        elseif vb==v % must reverse this face
                            w=va;
                            holdv=tList(next_face,1);
                            tList(next_face,1)=tList(next_face,2);
                            tList(next_face,2)=holdv;
                            faceOrder(next_face)=1;
                        end
                        break;
                    end
                end
                if w > 0
					front=front+1;
					preflower(front) = w;
                    if utilFlag(w) == 0 % first encounter for w?
						utilFlag(w) = next_face;
                    end
					hit = 1;
					nodefaces{target}(i) = 0; % this face has been used
                end
            end
        end		
    end % done with forward direction
    
    % flower open? must be bdry, so add petals backward
    if preflower(front) ~= preflower(back)
        hit = 1;
        while hit ~= 0 && preflower(front) ~= preflower(back)
            hit = 0;
            w=preflower(back);
            for i = 1:vnum(target)
                next_face=nodefaces{target}(i);
                if hit==0 && next_face > 0
                    fvert = tList(next_face,1:3);
                    % find edge (target,w) or (w,target)
                    v=0;
                    for j=1:3
                        if fvert(j)==target                    
                            wa=fvert(1+mod(j,3));
                            wb=fvert(1+mod(j+1,3));
                            if wb==w
                                v=wa;
                                faceOrder(next_face)=1;
                            elseif wa==w % must reverse this face
                                v=wb;
                                holdv=tList(next_face,1);
                                tList(next_face,1)=tList(next_face,2);
                                tList(next_face,2)=holdv;
                                faceOrder(next_face)=1;
                            end
                            break;
                        end
                    end
                    if v > 0
						back=back-1;
						preflower(back) = v;
                        if utilFlag(v) == 0 % first encounter for v?
                            utilFlag(v) = next_face;
                        end
						hit = 1;
                        nodefaces{target}(i) = 0; % this face has been used								nodefaces[target][i] = 0; // this face has been
                    end
                end
            end
        end
    end % done with backward

    % done with target; fix up its tmpflower and mark as bdry/int
    tmpflower{target}=preflower(back:front);
    if preflower(back) == preflower(front)
        utilFlag(target)=-1; % interior 
    else
        utilFlag(target)=-2; % bdry
    end
    
    % find the next vertex encountered but not done.
    target=0;
    for v=1:top
        if utilFlag(v)>0
            target=v;
            break;
        end
    end
end % end of while

%% Now 'tmpflower' should be complete. We need to check that
% vertices actually encountered are number from 1 to nodeCount,
% then fill in the GOpacker data.
% Note: could do check here that we've used all the faces,
%    but for now, we just forget this and use what faces we get.

newIndx=zeros(1,top);
oldIndx=zeros(1,top);
tick=0;
nextv=1;
while nextv<= top
    if utilFlag(nextv)<0 % should have a flower for nextv
        tick=tick+1;
        newIndx(nextv)=tick;
        oldIndx(tick)=nextv;
    end
    nextv=nextv+1;
end
oldIndx=oldIndx(1:tick);

%% set nodeCount, allocate flowers, put reindexed verts in flowers
obj.nodeCount=tick;
obj.flowers=cell(1,tick);
obj.vAims=zeros(1,tick);
bdryCount=0;
nextv=1;
while nextv<=top
    if utilFlag(nextv)<0
        v=newIndx(nextv);
        n=length(tmpflower{nextv});
        obj.vNum(v)=n-1;
        newflower=zeros(1,n);
        for i=1:n
            oldv=tmpflower{nextv}(i);
            newflower(i)=newIndx(oldv);
        end
        obj.flowers{v}=newflower;
        if utilFlag(nextv)==-2 % bdry
            bdryCount=bdryCount+1;
            obj.gamma=v; % set gamma
            obj.vAims(v)=-1.0;
        else % interior
            obj.vAims(v)=2*pi;
        end
    end
    nextv=nextv+1;
end

%% if alpha not already set, choose deep alpha
if isempty(obj.alpha) || obj.alpha(1)==0
    seeds=zeros(1,obj.nodeCount);
    tick=1;
    for j=1:obj.nodeCount
        if utilFlag(j)==-2 % bdry
            seeds(tick)=j;
            tick=tick+1;
        end
    end

    % find an alpha far from seed
    if tick>1 
        seeds=seeds(1:tick-1); % trim 'seeds'
        alpha=obj.FarVert(seeds);
        if alpha<0
            fprintf('error in setting alpha\n');
            obj.alpha=1;
        else
            obj.alpha=alpha;
        end
    else % sphere? set 'alpha' to 1
        obj.alpha=1;
    end
end
%% organize combinatorics
obj.complex_count();
if bdryCount==0
    obj.hes=1; % sphere?
else
    obj.hes=0; % default to euclidean
end

% ----------------- end of comb processing -----------

%% finish with centers/radii. Note: calling routine needs to 
%  call 'indxMatrices'
facecount=obj.faceCount;

obj.radii=ones(1,obj.nodeCount)*.5; % default to 1/2
obj.localradii=obj.radii;

% store 'cents' if given, else default
obj.centers=zeros(1,obj.nodeCount);
obj.localcenters=obj.centers;
if nargin==3
    if length(cents)<top
        fprintf('error: given "cents" vector is not the right length.\n');
    else
        for v=1:obj.nodeCount
            j=oldIndx(v);
            if j~=0
                obj.centers(v)=cents(j);
            end
        end
        obj.localcenters=obj.centers;
    end
end
   
fprintf('GOpacker is ready with triangulation having %d faces\n',facecount);

end