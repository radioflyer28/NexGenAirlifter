% NOT WORKING YET
function [M_eff,sweep] = Mcr_sweep(M_cruise,Mcr,sweep_qtrc)
% M_cr = critical mach of airfoil:
%   Input as actual critical mach of airfoil
%   Output as the lowest possible critical mach of airfoil
% sweep_qtrc = sweep of wing at quarter chord
%   Input as actual wing sweep
%   Output as lowest possible sweep needed to prevent airfoil from
%   exceeding critical mach at a given cruise speed

M_cr = M_cruise*cos(sweep_qtrc*pi/180);
sweep = acos(M_cr/M_cruise)*180/pi;