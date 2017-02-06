fprintf('Sample script for a geometrically random spherical circle packing.\n');
gop=randomSphere(25000);
gop.riffle(15);
gop.show();
gop.writepack('rand25000_P.p');
