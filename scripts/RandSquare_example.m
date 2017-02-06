fprintf('Sample script for a geometrically random square circle packing.\n');
gop=randomSquare(8000);
gop.riffle(15);
gop.show();
gop.writepack('randSqr8000_P.p');

