% show effects on oswald eff
clear all; clc;


num=100;
% [M,Cd0]=meshgrid(linspace(0.5,0.82,num),linspace(0,0.03,num));
[AR,Cd0]=meshgrid(linspace(3,15,num),linspace(0,0.03,num));
sweep=25;
taper = 0.45.*exp(1).^(-0.0375.*sweep);

% for i=1:num
%     i;
%     for j=1:num
%         j;
%         e(i,j)=oswald(0.114,7.8,.176,25,3,M,Cd0);
%     end
% end

e=oswald(0.114,AR,taper,sweep,5,0.7,Cd0);
LD=LDcruise(Cd0,AR,e);

figure
% contour(AR,sweep,LD,[0:1:25],'ShowText','on')
contour(AR,Cd0,LD,[0:2:30],'ShowText','on')
% surf(w_payload,range,w_mtow,'EdgeColor','none','LineStyle','none','FaceLighting','phong')
ylabel('Cd0')
xlabel('AR')
zlabel('LD')
legend('LD')