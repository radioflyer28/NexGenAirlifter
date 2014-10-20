function [] = range_payload()
% function [] = range_payload(e,AR,Vcruise,sfc_cruise,Cd0)

e=0.52;
AR=7.8;
Vcruise=442; %knots from .77mach @ 37000ft
Cd0=0.015;
sfc_cruise_s=0.6;

LD=LDcruise(Cd0,AR,e);
% LD=20;

mtow_guess=0;
num=20;
min_mtow=0;
max_mtow=1.4e6;
[w_payload,range]=meshgrid(linspace(0,600000,num),linspace(1000,8000,num));
exitflag=-4;
for i=1:num
    i;
    for j=1:num
        j;
        wffuel(i,j)=wftransport(range(i,j),sfc_cruise_s,Vcruise,LD);
        [w_mtow(i,j) fval exitflag output]=mtow_solve(wffuel(i,j),w_payload(i,j),min_mtow,max_mtow);
    end
end

figure
contour(range,w_payload,w_mtow,[8e5:2e5:max_mtow],'ShowText','on')
% surf(w_payload,range,w_mtow,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
ylabel('Payload (lbs)')
xlabel('Range (nm)')
zlabel('Gross Weight (lb)')
legend('MTOW (lbs)')