fprintf('Sample script for packing a raw triangulation.\n');
gop=GOPacker();
gop.readpack('rawTri');
gop.riffle();
gop.writepack('rawTriPacking.p');


