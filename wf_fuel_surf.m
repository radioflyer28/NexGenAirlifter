close all; clc; clear all;

[Cd0,sfc_cruise]=meshgrid(linspace(0.008,0.02,100),linspace(0.5,0.8,100));
%Cd0=0.02;
e=0.52;
AR=7.8; %AR/(Swet/Sref)

LDcruise= LDcruise(Cd0,AR,e);
Vcruise=442; %knots from .77mach @ 37000ft
range=6300; %6300nm converted to feet
endurance=0.5; %hr

wf_fuel=wftransport(range,sfc_cruise,Vcruise,LDcruise(Cd0,AR,e));
wf_fuel_c5=0.395833333+Cd0*0+sfc_cruise*0;
% wf_empty_c5=0.4524+Cd0*0+sfc_cruise*0;

surf(Cd0,sfc_cruise,wf_fuel,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
hold on
surf(Cd0,sfc_cruise,wf_fuel_c5,'EdgeColor','none','LineStyle','none','FaceLighting','phong')