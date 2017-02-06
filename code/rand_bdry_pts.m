function [bdryX,bdryY] = rand_bdry_pts(graphX,graphY,M)
%[bdryX,bdryY] = rand_bdry_pts(graphX,graphY,M) Create M random pts along graph.
%   Converted from java. 'graph' is a closed list of complex numbers defining 
%   a polygonal path. We want M uniformly randomly distributed points on that path.
%   The points are returned in order, but note that the list is not closed.
%   TODO: actually, M should be the mean of a distribution, but I don't
%   know what that distribution is.

%% check consistency, close up, get length
graphCount=length(graphX);
if graphCount<3 || M<3 || graphCount~=length(graphY)
    fprintf('Poor data in "rand_bdry_pts"\n');
    bdryX=[];
    bdryY=[];
    return;
end

% close up if necessary
if abs(graphX(1)-graphX(end))>.001 && abs(graphY(1)-graphY(end))>.001
    graphX(end+1)=graphX(1);
    graphY(end+1)=graphY(1);
end

% mark off by polygon length
graphCount=length(graphX);
length_marks=zeros(1,graphCount);
for i=2:graphCount
    length_marks(i)=length_marks(i-1)+sqrt((graphX(i)-graphX(i-1))^2+(graphY(i)-graphY(i-1))^2);
end

%% find M random ordered param spots in [0,length]
arc_spots=sort(rand(1,M)*length_marks(end));

% convert by interpolation to Complex points on graph
spot=1;
last_length = length_marks(spot);
next_length = length_marks(spot+1);
setlength=next_length-last_length;
bdryX=zeros(M,1);
bdryY=zeros(M,1);
for i=1:M
       while arc_spots(i)<last_length
           spot=spot+1;
           last_length = length_marks(spot);   
           next_length = length_marks(spot+1);
           setlength=next_length-last_length;
       end
       while arc_spots(i)>next_length
           spot=spot+1;
           last_length = length_marks(spot);   
           next_length = length_marks(spot+1);
           setlength=next_length-last_length;
       end
       
       ratio=(arc_spots(i)-last_length)/setlength;
       bdryX(i)=graphX(spot)+ratio*(graphX(spot+1)-graphX(spot));
       bdryY(i)=graphY(spot)+ratio*(graphY(spot+1)-graphY(spot));
end

end

