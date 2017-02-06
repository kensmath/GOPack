function [ez,er] = s_to_e_data(sz,sr)
%[ez,er] = s_to_e_data(sz,sr) convert sph circle to euclidean circle.
%   sz has form (theta,phi). 
%   Note: er negative means we intend the outside of the circle; calling 
%   routine must interpret this.

S_TOLER=.0000000000001;
flipflag=1;
V=s_pt_to_vec(sz);
phi=imag(sz);

%% essentially hits infinity (south pole)?
if abs(phi+sr-pi)<S_TOLER
    sr = sr+2.0*S_TOLER; % increment sr slightly to enclose infinity
end

%% encloses infinity?
if (phi+sr)>=(pi+S_TOLER)
    sr=pi-sr;
    V=V*-1.0;
    sz=proj_vec_to_sph(V); % antipodal center
    flipflag=-1;
end

up=phi+sr;
down=phi-sr;

%% essentially centered at north pole?
if abs(phi)<S_TOLER 
    er=sin(up)/(1.0+cos(up));
    ez=0.0;
    if flipflag<0
        er=er*-1.0;
    end
    return;
end

%% essentially centered at south pole
if abs(phi-pi)<S_TOLER
    % radius must be small since the circle wasn't flipped, so give
    % it a huge negative radius.
    er=-100000;
    ez=0.0;
    return;
end

%% circle essentially passes through infinity; decrease 'up' slightly
if abs(up-pi)<.00001
    up=up-.00001;
end

%% regular circle
RR=sin(up)/(1.0+cos(up));
rr=sin(down)/(1.0+cos(down));
er=abs(RR-rr)/2.0;
if flipflag<0
    er = er*-1.0;
    m=(RR+rr)/2.0;
    ez=V(1)*m/sin(phi)+(V(2)*m/sin(phi))*1i;
    return;
end

end
