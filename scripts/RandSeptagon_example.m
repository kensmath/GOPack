fprintf('Sample script for a geometrically random circle packing.\n');
fprintf('Aim is a regular septagon, with randomly chosen corner vertices.\n');
gop=randomDisc(5000);
gop.setMode(2,[7]);
gop.riffle(50);
gop.show();
gop.writepack('randSept_P.p');
