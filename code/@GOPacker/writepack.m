function vtct = writepack(obj,fname,euclFlag)
%vtct = writepack(GOPacker obj,fname,[euclFlag]) write, traditional format
%   if 'euclFlag' argument is present and positive, then
%   save the packing in its working euclidean form.
%   Return 'nodeCount'.

vtct=0;
fid = fopen(fname,'w');   % open the file for writing
if fid==-1
    fprintf('Failed open file %s for packing\n',fname);
    return;
end

% set eFlag, default 0
eFlag=0;
if nargin>2
    eFlag=euclFlag;
end

fprintf(fid,'NODECOUNT: %d\n',obj.nodeCount);
fprintf(fid,'GEOMETRY: ');
if nargin>2 && eFlag>0 % saving as euclidean
    fprintf(fid,'eucl\n');
elseif obj.hes<0
    fprintf(fid,'hyp\n');
elseif obj.hes>0
    fprintf(fid,'sph\n');
else
    fprintf(fid,'eucl\n');
end
if ~isempty(obj.alpha) && obj.alpha(1)>0
    fprintf(fid,'ALPHA/BETA/GAMMA: %d %d %d\n',obj.alpha,0,obj.gamma);
end
fprintf(fid,'FLOWERS:\n');
for k=1:obj.nodeCount
    fprintf(fid,'%d %d  ',k,obj.vNum(k));
    flower=obj.flowers{k};
    for j=1:obj.vNum(k)+1
        fprintf(fid,'%d ',flower(j));
    end
    fprintf(fid,'\n');
end
fprintf(fid,'RADII: \n');
rad2store=obj.radii;
cent2store=obj.centers;
if nargin==2 || eFlag==0 % convert as needed
    if obj.hes==1 % spherical case, with normalization.
        
        % current packing should be eucl; get vector 'T' of tangencies
        T=obj.loadTangency(obj.centers,obj.radii);

        [A,B] = affineNormalizer(T);
        
        % apply map z -> A*z+B to eucl circles, compute sph data
        Z=zeros(1,obj.nodeCount);
        R=zeros(1,obj.nodeCount);
        for v=1:obj.nodeCount
            [Z(v),R(v)]=e_to_s_data(A*obj.centers(v)+B,A*obj.radii(v));
        end
        
        % store for writing out; 'obj' data is not changed
        cent2store=Z;
        rad2store=R;
        
    elseif obj.hes==-1 %
        for v=1:obj.nodeCount
            [hz,hr]=e_to_h_data(obj.centers(v),obj.radii(v));
            cent2store(v)=hz;
            rad2store(v)=hr;
        end
    end
end
for v=1:obj.nodeCount
    fprintf(fid,'%16.10f\n',rad2store(v));
end
fprintf(fid,'CENTERS:\n');
for v=1:obj.nodeCount
    fprintf(fid,'%16.10f %16.10f\n',real(cent2store(v)),imag(cent2store(v)));
end

% VERT_LIST: e.g., this may contain corner vertices or layoutVerts
if ~isempty(obj.vlist)
    fprintf(fid,'VERT_LIST:\n');
    for k=1:length(obj.vlist)
        fprintf(fid,'%d\n',obj.vlist(k));
    end
end

% non-default aims
ndflag=0;
for v=1:obj.nodeCount
    flower=obj.flowers{v};
    if (flower(1)~=flower(length(flower)) && obj.vAims(v)>=0)
        if ndflag==0 % first hit?
            fprintf(fid,'ANGLE_AIMS:\n');
            ndflag=1;
        end
        fprintf(fid,'%d %13.6f\n',v,obj.vAims(v));
    elseif flower(1)==flower(length(flower)) && abs(obj.vAims(v)-2*pi)>.00001
        if ndflag==0 % first hit?
            fprintf(fid,'ANGLE_AIMS:\n');
            ndflag=1;
        end
        fprintf(fid,'%d %f\n',v,obj.vAims(v));
    end
end

% TODO: non-default inversive distances, not yet implemented
fprintf(fid,'\n\nEND\n');

fclose(fid);
vtct=obj.nodeCount;
gem=obj.HES{2}; % eucl
if obj.hes<0 && eFlag==0
    gem=obj.HES{1}; % hyp
elseif obj.hes>0 && eFlag==0
    gem=obj.HES{3}; % sph
end
fprintf('%s packing written to %s\n',gem,fname); 
end
