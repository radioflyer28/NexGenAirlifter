function CDF = cdf()

sref=19500;
sw=2*sref;
lw=262/7.75;

st=sw/3;
lt=lw/3;

sf=sw;
lf=200;

sn=sf*0.2;
ln=lf*0.2;


%[rho,a,temp,press,kvisc,ZorH]
[rho,a,temp,press,v,ZorH]=stdatmo(37000,0,'US',true);

u=0.77*a;

% sref=sn+sf+sw+st;

CDF = cd0_wing + cd0_body

cf_flatplate(reynolds(u,lw,v))*sw/sref;

end


