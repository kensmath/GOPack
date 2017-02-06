fprintf('Sample script for a geometrically random rectangular circle packing.\n');
gop=randomRectangle(15000,2.0);
gop.riffle(15);
gop.show();
gop.writepack('randRect15000_P.p');
