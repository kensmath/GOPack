function reapResults(obj)
%reapResults(GOpacker obj) put 'local' centers/radii into 'centers/radii'
%   Note: Radii and centers are euclidean and are converted to another
%   geometry only when the packing is saved.

obj.centers=obj.localcenters;
obj.radii=obj.localradii;

end

