function wffuel = wftransport(range,sfc_cruise,Vcruise,LDcruise)

    wfto=0.97;
    wfclimb=0.985;
    wflanding=0.995;
    wfdescent=0.999;

    wfcruise=exp(1).^-(range.*sfc_cruise./(Vcruise.*LDcruise)); %for range
    wfdivert=exp(1).^-(Vcruise.*sfc_cruise./(Vcruise.*LDcruise)); %for 1 hour at cruise
    
    loiter = 0.5; %hrs for tooling around in pattern/approach
    wfloiter=exp(1).^-(loiter.*sfc_cruise./(Vcruise.*LDcruise)); %for endurance

    wfmission=wfto.*wfclimb.*wfcruise.*wfdescent.*wfloiter.*wfdivert.*wflanding;
    reserve = 0.05;
    trapped = 0.01;
    wffuel=(1+reserve+trapped)*(1-wfmission);