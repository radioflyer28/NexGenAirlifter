function CF = cf_flatplate(Re)
    if Re>5e5
        CF=0.455/(log10(Re)^2.58);
    elseif Re<=5e5
        CF=1.328/sqrt(Re);
    else
        %blank;
    end
end