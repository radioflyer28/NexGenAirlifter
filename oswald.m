function e_final = oswald(dF_ov_b,AR,taper_ratio,sweep_qtr_chord,dihedral,M,C_D0)
% AR = aspect ratio
% taper_ratio is unitless
% sweep_qtr_chord is in DEGREES
% dihedral in DEGREES
% M = mach number
% C_D0 = zero lift drag coefficient

%% ideal taper ratio for a given sweep angle ONLY FOR UNSWEPT WING
taper_ratio_opt = 0.45.*exp(1).^(-0.0375.*sweep_qtr_chord);

%% Horner taper ratio effect on oswald efficiency corrected for wing sweep

%Horner taper ratio effect ONLY FOR UNSWEPT WING
f=@(taper_ratio) 0.0524.*taper_ratio.^4 - 0.15.*taper_ratio.^3 + 0.1659.*taper_ratio.^2 - 0.0706.*taper_ratio + 0.0119;

%Correction for Horner equation, f, to translate taper ratio effect of
%swept wing into taper ratio effect of unswept wing
delta_taper_ratio = -0.357 + 0.45.*exp(1).^(-0.0375.*sweep_qtr_chord);

e_theo = 1./(1+f(taper_ratio-delta_taper_ratio).*AR);

%% Dihedral correction

keG = (1./cos(dihedral.*pi./180)).^2;

%% Fuselage wing interference correction
% dF_ov_b = dF/b; %fuselage diameter divided by wingspan, typical value = 0.114 for subsonic jet transports 
keF = 1-2.*(dF_ov_b).^2;

%% Mach correction from statistical data of transport aircraft
M_comp = 0.3;

keM = 1;
if M > M_comp 
    a_e = -0.001521;
    b_e = 10.82;
    keM = a_e.*(M./M_comp-1).^b_e + 1;
end

%% Final oswald efficiency based on above correction factors
P = 0.38.*C_D0;
Q = 1./(e_theo.*keF);
e_final = keM./(Q+P.*pi.*AR);
e_final = e_final.*keG;