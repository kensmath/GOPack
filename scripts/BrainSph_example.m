fprintf('Sample script to circle pack a cerebellar surface:\n');
fprintf('Neuroscientists have used circle packing to map human cortical\n');
fprintf('and cerebellar surface meshes, obtained from fMRI scans, to the \n');
fprintf('sphere or to plane regions.\n');
fprintf('This spherical example is work of Collins, Hurdal, Stephenson and others.\n');
gop=GOPacker();
gop.readpack('brainSph_K.p');
gop.setMode(1);
gop.riffle(30);
gop.show();
gop.writepack('brainSph_P.p');

