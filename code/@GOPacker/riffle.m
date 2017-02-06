function  [cycles,visMon,etime] = riffle(obj,psNum)
%[cycles,visMon,etime] = riffle(GOPacker obj,psNum) 
%   combines 'continueRiffle', 'reapResults', returns cycle count, 
%   visual error, and elapsed seconds.

%% check 'mode'
if obj.mode<=0
    fprintf('mode = %d suggests there has been an error.',obj.mode);
    cycles=-1;
    return;
end

%% riffle and reap results
passNum=20; % default
if nargin>1
    passNum=psNum;
end
riftic=tic;
cycles=obj.continueRiffle(passNum);
elapsed=toc(riftic);
obj.reapResults();

%% report
if isempty(obj.visErrMonitor);
    fprintf('Riffle: %d passes\n',cycles);
else
    visMon=obj.visErrMonitor(end);
    etime=floor(elapsed);
    fprintf('\nRiffle: %d passes, visErr %f, elapsed %d secs\n',cycles,visMon,etime);
end

end

