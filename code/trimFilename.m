function trimmed = trimFilename(fname)
%trimmed = trimFilename(fname) isolate filename.
%   trim off any leading directories and the last '.*' 
%   on error, return original fname

slashspot=1;
dotspot=0;
trimmed=fname;
lgth=length(fname);
if lgth==1
    return;
end
for j=2:lgth
    if fname(j)=='.'
        dotspot=j-1;
    elseif fname(j)=='/' || fname(j)=='\'
        slashspot=j+1;
    end
end

% no dot?
if dotspot==0
    dotspot=lgth;
end

% ended with slash
if slashspot>lgth 
    return
end

% out of order? take all after the slash
if dotspot-slashspot<1
    dotspot=lgth;
end

trimmed=fname(slashspot:dotspot);
end

