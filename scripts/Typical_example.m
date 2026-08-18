fprintf('Sample script for packing a raw triangulation.\n');
gop=GOPacker();
gop.readpack('sph_10000.p');
gop.riffle();
gop.writepack('rawTriPacking.p');


