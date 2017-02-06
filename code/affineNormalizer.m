function [A,B] = affineNormalizer(T)
%[A,B]=affineNormalizer(T) Given pts 'T' in plane, find affine a*z+b
%   Real A complex B define affine map M: z --> A*z+B so that the
%   centroid of the points of M(T) when projected to the sphere is at
%   the origin in 3-space. Start with M=identity.
%   There are two nested loops. The inner one finds m: z --> a*z+b, then
%   replaces T by m(T) and replace M by composition m(M).

%% start with the identity transformation and the starting 'normsq'
M=[1.0,0.0,0.0]; % for building composition of successive 'p0's.
bestsq = Centroid(T,M);
N_TOLER=0.001; % how close do we want to be to the origin in 3-space?
CYCLES=20;  % number of both inner and outer while loops.

%% outer while loop
outercount=0;
while bestsq>N_TOLER && outercount<CYCLES
    delt=2.0;
    m=[1.0,0.0,0.0]; % inner loop transformation
    count = 0;
    
%% inner while loop    
    while bestsq>N_TOLER && count<CYCLES
        gotOne=0; % indication: which of 6 ways is best improvement
        for j=1:3
    		holdp_m=m(j);
    		m(j)=m(j)+delt;
    		newnorm=Centroid(T,m);
            m(j)=holdp_m; % reset to continue trying
    		if newnorm<bestsq 
                bestsq=newnorm;
    			gotOne=j;
            else % try opposite direction
        		m(j)=m(j)-delt;
        		newnorm=Centroid(T,m);
                m(j)=holdp_m; % reset
        		if newnorm<bestsq 
        			bestsq=newnorm;
        			gotOne=-j;
                end
            end
        end % end of for loop
	    
        % if moving in 6 directions didn't improve, then cut delt
        if gotOne==0
    		delt = delt/2;
    	% else success: which change was the best?
    	elseif gotOne==1
    		m(1)=m(1)+delt;
        elseif gotOne==2
            m(2)=m(2)+delt;
    	elseif gotOne==3
            m(3)=m(3)+delt;
        elseif gotOne==-1
            m(1)=m(1)-delt;
        elseif gotOne==-2
            m(2)=m(2)-delt;
    	elseif gotOne==-3
            m(3)=m(3)-delt;
        end % end of if/else
        count=count+1;
    end % end of while            

    % check if we're done
    if bestsq<N_TOLER
        % apply new 'm' to previously accumulated transform in 'M'
        M(1)=m(1)*M(1);
        M(2)=m(1)*M(2)+m(2);
        M(3)=m(1)*M(3)+m(3);
        A=M(1);
        B=M(2)+M(3)*1i;
        return;
    else
        % apply new transformatino to 'T'
        for v=1:length(T)
            T(v)=m(1)*T(v)+m(2)+m(3)*1i;
        end
        % accumulate in 'M'
        M(1)=m(1)*M(1);
        M(2)=m(1)*M(2)+m(2);
        M(3)=m(1)*M(3)+m(3);
    end
    
    outercount=outercount+1;
end

A=M(1);
B=M(2)+M(3)*1i;
return;
end

