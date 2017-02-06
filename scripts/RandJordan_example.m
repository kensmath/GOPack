fprintf('Sample script for a random triangulation of a Jordan domain G.\n');
fprintf('Given a simple closed polygonal curve (X,Y), we create a geometrically\n');
fprintf('random triangulation of the region G it bounds with\n');
fprintf(' "intN" interior and "bdryN" boundary vertices.\n');
fprintf('CAUTION: this process is not bullet-proof: an irregular G and/or small\n');
fprintf('vertex count can cause errors in the triangulation.\n');
fprintf('We first read in a saved path "Kurv" and get its coord vectors.\n');
Kurve
X=Kurv(:,1);
Y=Kurv(:,2);
figure(1);
plot(X,Y,'r');
hold;
gop=randomTri(1000,200,X,Y,0.0);
figure(1);
gop.show('object','face');
figure(1);
hold;
gop.riffle();
figure(2);
gop.show();
fprintf('\n The piecewise affine map from the carrier in the disc to the original\n');
fprintf('triangulation is known as a random discrete conformal map.\n');

