%drag_body.m
function Cd0B = cd0_body()

sref=19500;
L=200;
D=32;
DB=0.5*D; %diameter of blunt aft section, aka not tapered
SB=pi*D^2/4;
SS=L*pi*D;

[rho,a,temp,press,v,ZorH]=stdatmo(37000,0,'US',true);
M=0.77;
u=M*a;

CDF = cf_flatplate(reynolds(u,L,v));
CDp = CDF * ( 60/(L/D)^3 + 0.0025*(L/D) ) * (SS/SB);
Cpb = -0.015; %from #D curve in fig 2.27 for Mach 0.8
CDb = -Cpb*(DB/D)^2;
CDW = 0.05; %guess'timated from fig 13.15

Cd0B= CDF + CDp + CDb + CDW;

end