function [sz,sr] = e_to_s_data(ez,er)
%[sz,sr] = e_to_s_data(ez,er) Convert eucl to spherical data
%   taken from CirclePack java code
%   Note that complex center sz has (theta,phi) polar form

ns=real(ez)^2+imag(ez)^2;
rr=abs(er);
S_TOLER=.00000000001;

% er is too small; project center, er unchanged.
if rr<S_TOLER 
    sr=er;
    denom=ns+1.0;
    tmpd=1.0/denom;
    P3=[(2*real(ez))*tmpd,(2*imag(ez))*tmpd,(2.0-denom)*tmpd];
    if(P3(3)>(1.0-S_TOLER)) 
        sz=0.0;
        return;
    end
    
    if (P3(3)<(S_TOLER-1.0)) 
        sz=0.0+pi*1i;
    else
        sz=atan2(P3(2),P3(1))+acos(P3(3))*1i;
    end
    return;
end

norm=sqrt(ns);
if norm<S_TOLER  % close to origin 
    mn=-rr;
    x=mn;
    y=0.0;
    a=rr;
    b=0.0;
else
    denom=1/norm;
    mn=norm-rr;
    % a point on the circle closest to origin */
    x=mn*real(ez)*denom;
    y=mn*imag(ez)*denom;
    % a point on the circle furthest from the origin */
    a=(norm+rr)*real(ez)*denom;
    b=(norm+rr)*imag(ez)*denom;
end

% now we project these two points onto the sphere
d1=(x*x + y*y +1.0);
tmpd=1.0/d1;
P1=[2.0*x*tmpd,2.0*y*tmpd,(2.0-d1)*tmpd];
d2=a*a + b*b +1.0;
tmpd=1.0/d2;
P2=[2.0*a*tmpd,2.0*b*tmpd,(2.0-d2)*tmpd];

% We may need some point along the geo between these, for they
%    themselves might be too far apart to get the correct angle
%    between them or to get the right tangent direction from one 
%    towards the other. 
%
% We may use the origin, the euclidean center, or a point
%    on the unit circle, depending on which is well placed
%    vis-a-vis the endpoints. 

brk=100.0*S_TOLER;
midflag=0;
if mn<=-brk % origin is well enclosed; use it. 
    midflag=1;
    P3(2)=0;
    P3(1)=P3(2);
    P3(3)=1.0;
elseif mn<=brk && norm>2 % use pt on unit circle in direction of center
    midflag=1;
    P3(1)=real(ez)/norm;
    P3(2)=imag(ez)/norm;
    P3(3)=0.0;
end

if midflag==1 % use pt along geo; radius in two parts
    d1=P1(1)*P3(1)+P1(2)*P3(2)+P1(3)*P3(3);
    if d1>=1.0
        d1=1.0-S_TOLER;
    end
    d2=P2(1)*P3(1)+P2(2)*P3(2)+P2(3)*P3(3);
    if d2>=1.0
        d2=1.0-S_TOLER;
    end
    ang13=acos(d1);
    ang23=acos(d2);
    rad=(ang13+ang23)/2.0;
    if ang13<ang23 
        E=[P1(1),P1(2),P1(3)];
    else
        E=[P2(1),P2(2),P2(3)];
    end

    % Use E and P3 to find center; tangent direction from E toward P3. 

    v=atan2(E(2),E(1))+acos(E(3))*1i;
    w=atan2(P3(2),P3(1))+acos(P3(3))*1i;
    T=sph_tangent(v,w);
else
    d1=P1(1)*P2(1)+P1(2)*P2(2)+P1(3)*P2(3);
    if d1>=1.0
        d1=1.0-S_TOLER;
    end
    rad=acos(d1)/2.0;
    E=[P1(1),P1(2),P1(3)];
    v=atan2(E(2),E(1))+acos(E(3))*1i;
    w=atan2(P2(2),P2(1))+acos(P2(3))*1i;
    T=sph_tangent(v,w);
end    

% C will be the rectangular coordinates of the center 
C=[E(1)*cos(rad)+T(1)*sin(rad),E(2)*cos(rad)+T(2)*sin(rad),E(3)*cos(rad)+T(3)*sin(rad)];
sr=rad;

if rad<0 % actually, wanted outside of circle 
    sr=pi-rad;
    C=[-1.0,-1.0,-1.0];
end
if C(3)>1-S_TOLER
    sz=0.0;
elseif C(3)<(S_TOLER-1.0)
    sz=pi*1i;
else
    sz=atan2(C(2),C(1))+acos(C(3))*1i;
end
return;  
end