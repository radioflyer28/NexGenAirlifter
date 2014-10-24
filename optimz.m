% INCOMPLETE, this will later be some optimization code
function [X,P,S,TR,accel,GG] = akriz_ver()
    clear; clc; close all;
    Method = {'Weighted Sum','Global Criterion','Goal Attain','MiniMax'};
    for m=2
    % for m=1:length(Method)

        [X,P,S,TR,accel,GG] = calcs(m);

        fprintf('\n x1      x2    x3  x4   x5   f1      f2      %s\n', Method{m})
        if isempty(S)
            fprintf('\n___________________________________\n')
            fprintf('%6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',[X,P,accel',TR']')
            fprintf('\n___________________________________\n')
        else
            fprintf('\n___________________________________\n')
            fprintf('%6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f\n',[X,P,S,accel',TR']')
            fprintf('\n___________________________________\n')
        end

        %% Plotting Commands
        figure(1)
        plot(P(:,1),P(:,2),'b*')
        title([Method{m},' Objective Space'])
        % axis square
        xlabel('f_1 = Mass (lbs)')
        ylabel('f_2 = Control (deg/s^2)')
        % axis([0 2000 -6*10^6 0])

        %%
        if any(any(diff(P)<0))
            disp('Dominated point found')
        end
    end
end

function [X,P,S,TR,accel,GG]=calcs(method)

    f1 = @(x) Mass(x(1),x(2),x(3),x(4));
    %f2 = @(x) Control(x(3),x(4),x(5));
    f2 = @(x) ang_accel(x);

    xlb = [10; 1; 100; 36; 64];
    xub = [50; 10; 700; 120;128];
    x0 = mean([xlb,xub],2);

    % Utopia point and Reservation point
    MinMass = f1(xlb);
    MaxMass = f1(xub);
    MinControl = f2(xlb);
    MaxControl = f2(xub);

    % Setup weights for weighted sum objective function
    if method==2
    Weights = 0.0:0.01:1; % eps_1-constraint has uniform weighting
    else
    Weights = [(0.0:0.01:0.99), (0.99+0.01*((1-exp(-(0:10)/10))/(1-exp(-1))))];
    end

    % Pre-allocate pareto point solution vectors
    N = length(Weights);
    X = zeros(N,5);
    P = zeros(N,2);
    S = zeros(N,1);
    
    %Options for fmincon, fgoalattain, fminimax
    options = optimset('Display','off','GradObj','on','Algorithm','sqp','TolFun',1e-8);

    % Loop to find Pareto points for each weight combination
    for p=1:N
        alpha = Weights(p);
        switch method % Case of Pareto Method
            case 1 % Weighted Sum Method
            w8sum = @(x) (1-alpha)*f1(x)/MaxMass + alpha*(-f2(x)/MaxControl);
            % w8sum = @(x) (1-alpha)*f1(x)/MaxVol + alpha*MaxFrq/f2(x);
            [xp,S(p)] = fmincon(@(x)objcs(w8sum,x),x0,[],[],[],[],xlb,xub,@(x)boxcon(x),options);

            case 2 % Weighted Global Criterion (Compromise Solution)
            w8globcrit = @(x) (1-alpha)*(f1(x)-MinMass)/(MaxMass-MinMass) ...
            + alpha*(-f2(x)+MinControl)/(-MaxControl+MinControl);
            [xp,S(p)] = fmincon(@(x)objcs(w8globcrit,x),x0,[],[],[],[],xlb,xub,@(x)boxcon(x),options);

            case 3 % Goal Attainment
            goal = [MinMass, -MaxControl];
            weight = [alpha, (1-alpha)];
            F = @(x) [f1(x), -f2(x)];
            xp = fgoalattain(@(x)objcs(F,x),x0,goal,weight,[],[],[],[],xlb,xub,@(x)boxcon(x),options);

            case 4 % Mini-Max
            %F = @(x) [(1-alpha)*f1(x)/MaxMass, alpha*MaxControl/f2(x);]; %WRONG
            F = @(x) (1-alpha)*f1(x)/MaxMass+ alpha*(-f2(x)/MaxControl); %CORRECT
            %F = @(x) [f1(x), f2(x)]; %BEST
            xp = fminimax(@(x)objcs(F,x),x0,[],[],[],[],xlb,xub,@(x)boxcon(x),options);
        end

        X(p,:) = xp; % Store efficient point
        P(p,:) = [f1(xp),f2(xp)]; % Store Pareto point
        accel(p) = ang_accel(xp);
        [GG(p,:),~] = boxcon(xp); %store constraint violation values

        %Determine if any constraints are violated
        [nn,mm]=size(GG);
        TRR=1;
        for j=1:1:mm
            if GG(p,j)<=0
                TR(p)=1;
            else
                TR(p)=0;
                TRR=0;
            end
        end
    end %for 1:N % Loop to find Pareto points for each weight combination

    % Nulls S if a efficient point is found for any of the weights looped
    % through
    if all(abs(S)<1e-6), S=[]; end

    % Returns value of objective function and its gradient at point x
    function [obj,grad] = objcs(fcn,x)
        obj = fcn(x);
        if nargout>1
           grad=zeros(length(x),length(obj));
             for n=1:length(x)
                    xc = x;
                    xc(n) = xc(n) + 1i*eps;
                    fc = fcn(xc);
                    grad(n,:) = imag(fc)/eps;
            end
        end
    end
end