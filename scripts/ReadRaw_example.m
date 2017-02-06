fprintf('Sample script to read combinatorics as a raw triangulation.\n');
fprintf('By raw, we mean the data is simply a list of triples of vertices\n');
fprintf('forming the triangulation faces. See the data in "rawTri".\n');
gop=GOPacker();
gop.readpack('rawTri');
gop.setMode(1);
gop.riffle(30);
gop.show();
gop.writepack('rawTri_P.p');

