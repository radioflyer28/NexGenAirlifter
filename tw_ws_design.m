function [] = tw_ws_design()
% function [] = tw_ws_design(e,AR,Cd0,Vcruise,Vclimb)

e=0.8;
AR=6;
Cd0=0.015;
CLmax=5;
Vcruise=471;
Vclimb=200;
K=1/(pi*e*AR);

rhoSL=0.002377;
% [rho,a,temp,press,kvisc,ZorH]=stdatmo(H_in,Toffset,Units,GeomFlag);
num=100;
WS=linspace(0,200,num);

num=50;
[WSt,TWt]=meshgrid(linspace(0,200,num),linspace(0,0.6,num));

figure
hold on
axis([40 200 0.2 0.8]);



%% climb
%20min to climb with 205,000lbs
%SL to 37000ft in 20min is 1850ft/min average
Vclimb = Vclimb*6076/3600; %200kts in fps...
Pdyn=0.5*rhoSL*Vclimb^2;

Hceil = 47000; %absolute ceiling in feet
h1 = 0; %starting alt
h2 = 34000; %finishing alt
% climbTime = 20*60; %20minutes in seconds
% climbRate = Hceil*log((Hceil-h1)/(Hceil-h2))/climbTime;

climbRate=Vclimb.*(TWt-(Pdyn*Cd0./WSt+K/Pdyn.*WSt));
climbTime = Hceil*log((Hceil-h1)/(Hceil-h2))./climbRate/60;
% climbRate = 1850/60; %override ceiling determination...
contour(WSt,TWt,climbTime,[10,15,20],'ShowText','on','LineColor','c')
% TW=Pdyn*Cd0./WS+K/Pdyn.*WS+1/Vclimb*climbRate;
% plot(WS,TW,'r')

%% takeoff distance
% un-needed extra --> TW=-(104.5*WS)/(CLmax*sigma*348*sqrt(WS/(CLmax*sigma))-5*STO); %50ft obstacle clearance from book
[rho,~,~,~,~,~]=stdatmo(10000,50,'US',true); %@SL with 86degF = ISA+27degF
CLto=3.5;

%more robust method but may contain errors in takeoff_dist function - needs
%checking

STO=takeoff_roll(TWt,WSt,rho,CLto,e,AR,0.025,Cd0); %this is takeoff ground run...
contour(WSt,TWt,STO,[3e3,6e3,9e3],'ShowText','on','LineColor','k');


%% landing distance
[rho,~,~,~,~,~]=stdatmo(10000,50,'US',true); %@SL with 86degF = ISA+27degF 
sigma=rho/rhoSL;
CLldg=CLmax;
Sa=1000;
% SLDG=9000;
% WSs=2/3*5/3*(SLDG-Sa)*sigma*CLmax/80;
SLDG = 2/3*5/3*80.*WSt./(sigma*CLldg)+Sa;
contour(WSt,TWt,SLDG,[3e3:2e3:9e3],'ShowText','on','LineColor','g');
% plot([WSs WSs],[0 1],'c');

%% span limit
b=262;
Wb=b^2/AR*WSt;
contour(WSt,TWt,Wb,[1e6,1.2e6,1.4e6],'ShowText','on','LineColor','y');

%% Thrust limit
T=105000*4;
Wt=T./TWt;
contour(WSt,TWt,Wt,[1e6,1.2e6,1.4e6],'ShowText','on','LineColor','m');

%% Range
% g=32.2; %ft/s^2
% sfc_cruise=0.6;
% LDcruise= @(Cd0,AR,e) 0.943 * 1./(4.*Cd0./(pi.*AR.*e)).^0.5;
% Range = Vcruise/g/sfc_cruise*LDcruise(Cd0,AR,e)*log(WSt.*TWt);
% contour(WSt,TWt,Range,[4e3,6e3,8e3],'ShowText','on','LineColor','m')

%% takeoff simple
[rho,~,~,~,~,~]=stdatmo(10000,50,'US',true); %@SL with 86degF = ISA+27degF
CLto=3.5;

%simple t/o dist calc using takeoff parameter looked up from graph...
sigma=rho/rhoSL;
TOP = 230; %from 4-engine balanced field takeoff for 8000ft from performance slides
TW=WS/(TOP*sigma*CLto);
hatchedline(WS,TW,'b');
TOP = 360; %over 50ft obstacle 8000ft takeoff distance from performance slides
TW=WS/(TOP*sigma*CLto);
hatchedline(WS,TW,'r');

%% stall
Vref=130;
Vstall=Vref/1.3*6076/3600;
WSs=0.5*rhoSL*(Vstall)^2*CLmax;
hatchedline([WSs WSs],[0 1],'b');

%% straight and level @ FL450
Vcruise=Vcruise*6076/3600; %442kts = .77mach @ 37000ft
[rho,~,~,~,~,~]=stdatmo(45000,0,'US',true);
Pdyn=0.5*rho*Vcruise^2;
K=1/(pi*e*AR);
TW=Pdyn*Cd0./WS+K/Pdyn.*WS;
plot(WS,TW,'g')
xlabel('W/S (lb/sqft)')
ylabel('T/W')

%%
axis([40 200 0.1 0.6])
legend('Minutes to climb to FL340 @ 200keas','T/O GR @ 10kftMSL ISA+50degF','Landing Distance @ 10kftMSL ISA+50degF','MTOW for 262ft span limit','MTOW for 4x GE-90 engines','8kft BFL @ 10kftMSL ISA+50degF','8kft T/O Dist over 50ft @ 10kftMSL ISA+50degF','Level FL450','Stall @ 100keas')

