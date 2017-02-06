function [hz,hr] = e_to_h_data(ez,er)
%[hz,hr] = e_to_h_data(ez,er) Converts eucl to hyp data
%   Modified from CirclePack java version.
%   If center is close to 1 (or larger), treat circle as horocycle,
%   with convention that hr is negative of euclidean radius
%   and center hz is on unit circle.
%   Otherwise, work via s-radius and x-radius.
%   Recall: if hr is hyperbolic radius, then s=exp(-hr) is its
%   s-radius and x=1-s*s is its x-radius.

aec=abs(ez);
dist=aec+er;
if dist>(1.000000000001) % not in closed disc; push in to horocycle
   	aec = aec/dist;
   	er = er/dist;
   	dist=1.0;
end        

% is this a horocycle?
if (.99999999)<dist 
    
    % radius shouldn't be >=1
    if abs(er)>.99999999 
        er=er/2.0;
    end
    hr=-er;
    
    % center
    if (aec<.0001) % essentially zero?
        hz=0.0;
    else
        hz=ez*(1/aec); % in direction of ez
    end
    return;
end
    
c2=aec*aec;
r2=er*er;
if aec<.0000000000001 % circle at origin 
    hz =0.0;
else 
    t=1+c2-r2;
    b=sqrt((t+2*aec)/(t-2*aec));
    ahc=(b-1)/(b+1);
    hz=ez*ahc/aec;
end

t=1+r2-c2;
s=sqrt((t-2*er)/(t+2*er)); % this is s-radius
x=1.0-s*s;  % this is x-radius.
if x>.0001 
    hr=(-0.5)*log(1.0-x);
else
	hr=x*(1.0+x*(0.5+x/3))/2; % second order approximation
end