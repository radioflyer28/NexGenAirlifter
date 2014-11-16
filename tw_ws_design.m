% function [] = tw_ws_design()
% function [] = tw_ws_design(e,AR,Cd0,Vcruise,Vclimb)
clear all; clc; close all;

fuse_wing_ratio = 0.114; %ratio of fuselage diameter to wingspan, 0.114 applies to most transport aircraft
sweep_qtr_chord = 25; %degrees
taper_ratio_opt = 0.45.*exp(1).^(-0.0375.*sweep_qtr_chord);
dihedral = 5; %degrees
AR=7.8;
Cd0=0.02;
cruise_alt = 37000; %ft
cruise_mach = 0.77;
sfc_cruise_s=0.5;
[rho,a,~,~,~,~]=stdatmo(cruise_alt,0,'US',true); %rho = slugs/cuft, a = ft/s
Vcruise=cruise_mach*a*3600/6076; %knots

e_cruise=oswald(fuse_wing_ratio,AR,taper_ratio_opt,sweep_qtr_chord,dihedral,cruise_mach,Cd0);
% e=0.52; %optional override

LD=LDcruise(Cd0,AR,e_cruise);
% LD=20; %optional override

CLmax=3.5;
CLto=3.5;
CLldg=CLmax;
Vstall=120;  %Same as C-5
Vtakeoff=1.1*Vstall;
Vclimb1=1.2*Vstall; %climb speed immediately after takeoff
Vclimb2=200; %used in time to climb calculation
Vtd=1.1*Vstall; %landing touchdown speed
Vref=Vstall*1.2; %approach speed for MIL spec, normally 1.3*Vso for civilian
K=1/(pi*e_cruise*AR);

rhoSL=0.002377;
% [rho,a,temp,press,kvisc,ZorH]=stdatmo(H_in,Toffset,Units,GeomFlag);
num=100;
WS=linspace(20,200,num);

num=500;
[WSt,TWt]=meshgrid(linspace(0,200,num),linspace(0,0.6,num));

axes('Parent',figure,'FontWeight','demi','FontSize',11);
hold on

%% climb
%20min to climb with 205,000lbs
%SL to 37000ft in 20min is 1850ft/min average
Pdyn=0.5*rhoSL*(Vclimb2*6076/3600)^2;

Hceil = 45000; %absolute ceiling in feet
h1 = 0; %starting alt
h2 = 32000; %finishing alt
% climbTime = 20*60; %20minutes in seconds
% climbRate = Hceil*log((Hceil-h1)/(Hceil-h2))/climbTime;

[~,a,~,~,~,~]=stdatmo(h2/2,0,'US',true); %rho = slugs/cuft, a = ft/s
climb_mach = Vclimb2/a;
e_climb=oswald(fuse_wing_ratio,AR,taper_ratio_opt,sweep_qtr_chord,dihedral,climb_mach,Cd0);
K=1/(pi*e_climb*AR);
climbRate=Vclimb2.*(TWt-(Pdyn*Cd0./WSt+K/Pdyn.*WSt));
climbTime = Hceil*log((Hceil-h1)/(Hceil-h2))./climbRate/60;
% climbRate = 1850/60; %override ceiling determination...
contour(WSt,TWt,climbTime,[10,15,20],'ShowText','on','LineColor','c')
% TW=Pdyn*Cd0./WS+K/Pdyn.*WS+1/Vclimb*climbRate;
% plot(WS,TW,'r')

%% takeoff distance
% un-needed extra --> TW=-(104.5*WS)/(CLmax*sigma*348*sqrt(WS/(CLmax*sigma))-5*STO); %50ft obstacle clearance from book
[rho,~,~,~,~,~]=stdatmo(10000,50,'US',true); %@SL with 86degF = ISA+27degF

%more robust method but may contain errors in takeoff_dist function - needs
%checking

STO=takeoff_roll(TWt,WSt,rho,CLto,e_cruise,AR,0.025,Cd0); %this is takeoff ground run...
% contour(WSt,TWt,STO,[3e3,6e3,9e3],'ShowText','on','LineColor','k');


%% landing distance
[rho,~,~,~,~,~]=stdatmo(10000,50,'US',true); %@SL with 86degF = ISA+27degF 
sigma=rho/rhoSL;
Sa=1000;
% SLDG=9000;
% WSs=2/3*5/3*(SLDG-Sa)*sigma*CLmax/80;
SLDG = 2/3*5/3*80.*WSt./(sigma*CLldg)+Sa;
contour(WSt,TWt,SLDG,[3e3:2e3:9e3],'ShowText','on','LineColor','y');
% plot([WSs WSs],[0 1],'c');

%% span limit
b=262;
Wb=b^2/AR*WSt;
contour(WSt,TWt,Wb,[1e6,1.2e6,1.4e6],'ShowText','on','LineColor','g');

%% Thrust limit
T=105000*4;
Wt=T./TWt;
contour(WSt,TWt,Wt,[1e6,1.2e6,1.4e6],'ShowText','on','LineColor','m');

%% Range
% g=32.2; %ft/s^2
% sfc_cruise=0.6;
% Range = Vcruise/g/sfc_cruise*LDcruise(Cd0,AR,e)*log(WSt.*TWt);
% contour(WSt,TWt,Range,[4e3,6e3,8e3],'ShowText','on','LineColor','m')

%% takeoff simple
[rho,~,~,~,~,~]=stdatmo(10000,50,'US',true); %@SL with 86degF = ISA+27degF

%simple t/o dist calc using takeoff parameter looked up from graph...
sigma=rho/rhoSL;
TOP = 240; %from 4-engine balanced field takeoff for 8000ft from performance slides
TW=WS/(TOP*sigma*CLto);
hatchedline(WS,TW,'b');
TOP = 360; %over 50ft obstacle 8000ft takeoff distance from performance slides
TW=WS/(TOP*sigma*CLto);
hatchedline(WS,TW,'r');

%% stall
WSs=0.5*rhoSL*(Vstall*6076/3600)^2*CLmax;
hatchedline([WSs WSs],[0 1],'b');

%% straight and level @ FL450
% [rho,~,~,~,~,~]=stdatmo(45000,0,'US',true);
% Pdyn=0.5*rho*(Vcruise*6076/3600)^2;
% K=1/(pi*e*AR);
% TW=Pdyn*Cd0./WS+K/Pdyn.*WS;
% plot(WS,TW,'g')


%% 2 engine climb after takeoff
CLclimb=WS*1/(0.5*rhoSL*(Vclimb1*6076/3600)^2);
LDclimb = CLclimb./(Cd0+K.*CLclimb.^2);
TW = 2*(3/100+1./LDclimb); %3/100 is 3% climb gradient required
hatchedline(WS, TW,'g');

[rho,~,~,~,~,~]=stdatmo(5000,0,'US',true); %@SL with 86degF = ISA+27degF
CLclimb=WS*1/(0.5*rho*(Vclimb1*6076/3600)^2);
LDclimb = CLclimb./(Cd0+K.*CLclimb.^2);
TW = 2*(3/100+1./LDclimb); %3/100 is 3% climb gradient required
plot(WS, TW,'g');

[rho,~,~,~,~,~]=stdatmo(10000,0,'US',true); %@SL with 86degF = ISA+27degF
CLclimb=WS*1/(0.5*rho*(Vclimb1*6076/3600)^2);
LDclimb = CLclimb./(Cd0+K.*CLclimb.^2);
TW = 2*(3/100+1./LDclimb); %3/100 is 3% climb gradient required
plot(WS, TW,'g');

%%

xlabel('W/S (lb/sqft)','FontWeight','bold','FontSize',12);
ylabel('T/W','FontWeight','bold','FontSize',12);
axis([20 200 0.1 0.6])
legend('Minutes to climb to FL320 @ 200keas','Landing Distance @ 10kftMSL ISA+27degC','MTOW for 262ft span limit','MTOW for 4x GE-90 engines','8kft BFL @ 10kftMSL ISA+27degC','8kft T/O Dist over 50ft @ 10kftMSL ISA+27degC',strcat(strcat('V_s_o =',num2str(Vstall)),'keas'),'2 Engine climb after T/O')
% 'T/O GR @ 10kftMSL ISA+27degC'
