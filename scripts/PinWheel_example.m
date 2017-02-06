fprintf('Sample script to circle pack a "pinwheel" subdivision rule.\n');
fprintf('This is a level 3 subdivision with 3081 vertices.\n');
fprintf('and is to be packed as a [1:2:sqrt(5)] triangle.\n');
gop=GOPacker();
gop.readpack('Pinwheel_K.p');
gop.setMode(2,[272,3056,892],[pi*.5, asin(1/sqrt(5)),asin(2/sqrt(5))]);
gop.riffle(50);
gop.show();
gop.writepack('Pinwheel_P.p');

