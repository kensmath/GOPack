function setHoroCenters(obj)
%setHoroCenters(GOPacker obj) Position horocycles around unit circle
%   For max packing in the disc, we start by positioning
%   the bdry circles as horocycles around the inside of 
%   the unit circle. This involves scaling all 'localradii'.

%%   Note: if there are only 3 boundary vertices, fixed locaitons; return
if obj.bdryCount<=3
    s3=sqrt(3);
    brad=s3/(2+s3);
    for i=1:3
        obj.localradii(obj.bdryList(i))=brad;
        obj.vAims(obj.bdryList(i))=0.0; % aim to zero so radii not adjusted
    end
    % centers equally spaced
    obj.localcenters(obj.bdryList(1))=(1-brad)*1i;
    obj.localcenters(obj.bdryList(2))=(1-brad)*(-sqrt(3)/2-(1/2)*1i);
    obj.localcenters(obj.bdryList(3))=(1-brad)*(sqrt(3)/2-(1/2)*1i);
    return;
end

%% initial guess for R: (sum of bdry radii)/pi
R=0.0;
minrad=0.0;
r=zeros(1,obj.bdryCount+1);  % want closed list
for j=1:obj.bdryCount
    r(j)=obj.localradii(obj.bdryList(j));
    if r(j)>minrad
        minrad=r(j);
    end
    R = R+r(j);
end
r(obj.bdryCount+1)=r(1); % close up
R = R/pi;
if R<2.0*minrad
    R=3.0*minrad;
end

%% Newton iteration to find R
trys=0;
keepon=1;
while (keepon==1 && trys<100)
    trys=trys+1;
    fvalue=-2.0*pi;
    fprime=0.0;
    for j=1:obj.bdryCount
        Rrr=R-r(j)-r(j+1);
        RRrr=R*Rrr;
        ab=r(j)*r(j+1);
        fvalue = fvalue+acos((RRrr-ab)/(RRrr+ab));
        fprime = fprime-1.0*(R+Rrr)*sqrt(ab/RRrr)/(RRrr+ab);
    end
    		
    % is this working?
    newR=R-fvalue/fprime;
   	if (newR<R/2.0)
   		newR=R/2;
    end
   	if (newR>2.0*R)
   		newR=2.0*R;
    end
    		
    % cutoff (might be adjustable in future)
    if abs(newR-R)<.00001
    	keepon=0;
    end
	R=newR;
end % end of while

%% scale all radii by 1/R
obj.localradii=obj.localradii./R;
r=r./R;

%% set boundary centers, first being on y-axis.
r2=r(1);
obj.localcenters(obj.bdryList(1))=(1.0-r2)*1i;
arg=pi/2.0;
for k=2:obj.bdryCount
    r1=r2;
    r2=r(k);
    RRrr=1.0-r1-r2;
    ab=r1*r2;
	delta=acos((RRrr-ab)/(RRrr+ab));
	arg=arg+delta;
	d=1.0-r2;
	obj.localcenters(obj.bdryList(k))=d*cos(arg)+1i*d*sin(arg);
end

end

