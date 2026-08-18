# GOPack
Matlab package for circle packing

GOPack is a matlap package developed at the University of Tennessee
by Chuck Collins, Gerald Orick, and Ken Stephenson, 2017, and is
based on an algorithm invented by Gerald Orick in his PhD thesis.
The inputs are triangulations of topological discs or spheres, provided
by the user or created randomly with methods of the package. The outputs
are circle packings having the patterns of tangencies of the given
triangulations. GOPack is for packings involving very large numbers of 
circles and does not provide full functionality. Rather it specializes to
computing "maximal" packings of the sphere or the hyperbolic plane and also
euclidean packings of rectangles. For more functionality, see the Github
repository https://github.com/kensmath/CirclePack. The maximal and 
polygonal packing portions of the code were ported in 8/2026 to C++ by 
Claude and are available at https://github.com/kensmath/GOPack-cpp.
