function setRectCenters(obj)
%setRectCenters(GOPacker obj) Put local centers around a rectangle.
%   In case we are packing a rectangle, we should already
%   have the 'obj.sides' set up. We lay the bdry centers around
%   a rectangle centered at the origin and with horizontal
%   sides at y=-1 and y=+1. Adjust 'localradii' also.

%% Get side lengths
sidelengths=zeros(1,4);
for i=1:4
    side=obj.sides{i};
    n=length(side);
    
    % accumulate radius for each end
    long=obj.localradii(side(1));
    long=long+obj.localradii(side(n));
    % and diameters for those between
    for j=2:n-1
        long=long+2*obj.localradii(side(j));
    end
    sidelengths(i)=long;
end

%% average lengths, top/bottom, left/right
width=(sidelengths(1)+sidelengths(3))/2.0;
height=(sidelengths(2)+sidelengths(4))/2.0;

%% Use aspect of rectangle to scale localradii and 'sidelengths'
aspect=height/width;
factor=2*(aspect+1)/(width+height);
for v=1:obj.nodeCount
    obj.localradii(v)=obj.localradii(v)*factor;
end
for i=1:4
    sidelengths(i)=sidelengths(i)*factor;
end

%% ????? rectangle: lowerleft (-aspect,-1), upper right (aspect,1).
% On each edge we spread the vertices proportially to cover that edge.

% corners and increments are
crnpt=zeros(1,4);
edgedir=zeros(1,4);
slength=zeros(1,4);
crnpt(1)=1.0+aspect*1i;
crnpt(2)=-1.0+aspect*1i;
crnpt(3)=-1.0-aspect*1i;
crnpt(4)=1.0-aspect*1i;
edgedir(1)=-1;
edgedir(2)=-1i;
edgedir(3)=1.0;
edgedir(4)=1i;
slength(1)=2.0;
slength(2)=2.0*aspect;
slength(3)=2.0;
slength(4)=2.0*aspect;

% do the edges in turn
for k=1:4
    sidefactor= slength(k)/sidelengths(k);
    side=obj.sides{k};
    n=length(side);
    prev=obj.localradii(obj.corners(k));
    spot=crnpt(k);
    obj.localcenters(side(1))=spot;
    for i=1:(n-2)
        next=obj.localradii(side(i+1));
        spot=spot+sidefactor*edgedir(k)*(prev+next);
        obj.localcenters(side(i+1))=spot;
        prev=next;
    end
end

end

