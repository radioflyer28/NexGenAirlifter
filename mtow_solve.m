function [w_mtow fval exitflag output] = mtow_solve(wf_fuel,w_payload,min_mtow,max_mtow)

w_empty_avail = @(w_mtow_guess) w_mtow_guess*(1 - wf_fuel) - w_payload;
w_empty_reqd = @(w_mtow_guess) 0.911.*w_mtow_guess.^0.947;
error=@(w_mtow_guess) w_empty_avail(w_mtow_guess) - w_empty_reqd(w_mtow_guess);

options = optimset('TolX',eps);

mtow_increment=(max_mtow-min_mtow)/10;
% mtow_increment=(max_mtow-min_mtow)/100;
exitflag=-4;
mtow_guess=min_mtow;
while exitflag==-4 && mtow_guess < max_mtow
    mtow_guess=mtow_guess+mtow_increment;
    [w_mtow fval exitflag output] = fzero(error,mtow_guess,options);
end

% close all
% w_mtow_guess = w_payload*2:100000:w_mtow*1.5;
% figure
% plot(w_mtow_guess,w_empty_avail(w_mtow_guess),w_mtow_guess,w_empty_reqd(w_mtow_guess))
% title('Solving for MTOW & Empty Weight')
% ylabel('Empty Weight (lbs)')
% xlabel('MTOW (lbs)')
% legend('Empty Available','Empty Reqd')
