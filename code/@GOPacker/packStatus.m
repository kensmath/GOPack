function packStatus(obj)
%llong=packStatus(GOPacker obj) Print info on packing status.
%   Return count of 'layoutVerts'

llong=length(obj.layoutVerts);
fprintf('Status for %s packing "%s":\n',obj.HES{obj.hes+2},obj.fileName);
fprintf('  Mode is "%s"',obj.PACKMODES{obj.mode});
if obj.mode==2 
    fprintf(', with corner vertices ');
    for j=1:length(obj.corners)
        fprintf('%d ',obj.corners(j));
    end
end
fprintf('.\n');
fprintf('  Packing has %d vertices, of which %d are subject to packing adjustments.\n',obj.nodeCount,llong);
mx=max(obj.visualErrors());
fprintf('  Maximum visual error is %f. For details see "visualErrors" array.\n',mx);

end

