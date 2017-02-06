function show(obj,varargin)
%show(GOPacker obj,varargin) plot objects from current packing.
%   Examples: 'show()' or 'show('object','circle') for circles;
%     'show('object','face'); for the triangulation.
%     'show('label','circle'); to label the circles.
%     'show('object','both'); to show both circles and faces
%   resolution: 360/resolution points used in drawing circles (default: 1)
%   

%% set up input parser
p = inputParser;

% set default and valid values for parameter pairs
defaultResolution = 10;
checkResolution = @(x) (isnumeric(x) && (x>0));
defaultObject = 'circle';
validObjects = {'circle','triangle','face','both'};
checkObject = @(x) any(validatestring(x,validObjects));
gobjectMap = containers.Map(validObjects,{1,2,2,3});
defaultLabel = 'none';
validLabels = {'circle', 'none'};
checkLabel = @(x) any(validatestring(x,validLabels));
labelMap = containers.Map(validLabels,{1,0});
defaultFill = 'none';
validFills = {validObjects{:}, 'none'};
checkFill = @(x) any(validatestring(x,validFills));
fillMap = containers.Map(validFills,{1,2,2,3,0});

% set up requirements 
addParameter(p,'resolution',defaultResolution,checkResolution)
addParameter(p,'object',defaultObject,checkObject)
addParameter(p,'label',defaultLabel,checkLabel)
addParameter(p,'fill',defaultFill,checkFill)
p.KeepUnmatched = true;

%% parse and process inputs
parse(p,varargin{:})

resolution = p.Results.resolution;
gobject = gobjectMap(p.Results.object);
label = labelMap(p.Results.label);
filltype = fillMap(p.Results.fill);
plotCommands = p.Unmatched;  % only works with pairs, e.g. 'LineWidth', 3

%% calculations and plotting

% preserve hold status
myhold = ishold;

% circle plotting
if (gobject==1 || gobject==3)
% set parameters for circle (note use of resolution)
    theta = (0:resolution:360)*pi/180;

    % get current radii and centers
    radii = obj.radii';
    x = real(obj.centers)';
    y = imag(obj.centers)';

    % calculate x & y values, individual circles are separated
    % by NaNs

    x_circle = bsxfun(@times,radii,cos(theta));
    x_circle = bsxfun(@plus,x_circle,x);
    x_circle = cat(2,x_circle,nan(size(x_circle,1),1));
    x_circle =  x_circle';
    x_circle = x_circle(:);

    y_circle = bsxfun(@times,radii,sin(theta));
    y_circle = bsxfun(@plus,y_circle,y);
    y_circle = cat(2,y_circle,nan(size(y_circle,1),1));
    y_circle =  y_circle';
    y_circle = y_circle(:);

    % plot, maintain hold status
    plot(x_circle,y_circle,plotCommands)
    hold on
end

% triangle/face plotting
if (gobject==2 || gobject==3)
    % get (x,y) coordinates of centers
    x = real(obj.centers)';
    y = imag(obj.centers)';
    
    % compute number of unique edges
    edgecount = obj.edgeCount;
    
    x_tri = nan(edgecount,3);
    y_tri = nan(edgecount,3);
    
    ct = 1;
    for i = 1:obj.nodeCount
        vlist = obj.flowers{i};
        if vlist(1)==vlist(end)
            vlist(end) = [];
        end
        for j = vlist
            if (j>i)
                x_tri(ct,1:2) = [x(i),x(j)];
                y_tri(ct,1:2) = [y(i),y(j)];
                ct = ct + 1;
            end
        end
    end
    
    x_tri = x_tri';
    x_tri = x_tri(:);
    y_tri = y_tri';
    y_tri = y_tri(:);
    
    % plot
    hold on
    
    plot(x_tri,y_tri,plotCommands)
   


end

if label
    for i = 1:obj.nodeCount
        text(x(i),y(i),int2str(i))
    end
end

axis equal
axis off

if myhold
    hold on
else
    hold off
end


end
    
