%function [] = range_payload_plot()
clear all; clc; close all;

fuse_wing_ratio = 0.114; %ratio of fuselage diameter to wingspan, 0.114 applies to most transport aircraft
sweep_qtr_chord = 25; %degrees
taper_ratio_opt = 0.45.*exp(1).^(-0.0375.*sweep_qtr_chord);
dihedral = 5; %degrees
AR=7.8;
Cd0=0.02;
cruise_alt = 37000; %ft
cruise_mach = [0.6 0.7 0.8];
sfc_cruise=0.5;
[~,a,~,~,~,~]=stdatmo(cruise_alt,0,'US',true); %rho = slugs/cuft, a = ft/s
Vcruise=cruise_mach*a*3600/6076; %knots

e=oswald(fuse_wing_ratio,AR,taper_ratio_opt,sweep_qtr_chord,dihedral,cruise_mach,Cd0);
% e=0.52; %optional override

LD=LDcruise(Cd0,AR,e);

%%
s = warning('off', 'all'); %turn all warnings off
mtow_guess=0;
num=20;
min_mtow=0;
max_mtow=1.6e6;

[w_payload,range]=meshgrid(linspace(0,600000,num),linspace(1000,8000,num));
exitflag=-4;
for i=1:num
    i;
    for j=1:num
        j;
        for k=1:length(cruise_mach)
            wffuel(i,j,k)=wftransport(range(i,j),sfc_cruise,Vcruise(k),LD(k));
            [w_mtow(i,j,k),~,exitflag,~]=mtow_solve(wffuel(i,j,k),w_payload(i,j),min_mtow,max_mtow);
            %[w_mtow(i,j),fval,exitflag,output]
        end
    end
end
warning(s)

figure
hold on
%% EDIT
contour(range,w_payload,w_mtow(:,:,1),[0 1.3e6],'ShowText','off','LineColor','r')
contour(range,w_payload,w_mtow(:,:,2),[0 1.3e6],'ShowText','off','LineColor','b')
contour(range,w_payload,w_mtow(:,:,3),[0 1.3e6],'ShowText','off','LineColor','g')
%%
ylabel('Payload (lbs)')
xlabel('Range (nm)')
zlabel('Gross Weight (lb)')
legend('Mach 0.6','Mach 0.7','Mach 0.8')