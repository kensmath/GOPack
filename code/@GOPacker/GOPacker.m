classdef GOPacker < handle
    %GOPacker < handle  This is the repack engine, methods of Gerald Orick 
    %
    %   This class implements repack methods using sparse matrices 
    %   as initiated by Gerald Orick. 
    
    properties (Access = 'public')
        
       %% **** constant strings ****
       PACKMODES={'max_pack','polygonal','frozen_bdry','orth','fixed_corners'};
       HES={'hyp','eucl','sph'};

       %% fields, many parallel to PackData in java
       fileName     % original input packing file name
       hes          % geometry: 0 eucl, -1 hyp, +1 sph
       alpha        % vertex for normalization, usually at origin
       beta         % (obe: not used)
       gamma        % vertex for normalization, usually on imaginary axis
       nodeCount    % total count of vertices
       edgeCount    % number of edges
       faceCount    % number of faces
       vNum         % vNum(v)+1 is the petal count for v (int or bdry)
       flowers      % cells with vNum(v)+1 petal vertices.
       bdryFlags    % usual meaning: bdry 1 (open); interior 0 (closed)
       vAims        % target angle sums for computation (depending on mode)   
       vlist        % utility list of vertices (e.g., for specifying corners).  
     
       %% **** combinatoric needs ****
       % Keeping track of vertices is complicated due to need for 
       %   connectivity, possible orphans, faux bdry in spherical 
       %   case, mutable designation of adjustable vertices, etc.
       %   'intVerts' lists vertices in interior connected component
       %   containing 'alpha', 'bdryList' is closed oriented list of
       %   surrounding nghbs, and 'orphanVerts' are the remaining 
       %   vertices. Note that for a sphere, 'bdryList' is faux 
       %   bdry, 3 vertices of a face: 'intCount' = 'nodeCount'-3, 
       %   'bdryCount'=3, and 'bdryList' has length 4 (but 'bdryFlags'
       %   are all still 0).
       
       intVerts     % interior component containing 'alpha'
       bdryList     % cclw closed list of vertices around 'intVerts'
       orphanVerts  % vertices without interior neighbors
       intCount     % count of intVerts
       bdryCount    % count of bdry verts
       orphanCount  % count of orphan vertices (not int, not bdry)      
       
       %   Regarding computations: 'layoutVerts' identify
       %   some non-empty subset of interior vertices whose centers
       %   and radii are to be adjusted in 'riffle' calls, defaulting
       %   to 'intVerts'. Closed listing of nghbs surrounding is 
       %   'rimVerts', defaulting to 'bdryList' (except 'rimVerts' is
       %   not necessarily in order). Must call 'indxMatrices' to
       %   initialize matrices: 'layoutVerts' and 'rimVerts' are
       %   reindexed and 'v2indx', 'indx2v' are for translation.

       layoutVerts  % mutable list of vertices subject to center changes
       rimVerts     % closed list of nghbs of 'layoutVerts' (not necessarily ordered)
       v2indx       % index conversion: true index to our internal matrix index; 
                    % only non-zero for 'layoutVerts', 'rimVerts'
       indx2v       % reverse index conversion; note, initial part of indx2v 
                    % translates to 'layoutVerts', 'rimVerts' follow.

       % Orphans can be eliminated entirely with 'pruneComplex', but
       %   the user may not want this. If not pruned, we avoid using
       %   them in computations, but they may cause layout problems. 
       %   Hence, for each orphan we identify an edge in 'bdryList'
       %   which gives a default center. 

       orphanEdges  % edge (w1_j,w2_j): plot j_th orphan at tangency
                    % point of these two bdry circles.
       
       %% **** various radii/centers ********
       % We keep three versions: 
       %   'original' for reference purposes (e.g., if we at some point 
       %      want to revert to them). 
       %   'radii' and 'centers': current best info based on initialization
       %      reaped results after computations; used when saving results.
       %   'localradii' and 'localcenters': working values during riffles;
       %      typically copy these to 'radii/centers' after riffling 
       %      cycles are done. See 'reapResults'.
       
       % original centers/radii (may be empty): 
       origRadii
       origCenters
       
       % best known values; e.g., local values set to these initially.
       %    after cycles of processing, store new values here.
       radii        
       centers      

       % current working radii/centers during processing
       localradii  
       localcenters

 
       % data and matrix structures needed during processing
 
       transMatrix % transition sparse matrix, among interiors
       tranI       % list (tranI,tranJ) of entries for transMat
       tranJ       %
       tranJindx   % index of tranJ in flower of tranI.
       tranIJcount % size of these lists
        
       rhsMatrix   % right hand side 
       rhsI        % list (rhsI,rhsJ) of entries for rhsMatrix
       rhsJ        %
       rhsJindx    % index of rhsJ in flower of rhsI.
       rhsIJcount  % size of these lists
       rhs         % rhs= rhsMatrix*zb'
       
       inRadii     % incircle radii for computing edge conductance
       conduct     % interior vertex conductances

       corners     % indices of bdry verts at corners in polygon case
       sides       % sides in polygon case: each entry is vector with
                   %   local indices of vertices ccw along that side,
                   %   including both first and last.

       % User or default specified mode
       mode =1     % mode: 
                   %   1: max pack (in disc if hes<=0, sphere if hes>0)
                   %   2: polygon packing, corners provided
                   
       % monitoring progress, error
       angsumMonitor  % array of worst angle sum errors during repack cycles; 
       l2Monitor   % array of l2-norms of angle sum errors.
       visErrMonitor   % array of max relative visual errors for 'layoutVerts'.
       ticMonitor  % array of elapsed time in 'layoutCenters' call.
       
    end
    
    methods 

        % clean our this GOpacker
        cleanse(obj)
                
        % combinatorics stuff
        nodecount = complex_count(obj)
        cutCount = pruneComplex(obj)
        
        % initialize sparse matrices, vectors
        indxMatrices(obj,varlist)
        
        % position boundary horocycles
        setHoroCenters(obj)

        % continue riffle using 'localradii' 'localcenters'.
        cycles = continueRiffle(obj,passNum) % for efficienty

        % riffle and reap results: cycles, visual error, elapsed seconds
        [cycles,visMon,etime] = riffle(obj,passNum) % for efficiency
        
        % lay out the bdry, depending on mode
        layoutBdry(obj)
        
        % for rectangular bdry centers
        setRectCenters(obj)
                
        % for rectangular bdry centers
        setPolyCenters(obj)

        % specifying what mode we want
        md=setMode(obj,m,pverts,angles)
	  
        % lay out the centers of interiors
        layoutCenters(obj)
        
        % set effective radii using centers
        setEffective(obj)
        
        % put radii/cents into the packing itself
        reapResults(obj)
        
        % get aspect (if appropriate)
        aspect = getAspect(obj)
        
        % data for sup and l2 norm of errors in interior angle sums
        diffs = angsumErrors(obj,rad);
        
        % summarize overall status
        packStatus(obj);
        
        % data for relative visual error (edgelength error/radius).
        visualErr=visualErrors(obj);
        
        % update sector tangents and conductance data
        updateVdata(obj)
        
        % read in triangulation
        vertcount=readpack(obj,fname)
        facecount=parse_triangles(obj,tList,cents)
        
        % for spherical normalization in 'writepack'
        T = loadTangency(obj,centers,radii)
        
        % save/write results; 
        vc=writepack(obj,fname,euclFlag) % save final packing, traditional form
        vc=writeEucl(obj,fname) % save working eucl version, traditional form
        
        % find deep vertex
        alpha=FarVert(obj,seeds) 
        
        % plot results
        h=show(obj,varargin)
        
        function A=getTrans(obj)
            A=full(obj.transMatrix);
        end
        
        function getRHSmatrix(obj)
            full(obj.rhsMatrix)
        end
        
    end
    
end

