function md = setMode(obj,md_in,crns,angs)
%md=setMode(GOPacker obj,md_in,[crns,[angs]]) Set 'mode' of the GOPacker
%   md_in = intended mode: 1 = max pack; 2 = polypack; 
%   (Note: developmental version has more options.)
%   If needed, 'crns' is list of corner vertices (using original indices)
    %   1: max pack in disc or sphere. 
    %   2: polygon pack; provide counterclockwise corners (or use
    %      'vlist' or choose pseudorandomly for rectangle); 
    %      corner angles are set equal (e.g., for rect, pi/2)
    %   -1: error
%   If given, 'angs' are the corner angles corresponding to 'crns';
%   default to equal angles.
%   GOPacker.mode is set and returned as 'md'; -1 on error.

% Is there a packing
if isempty(obj.hes) || obj.nodeCount<1
    fprintf('GOpacker seems to have no packing.\n');
    md=-1;
    obj.mode=-1;
    return;
end

%% set defaults and determine 'mode'
md=1; % mode to be returned; m_in may be changed
m=1;
sideN=4; % default number of sides for a polygon
corners=[]; % local listing of corners, if needed

% read the intended mode, either 1 or 2
if nargin>=2
    m=max(md_in,1);
    if m<1 || m>2
        fprintf('Mode choices: 1 = max packing, 2 = polygonal packing.\n');
        md=-1;
        return;
    end
    md=m;
end

% Sphere, mode must be max
if m>1 && obj.hes>0
   fprintf('Mode must be %s for a sphere.\n',obj.PACKMODES{1});
   md=1;
   m=1;
end

%% default: mode=1, traditional max packing; ignore other arguments
if m==1
    obj.vAims = 2*pi*ones(1,obj.nodeCount);
    for w=1:obj.nodeCount
        if obj.bdryFlags(w)~=0
           obj.vAims(w)=-1.0; % neg aims on bdry
        end
    end

    obj.mode=md;

    fprintf('Mode is set to %s\n',obj.PACKMODES{obj.mode});
    return;
end

%% else 'm' ==2; if 'crns' is given, validate it and use 'angs' if given
if nargin>=3
    cln=length(crns);
    
    % empty? too short?
    if cln==0 || cln==2
        fprintf('Error: list of corners is empty or too short\n');
        obj.mode=-1;
        md=-1;
        return;
    end
    
    % length 1? then this is integer giving sideN
    if cln==1
        if floor(crns(1))>2
            sideN=floor(crns(1));
            if ~isempty(obj.vlist)
                if length(obj.vlist)>sideN
                    obj.vlist=obj.vlist(1:sideN); % truncate
                elseif length(obj.vlist)<sideN
                    obj.vlist=[]; % discard 'vlist'
                end
            end
        end
        
    % else, put in 'corners'
    else
        sideN=cln;        
        corners=zeros(sideN,1);

        % check for boundary
        for k=1:cln
            if obj.bdryFlags(crns(k))~=1
                fprintf('Error: Your given "corner" %d is not a boundary vertex\n',crns(k));
                obj.mode=-1;
                md=-1;
                return;
            end
            corners(k)=crns(k);            
        end
    end
    
    % given corner angles?
    if nargin>=4
        if length(angs)~=sideN
            fprintf('Numbers of corner vertices and angles do not match');
            md=-1;
            obj.mode=-1;
            return;
        end
    
        % turning angles (pi-aim) should sum to 2*pi
        if abs(sideN*pi-sum(angs)-2*pi)>.01
            fprintf('Corner angles are not consistent with polygon turning angles');
            md=-1;
            obj.mode=-1;
            return;
        end
    end
        
end

%% polygonal case requires corners: 

% Corners not given? take bdry vertices in 'vlist' and infer sideN
if isempty(corners) && length(obj.vlist)>=3
    vln=length(obj.vlist);
    corners=zeros(vln,1);
    mctn=0;
    for k=1:vln
        if obj.bdryFlags(obj.vlist(k))~=0
            mctn=mctn+1;
            corners(mctn)=obj.vlist(k);
        end
    end
    if mctn<3 % didn't get enough? default to random below
        corners=[]; 
    else
        sideN=mctn;
        corners=corners(1:sideN); % trim to right length
    end
end
    
% Still no corners? choose 'sideN' corners randomly
if isempty(corners)
    bl=length(obj.bdryList);
    if bl<3 % error
        fprintf('The boundary has only %d vertices\n',bl);
        obj.mode=-1;
        md=-1;
        return;
    elseif bl==3         % triangle
        sideN=3;
    elseif bl<sideN   % bl is maximum number of sides
        sideN=bl;
    end
       
    corners=zeros(sideN,1);
    fth=floor(bl/sideN);
    sd=randi(bl);
    for e=1:sideN
        corners(e)=obj.bdryList(sd);
        sd=1+mod(sd+fth,bl);
    end
    obj.vlist=corners(:);
    fprintf('Corners not provided, so %d were chosen randomly\n',sideN);
end

% check length
sideN=length(corners);
if sideN<3
    fprintf('Setting polygon mode requires at least 3 corners\n');
    md=-1;
    obj.mode=-1;
    return;
end

% set all bdry aims to pi, equal corner target angles as default
for i=1:obj.bdryCount
    obj.vAims(obj.bdryList(i))=pi;
end
for i=1:sideN
    obj.vAims(corners(i))=pi*(1-2.0/sideN); 
end

if nargin>=4 % 'angs' were specified
    for i=1:sideN
        obj.vAims(corners(i))=angs(i);
    end
end

% determine indices in bdryList so we can get cclw order
bdryIndx=zeros(1,sideN);
for i=1:sideN
    cnr=corners(i); % corner index
    for j=1:obj.bdryCount
        if obj.bdryList(j)==cnr
            bdryIndx(i)=j;
            break;
        end
    end
    if bdryIndx(i)==0;
        fprintf('Vert %d is not a bdry vertex\n',corners(i));
        md=-1;
        obj.mode=-1;
        return;
    end
end

% put 'cornangs' in counterclockwise order
sort(bdryIndx);
tmpcorners=corners;
corners=zeros(sideN,1);
for j=1:sideN
    corners(j)=obj.bdryList(bdryIndx(j));
end

% organize the bdryIndx numerically based on first being 'gamma'; 
%    reset corner aims correspondingly
upright=tmpcorners(1);
bdryIndx=sort(bdryIndx);
offset=1;
for i=2:sideN
    if bdryIndx(i)== upright
        offset=i;
    end
end
obj.corners=zeros(1,sideN); % actual index of corners
crnrIndices=zeros(1,sideN); % index of corners in bdryList
for i=0:sideN-1
    k=1+mod(offset-1+i,sideN);
    crnrIndices(i+1)=bdryIndx(k);
    obj.corners(i+1)=obj.bdryList(crnrIndices(i+1));
end

% set up 'corners' and 'sides' info
% 'corners' should have the local indices of corners in the
%   correct order starting with 'upright' (but they may wrap)
obj.sides=cell(sideN,1);
for i=1:sideN
    cornerindx=crnrIndices(i);
    j=1+mod(i,sideN); 
    nextcorner=crnrIndices(j);
    sideIndices=zeros(1,obj.bdryCount);
    sideIndices(1)=crnrIndices(i);
    tick=1;
    while sideIndices(tick)~= nextcorner
        k=mod(cornerindx+tick-1,obj.bdryCount)+1; % next bdry vert
        tick=tick+1;
        sideIndices(tick)=k;
        if tick>obj.bdryCount
            fprintf('error in getting sides\n');
            md=-1;
            obj.mode=-1;
            return;
        end
    end
   
    % set actual vertices
    side=zeros(1,tick);
    for j=1:tick
        side(j)=obj.bdryList(sideIndices(j));
    end
    % store
    obj.sides{i}=side;    
end
obj.mode=m;
md=m;
fprintf('Mode is "%s", corner vertices are:',obj.PACKMODES{obj.mode});
for s=1:length(obj.corners)
    fprintf(' %d',obj.corners(s));
end
fprintf('\n');
return;

end

