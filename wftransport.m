function wffuel = wftransport(range,sfc_cruise,Vcruise,LDcruise)

    wfto=0.97;
    wfclimb=0.985;
    wflanding=0.995;
    wfdescent=0.999;

    wfcruise=exp(1).^-(range.*sfc_cruise./(Vcruise.*LDcruise)); %for range
    wfdivert=exp(1).^-(Vcruise.*sfc_cruise./(Vcruise.*LDcruise)); %for range

    wfmission=wfto.*wfclimb.*wfcruise.*wfdescent.*wfdivert.*wflanding;
    wffuel=1.00*(1-wfmission);