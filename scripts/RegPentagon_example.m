fprintf('Sample script to circle pack level 6 of the regular pentagonal\n');
gop=GOPacker();
gop.readpack('pentl6_K.p');
gop.setMode(2);
gop.riffle(30);
gop.show();
gop.writepack('pentl6_P.p');
fprintf('This tiling was created by Phil Bowers and Ken Stephenson.\n');