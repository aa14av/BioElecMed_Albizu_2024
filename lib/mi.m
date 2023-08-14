function [MI,NMI,Hxy]=mi(A,B,L)
% Created by Alejandro Albizu on 03/16/2022
% Last Updated on 03/17/2022 by AA
A=double(A);
B=double(B);

Mx = histcounts(A(:),L);
Px = nonzeros(Mx/sum(Mx));
My = histcounts(B(:),L);
Py = nonzeros(My/sum(My));
Mxy = histcounts2(A,B,L);
Pxy = nonzeros((Mxy/sum(Mxy(:))));

% Entropy
Hx = -dot(Px,log2(Px+1e-10));
Hy = -dot(Py,log2(Py+1e-10));
Hxy = -dot(Pxy,log2(Pxy+1e-10));

% Mutual Information
MI = Hx + Hy - Hxy;
NMI = max(MI/sqrt(Hx*Hy),0);
% -----------------------