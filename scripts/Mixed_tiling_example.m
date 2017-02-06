fprintf('Sample script to circle pack a "mixed" subdivision rule due to\n');
gop=GOPacker();
gop.readpack('mixed10000_K.p');
gop.setMode(2);
gop.riffle(30);
gop.show();
gop.writepack('mixed10000_P.p');
fprintf('\nThanks to Cannon, Floyd, and Parry for this example!\n\n');
