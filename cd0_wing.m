%drag_wing.m
function cd0w_transonic = cd0_wing()

    [rho,a,temp,press,v,ZorH]=stdatmo(37000,0,'US',true);
    M=0.77;
    u=M*a;
    chord=262/7.75;
    tc=0.1;
    thickness=tc*chord;
    cfw = cf_flatplate(reynolds(u,chord,v));
    sref=19500;
    swet=2*sref;
    R=1.1;

    cd0w_subsonic = cfw*(1+L()*(tc)+100*(tc)^4)*R*swet/sref;
    
    %figure 13.10 using AR*(t/c)^(1/3)=3.6
    param = sqrt(abs(M^2-1)/(tc^(1/3)));
    cdw_c=2.75*tc^(5/3);
    
    CDW = cdw_c / cos(25*pi/180)^2.5;
    
    cd0w_transonic = cfw*(1+L()*(tc))*R*swet/sref + CDW;

end

function thickness_parameter = L()
    thickness_parameter = 1.2;
end