function cleanse(obj)
%cleanse(GOPacker obj) Empty GOpacker, ready for new data

obj.fileName='noname';
obj.alpha=0;
obj.gamma=0;
obj.hes=0;
obj.nodeCount = 0;
obj.intCount=0;
obj.bdryCount=0;
obj.orphanCount=0;
obj.bdryFlags=[];
obj.flowers={};
obj.vNum=[];
obj.vAims=[];
obj.vlist=[];
obj.edgeCount=0;
obj.faceCount=0;

obj.intVerts=[];
obj.bdryList=[];
obj.orphanVerts=[];
obj.layoutVerts=[];    

obj.origRadii=[];
obj.origCenters=[];
obj.localradii=[];
obj.localcenters=[];
obj.radii=[];
obj.centers=[];
obj.v2indx=[];
obj.indx2v=[];

obj.corners=[];
obj.sides={};
obj.mode=1;
obj.angsumMonitor=[];
obj.l2Monitor=[];
obj.visErrMonitor=[];
obj.ticMonitor=[];
end