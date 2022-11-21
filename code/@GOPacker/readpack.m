function  vertexCount = readpack(obj,fname)
% vertexCount=readpack(GOpacker obj,fname) read packing or triangulation.
%    Read traditional packing of NODECOUNT or CHECKCOUNT type.
%    Normally, it is only the combinatorics which are needed, but
%    centers/Radii are converted to euclidean (if available and if possible).
%    For NODECOUNT or triangulation input, run through 'complex_count'
%    to find interior component, bdryList, orphans, etc.
%    We assume the complex is simply connected. For sphere, bdryList,
%    is faux bdry made from first face containing the vert having the 
%    max index. If not a traditional *.p packing file, this tries to read 
%    as OFF or other type of triangulation.

vertexCount=0;

%% open the (text) file for reading
fid = fopen(fname, 'r');
if (fid==-1)
    fprintf('Failed to read packing file %s\n',fname);
    return;
end

%% data is organized by key words --- first, find out the format

% Set flag to see what has been read
nodeCase=1; % this is NODECOUNT type file
geom=0; % default euclidean
newRadii=[]; % empty unless new radii are read
newCenters=[]; % empty unless new centers are read in

% grab the first string of characters and decide how to proceed.
beginStr=fscanf(fid,'%s',1);

% partial data: consistency?
if length(beginStr)>=11 && strcmp(beginStr(1:11),'CHECKCOUNT:') 
    nodeCase=0; 
    ckcount = fscanf(fid,'%d',1);
    if ckcount~=obj.nodeCount
        fprintf('Error: this is a CHECKCOUNT type file, count does not match\n');
        return;
    end

% a full packing
elseif length(beginStr)>=10 && strcmp(beginStr(1:10),'NODECOUNT:')
    % reinitialize data
    obj.cleanse();
    obj.nodeCount = fscanf(fid,'%d',1);
    vertexCount=obj.nodeCount;
    
    % find actual file name without extension
    obj.fileName=trimFilename(fname);
    
% Open file format OFF
elseif length(beginStr)>=10 && strcmp(beginStr(1:3),'OFF') 
    fprintf('TODO: readpack in OFF format; code not yet done.\n');
    return;
    
% Nothing else works, try to read as a triangulation    
else
    x1 = sscanf(beginStr,'%d');    % should get the first number(s)
    x2 = fscanf(fid,'%d');         % read the rest
    x = [x1;x2];                   % combine       
    fclose(fid);

    % check if multiple of 3 and reshape:
    n = length(x);
    if mod(n,3)==0
        tri = reshape(x,3,n/3)';
        fcount=obj.parse_triangles(tri);
        if fcount==0
            disp('failed to form a packing from the given triangles.'\n);
            return;
        end
        obj.indxMatrices();
        obj.mode=1;
        vertexCount=obj.nodeCount;
        return;
    else
        disp('failed final attempt, to read as triangulation (n-by-3).\n');
    end
    return;
end

%% now continue processing: CHECKCOUNT situation should have only
%   certain of the data possibilities.
done = 0;
while (done==0)
   % CHECK
   S = fscanf(fid,'%s',1);
   ls = length(S);
   if (ls<4)
       S = [S,'     ']; 
   end
   
   % these should only occur in NODECOUNT case
   if strcmp(S(1:4),'ALPH') % ALPHA/GAMMA (obe: ALPHA/BETA/GAMMA)
      x = fscanf(fid,'%d',3);
      obj.alpha = x(1);
      obj.gamma = x(2);
      if (size(x,1)==3)
          obj.gamma=x(3);
      end

   elseif strcmp(S(1:4),'GEOM') % GEOMETRY: default to eucl
      % note: in CHECKCOUNT case, 
      S = fscanf(fid,'%s',1);
      hyp = strfind(S,'hyp');
      if ~isempty(hyp)
          geom=-1;
      else 
        sph=strfind(S,'sph');
        if ~isempty(sph)>0
          geom=1;
        end
      end
      if nodeCase==1 % NODECOUNT case
          obj.hes=geom;
      end
      
   % ---------------- lots of processing here --------------------
   elseif (strcmp(S(1:4),'FLOW') && nodeCase==1) 
      if nodeCase~=1
           fprintf('Error: improper FLOWER data for CHECKCOUNT case\n');
           vertexCount=0;
           return;
      end

      % read the data first
      flwrs = cell(obj.nodeCount, 1);
      obj.bdryFlags=zeros(1,obj.nodeCount);
      for j=1:obj.nodeCount
      
          % get the next non-empty line
          line=fgetl(fid);
          while isempty(line) || length(line)==1
            line=fgetl(fid);
          end
          line_num = str2num(line); %#ok<ST2NM>
          sz_line_num = size(line_num, 2);
             
          % first entry is index (i.e. j), second is 'vNum', number of faces
          obj.vNum(j)=line_num(2);
          flower = line_num(3 : sz_line_num);
          if flower(1)~=flower(end) % bdry vertex?
              obj.bdryFlags(j)=1;
              obj.bdryCount=obj.bdryCount+1;
          end
          flwrs{j}=flower;
      end
      obj.flowers=flwrs;
      
      % various preliminary counts
      obj.intCount=obj.nodeCount-obj.bdryCount;
      totvNum=sum(obj.vNum);
      obj.faceCount=totvNum/3;
      obj.edgeCount=(totvNum+obj.bdryCount)/2;
      
      % make sure alpha is interior, default to first interior
      if obj.alpha==0 || obj.bdryFlags(obj.alpha)~=0
          for v=1:obj.nodeCount
            if obj.bdryFlags(v)==0
                obj.alpha=-v;  % set negative temporarily
                break;
            end
          end
      end
      
      % has 'alpha' been set?
      if obj.alpha==0
          fprintf('Error, no interior vertex was found, stop processing.\n');
          return;
      elseif obj.alpha<0 % was not specified, so reset to far from seeds
          if obj.bdryCount==0 % this is sphere
              obj.alpha=1;
          else
              seeds=zeros(1,obj.nodeCount);
              tick=1;
              for j=1:obj.nodeCount
                if obj.bdryFlags(j)==1 % bdry
                    seeds(tick)=j;
                    tick=tick+1;
                end
              end
              % find one far from seed
              seeds=seeds(1:tick-1); % trim 'seeds'
              % CHECK
              alpha=obj.FarVert(seeds);
              if alpha<0
                  fprintf('error in setting alpha\n');
                  obj.alpha=1;
              else
                  obj.alpha=alpha;
              end
          end
      end

   % ----------------- end of comb processing -----------
      
   % the rest could also occur in CHECKCOUNT cases      
   elseif (strcmp(S(1:4),'RADI')) % RADII:
      newRadii = fscanf(fid,'%f',obj.nodeCount);
      
   elseif (strcmp(S(1:4),'CENT')) % CENTERS:
      x = fscanf(fid,'%f',2*obj.nodeCount);
      if (length(x)==2*obj.nodeCount)
         newCenters=zeros(1,obj.nodeCount);
         c = reshape(x,2,obj.nodeCount);
         newCenters(1,:) = c(1,:) + sqrt(-1)*c(2,:); 
      end
   elseif (strcmp(S(1:4),'VERT'))  % VERT_LIST
      [x,~] = fscanf(fid,'%d',obj.nodeCount);
      obj.vlist = x;
   elseif (strcmp(S(1:3),'END'))
      done = 1;
   end
end
% finished with input
fclose(fid);

%% set some defaults, then store data
if nodeCase==1 % NODECOUNT case
    
    % set combinatorics
    obj.complex_count();

    % are there orphan vertices?
    if obj.orphanCount>0
        fprintf('Warning: orphan vertices were found (vertices w/o interior neighbors)\n');
    end
    
    % CHECK
    % initialize default centers/radii
    obj.centers=zeros(1,obj.nodeCount);
    obj.radii=ones(1,obj.nodeCount)*.5; % default to 1/2

    % store original data if given
    if ~isempty(newRadii)
        obj.origRadii=newRadii';
    end
    if ~isempty(newCenters)
        obj.origCenters=newCenters;
    end
end

% store eucl centers/radii when given
if geom==0 && ~isempty(newRadii)
   obj.radii=newRadii';
end
if geom==0 && ~isempty(newCenters)
    obj.centers=newCenters;
end

% convert hyp radii/centers to eucl, if necessary
if geom<0 && ~isempty(newRadii) && ~isempty(newCenters)
    for v=1:obj.nodeCount
        [ez,er]=h_to_e_data(newCenters(v),newRadii(v)); % ??? h_to_x_rad(newRadii(v)));
        obj.radii(v)=er;
        obj.centers(v)=ez;
    end
end

% set local data
obj.localcenters=obj.centers;
obj.localradii=obj.radii;

% aims
if isempty(obj.vAims) % set default
    obj.vAims = 2*pi*ones(1,obj.nodeCount);
    for k=1:obj.nodeCount
       if obj.bdryFlags(k)~=0
           obj.vAims(k)=-1.0;
       end
   end
end

obj.mode=1;
obj.indxMatrices();

%% report results to the user
gem='Euclidean';
if obj.hes<0 
    gem='Hyperbolic';
elseif obj.hes>0
    gem='Spherical';
end
fprintf('Packing %s (%s) is loaded, max pack mode\n',obj.fileName,gem); 

end

