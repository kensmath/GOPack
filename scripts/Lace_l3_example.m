fprintf('Sample script to circle pack a level 3 "lace" subdivision tiling.\n');
gop=GOPacker();
gop.readpack('lace42000_K.p');
gop.setMode(2);
gop.riffle(50);
gop.show('object','face');
gop.writepack('lace_P.p');
fprintf('\nThanks to Cannon, Floyd, and Parry for this example!\n\n');
