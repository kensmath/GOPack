fprintf('Sample script for a geometrically random circle packing of the unit disc:\n');
gop=randomDisc(5000);
gop.riffle(50);
gop.show();
gop.writepack('randDisc5000_P.p');
