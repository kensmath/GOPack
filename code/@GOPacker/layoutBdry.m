function layoutBdry(obj)
%layoutBdry(GOPacker obj) Layout the boundary centers depending on 'mode'
%   Depending on the 'mode', this calls other routines to lays out 
%   the boundary circles and record 'localcenters'. This may be around 
%   the interior of the unit circle or around a rectangle. In each case, 
%   there may be a corresponding scaling adjustment to all 'localradii'.

%% polygonal packing mode
if obj.mode==2
    setPolyCenters(obj);
    return;
end

%% default to max packing, 'mode'=1
setHoroCenters(obj);
return;

end

