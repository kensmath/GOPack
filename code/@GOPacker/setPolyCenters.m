function setPolyCenters(obj)
%setPolyCenters(GOPacker obj) Put local centers on normalized n-gon.
%   For polygonal mode only, 'mode=2'. Must have 'obj.corners', 
%   'obj.sides', and 'obj.vAims' data.
%   Cases: 
%     n=3: triangle. deterimine sides based on corner aims.
%     n=4: rectangle handled separately if all right angles
%     n=even: pair up opposite sides when setting lengths;
%             cclw layout starts horizontally at 1+i.
%     n=odd: set all side lengths equal (though this may not
%            have a solution); cclw layout starts with corner at i.
%   normalize to put centroid of centers at origin, and scale
%     so first corner has x-coord 1 in n=even case, y-coord 1
%     in n=odd case.

%% check for data consistency
if obj.mode ~= 2
    fprintf('setPolyCenters: mode must be %s\n',obj.PACKMODES{2});
    return;
end

num_sides=length(obj.corners);
if num_sides<3 || num_sides~=length(obj.sides) || isempty(obj.vAims)
    fprintf('setPolyCenters: must have corners, sides, and aims.\n');
end

%% check for rectangle first
if num_sides==4
    benderror=0.0; % difference from all right angles
    for j=1:4
        benderror=benderror+abs(obj.vAims(obj.corners(j))-pi/2);
    end
    if benderror<=.00001   % standard situation, right angles
        setRectCenters(obj);
        return;
    end
end % else, handled later by n=even routines

%% compute side lengths using 'localradii'
sidelengths=zeros(1,num_sides); % current sidelengths
full_length=0; % sum of current sidelengths
targetLength=ones(1,num_sides); % normalized layout length for sides
for i=1:num_sides
    side=obj.sides{i};
    n=length(side);
    
    % accumulate radius for circle at each end
    long=obj.localradii(side(1));
    long=long+obj.localradii(side(n));
    % and diameters for circles between
    for j=2:n-1
        long=long+2*obj.localradii(side(j));
    end
    sidelengths(i)=long;
    full_length=full_length+long;
end
halfn=floor(num_sides/2);

% Situations

%% triangle: solve triangle to set 'targetLength's
if num_sides==3
    opp1=obj.vAims(obj.corners(3));
    opp2=obj.vAims(obj.corners(1));
    if opp1<=0.0 || opp2<=0.0 || (opp1+opp2)>=pi
        fprintf('setPolyCenters: error in triangles angle aims\n');
        return;
    end
    opp3=pi-(opp1+opp2); % ensure angles sum to pi
    % law of sines gives desired proportions of side lengths
    targetLength(1)=1.0;
    targetLength(2)=sin(opp2)/sin(opp1);
    targetLength(3)=sin(opp3)/sin(opp1);
    lensum=targetLength(1)+targetLength(2)+targetLength(3);
    factor=lensum/full_length;
    obj.localradii=obj.localradii*factor;
    sidelengths=sidelengths*factor;
    
%% polygon, n even, pair opposites, target length 6 (roubhly 2pi)    
elseif halfn*2==num_sides  
    factor=6.0/full_length;
    obj.localradii=obj.localradii*factor;
    sidelengths=sidelengths*factor;
    for j=1:halfn
        targetLength(j)=(sidelengths(j)+sidelengths(halfn+j))/2.0;
        targetLength(halfn+j)=targetLength(j);
    end
    
%% polygon, n odd, sides target length 2*sin(pi/n) (regular n-gon in unit disc)    
else 
    spn=2*sin(pi/num_sides);
    factor=num_sides*spn/full_length;
    obj.localradii=obj.localradii*factor;
    sidelengths=sidelengths*factor;
    for j=1:num_sides
        targetLength(j)=spn;
    end
end

%% Normalization procedure: 
% 1. Lay out using 'targetLength's:
%      num_sides odd: first corner at z=i, bisected by imaginary axis, edge
%         down to left
%      num_sices even: first corner at 1+i, first edge horizontal to left
% 2. translate so average of corners is the origin.
% 3. num_sides odd: scale so first corner is at z=i.
%    num_sides even: scale so first corner has x-coord 1

% ------ Step 1:
%   set the direction arguments for successive sides.
edgeArg=ones(1,num_sides);
edgeArg(1)=pi;
if halfn*2~=num_sides  % odd?
    edgeArg(1)=pi+(pi-obj.vAims(obj.corners(1)))/2.0;
end
for j=2:num_sides
    edgeArg(j)=edgeArg(j-1)+pi-obj.vAims(obj.corners(j));
end
edgedir=ones(1,num_sides);
for j=1:num_sides
    edgedir(j)=exp(1i*edgeArg(j));
end

% Set first corner, then layout edges in turn; adjust sizes based on
%   'targetLength's
obj.localcenters(obj.corners(1))=1i; % at z=i
if halfn*2==num_sides  % even?
    obj.localcenters(obj.corners(1))=1+1i; % at z=1+i
end
for k=1:num_sides
    sidefactor= targetLength(k)/sidelengths(k);
    side=obj.sides{k};
    n=length(side);
    prev=obj.localradii(obj.corners(k));
    spot=obj.localcenters(obj.corners(k));
    obj.localcenters(side(1))=spot;
    for i=1:(n-1)
        next=obj.localradii(side(i+1));
        spot=spot+sidefactor*edgedir(k)*(prev+next);
        obj.localcenters(side(i+1))=spot;
        prev=next;
    end
end

% Step 2 -------
% put average of corners at the origin
centAvg=0.0;
for j=1:num_sides
    centAvg=centAvg+obj.localcenters(obj.corners(j));
end
centAvg=centAvg/num_sides;
for j=1:obj.nodeCount
    obj.localcenters(j)=obj.localcenters(j)-centAvg;
end

% Step 3 --------
% scale
if halfn*2==num_sides  % even?
    scalefactor=real(obj.localcenters(obj.corners(1)));
else
    scalefactor=imag(obj.localcenters(obj.corners(1)));
end
obj.localcenters=obj.localcenters./scalefactor;
obj.localradii=obj.localradii./scalefactor;

return;
end

