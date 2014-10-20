%not trustworthy
function STO = takeoff_roll(TW,WS,rho,CLto,e,AR,u,Cd0g)
    g=32.2; %ft/s^2
    Vstall=(2.*WS./(rho.*CLto)).^0.5;
    Vto=1.2*Vstall;
    % u=0.25;
    Kg=1/(pi*e*AR);
    Clg=u/2/Kg;
    % Cd0g=0.025;
    Cdg=Cd0g+Kg*Clg^2;
    A=g*(TW-u);
    B=g./WS.*(0.5*rho*(Cdg-u*Clg));
    STO=0.5./B.*log(A./(A-B.*(Vto).^2));