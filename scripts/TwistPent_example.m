fprintf('Sample script to circle pack a twisted pentagonal pattern; this comes\n');
gop=GOPacker();
gop.readpack('twist41000_K.p');
gop.setMode(2);
gop.riffle(50);
gop.show();
gop.writepack('twist41000_P.p');
fprintf('\nThanks to Cannon, Floyd, and Parry for this example!\n\n');
