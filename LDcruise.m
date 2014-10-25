function LD = LDcruise(Cd0,AR,e)
% a crude function that estimates cruise L/D (from our design book)
LD = 0.866 * 1./(4.*Cd0./(pi.*AR.*e)).^0.5;