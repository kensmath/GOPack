function cycles = continueRiffle(obj,passNum)
%cycles=continueRiffle(GOPacker obj,passnum) Continue repacking.
%   Repacking involves iteratively adjusting radii and centers. 
%   Continue riffle in current mode. The standing assumption is 
%   that the radii have been updated -- typically as "effective" radii.
%   Thus, we use them for layout, then set new effective radii
%   for the number of passes specified or until maximum 
%   visError < 0.01. Return number of cycles.

cutval=.01; % TODO: what to set here as default?
pass=0;

%% make sure there's a layout, but don't change radii

if passNum<=0
    layoutBdry(obj);
    layoutCenters(obj);
    visErr=obj.visualErrors();
    maxVis=max(visErr);
    obj.visErrMonitor(end+1)=maxVis;
    cycles=0;
    return;
end

%% iterate passNum times (at least once)
maxVis=2*cutval; % Latest worst visError: set to get at least one cycle
%fprintf('Working |');
%progstring = '/-\|';
while pass<passNum && maxVis>cutval 

    % do a new layout
    layoutBdry(obj);
    layoutCenters(obj); 
    
    % reset 'radii' to effective radii based on new centers
    setEffective(obj);    
      
 	% judge results, save error info
    visErr=obj.visualErrors();
    maxVis=max(visErr);
    obj.visErrMonitor(end+1)=maxVis;

    pass=pass+1;
    fprintf('.');
%    fprintf('\b%c',progstring(mod(pass,4)+1));

end

cycles=pass;
%fprintf('\b - Done! %d cycles, % visError \n',cycles,maxVis);

end