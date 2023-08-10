function [MI,NMI,Hxy]=mi(A,B,varargin)
% Created by Alejandro Albizu on 03/16/2022
% Last Updated on 03/17/2022 by AA
L=100;
A=double(A);
B=double(B);

Mx = histcounts(A(:),L);
Px = nonzeros(Mx/sum(Mx));
My = histcounts(B(:),L);
Py = nonzeros(My/sum(My));
Mxy = histcounts2(A,B,L);
Pxy = nonzeros((Mxy/sum(Mxy(:))));

% Entropy
Hx = -dot(Px,log2(Px));
Hy = -dot(Py,log2(Py));
Hxy = -dot(Pxy,log2(Pxy));

% Mutual Information
MI = Hx + Hy - Hxy;
NMI = max(MI/sqrt(Hx*Hy),0);
% -----------------------
end

function n=hist2(A,B,L)
    ma=min(A(:));
    MA=max(A(:));
    mb=min(B(:));
    MB=max(B(:));
    
    A=round((A-ma)*(L-1)/(MA-ma+eps));
    B=round((B-mb)*(L-1)/(MB-mb+eps));
    n=zeros(L);
    x=0:L-1;
    for i=0:L-1
        n(i+1,:) = histc(B(A==i),x,1);
    end
end