function LD = LDcruise(Cd0,AR,e)

LD = 0.943 * 1./(4.*Cd0./(pi.*AR.*e)).^0.5;