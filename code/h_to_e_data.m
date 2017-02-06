function [ez,er] = h_to_e_data(hz,hr)
%[ez,er] = h_to_e_data(hz,hr) Convert hyp circle to euclidean data
%   Taken from CirclePack java code.
%   Recall that hyp radius hr is negative for horicycles and 
%   -hr is its eucl radius.

if hr<0 % horocycle
    er=-hr;
    ez=hz*(1-er);
    return;
end

ahc=abs(hz);
s_rad=exp(-hr);
n1=(1+s_rad)^2;
n2=n1-ahc*ahc*(1-s_rad)^2;
er=(1.0-s_rad^2)*(1.0-ahc^2)/n2;
b=4.0*s_rad/n2;
ez=hz*b;
end
