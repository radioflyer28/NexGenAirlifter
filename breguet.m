function varargout = breguet(type, task, E_R_or_frac, LD, SFC, V, eta_p)
% BREGUET uses the Breguet range equation to calculate the weight fraction
% for a cruise or loiter mission segment -OR- to find the range and
% endurance for a given segment weight fraction. 
% 
%   segFrac = BREGUET('Jet' , 'Cruise', R      , LD, TSFC, V)
%   segFrac = BREGUET('Jet' , 'Loiter', E      , LD, TSFC)
%   [R, E]  = BREGUET('Jet' , 'Range' , segFrac, LD, TSFC, V)
% 
%   segFrac = BREGUET('Prop', 'Cruise', R      , LD, PSFC, [], eta_p)
%   segFrac = BREGUET('Prop', 'Loiter', E      , LD, PSFC, V , eta_p)
%   [R, E]  = BREGUET('Prop', 'Range' , segFrac, LD, PSFC, V , eta_p)
% 
%   Variables (also see table below):
%     type    - First argument, a string indicating type of powerplant:
%                'Prop'   - Power-producing (e.g. piston or turboprop).
%                'Jet'    - Thrust-producing (e.g. turbofan).
%     task    - Second argument, a string indicating computation task:
%                'Cruise' - Calculate weight fraction, W_end/W_start, for a
%                           cruising mission segment based on given range.
%                'Loiter' - Calculate weight fraction for a loitering
%                           mission segment based on given endurance.
%                'Range'  - Calculate segment range and/or endurance for a
%                           given weight fraction.
%     segFrac - Weight fraction for the mission segment, W_end/W_start.
%     R       - Segment range, i.e. distance traveled in length units.
%     E       - Endurange, i.e. time elapsed for segment in time units
%     LD      - L/D, the lift to drag ratio AT WHICH THE SEGMENT IS FLOWN.
%               Optimal is shown in table below for a parabolic drag polar.
%               Remember that L/D and V are NOT independent (see table).
%     TSFC    - Thrust specific fuel consumption in 1/time units.
%     PSFC    - Power specific fuel consumption in 1/length units.
%     V       - True speed at which the segment is flown. Required for
%               'JetRange' only for finding R and for 'PropRange' only for
%               finding E.
%     eta_p   - Efficiency with which shaft power is converted by propulsor
%               (i.e. propeller) into thrust power
% 
%   Certain parameters must combine according to the table below such that
%   their units cancel in order to create a dimensionless quantity. SFC
%   must be in different units depending on the powerplant type (PSFC vs
%   TSFC). Using inconsistent units is an extremely common mistake that is
%   difficult to detect. Using gravitational acceleration is often
%   necessary to achieve unit consistency.
%            type  |   task   | Optimal LD | Dimensionless quantity
%          --------|----------|------------|------------------------
%           'Jet'  | 'Cruise' | .866*LDmax |        R*TSFC/V
%           'Jet'  | 'Loiter' |    LDmax   |         E*TSFC
%           'Prop' | 'Cruise' |    LDmax   |         R*PSFC
%           'Prop' | 'Loiter' | .866*LDmax |        E*PSFC*V
%
%   Note: The Breguet range equation assumes that L/D, V, and SFC remain
%   constant over the entire flight sement.
% 
%   BREGUET is fully vectorized and also can accept dimensioned variables
%   using the DimensionedVariable class (see UNITS function). This is
%   extemely helpful in enforcing unit consistency and eliminating common
%   errors.
% 
%   Example 1a: Find endurance of a loitering jet with segment fuel
%   fraction of 30% (segment weight fraction 70%), max L/D of 18, and TSFC
%   of 0.5 lb/hr/lb. Result is in hours because TSFC is in units of 1/hour.
%       [~, Emax] = BREGUET('Jet', 'Range', 0.7, 18, 0.5)
% 
%   Example 1b: Find the range and segment time for a cruise segment flown
%   at M = 0.87 @ 37000 ft (500 knots true). Result is in nmi and hr
%   because of inputs in units of 1/hr and kts.
%       [R, t]    = BREGUET('Jet', 'Range', 0.7, 0.866*18, 0.5, 500)
% 
%   Example 2: Use DimensionedVariable class to find 600 nmi cruise segment
%   weight fraction for piston-prop general aviation aircraft with max L/D
%   of 10, PSFC of 0.4 lb/hr/hp, and propeller efficiency of 80%.
%       u = units;
%       breguet('Prop','Cruise',600*u.nmi,10,u.g0*.4*u.lbm/u.hr/u.hp,[],.8)
% 
%   See also FUELFRACTIONSIZING, MISSIONFUELBURN, 
%     UNITS - http://www.mathworks.com/matlabcentral/fileexchange/38977.
% 
%   segFrac = BREGUET('Jet' , 'Cruise', R      , LD, TSFC, V)
%   segFrac = BREGUET('Jet' , 'Loiter', E      , LD, TSFC)
%   [R, E]  = BREGUET('Jet' , 'Range' , segFrac, LD, TSFC, V)
% 
%   segFrac = BREGUET('Prop', 'Cruise', R      , LD, PSFC, [], eta_p)
%   segFrac = BREGUET('Prop', 'Loiter', E      , LD, PSFC, V , eta_p)
%   [R, E]  = BREGUET('Prop', 'Range' , segFrac, LD, PSFC, V , eta_p)

%   Copyright 2012-2013 Sky Sartorius
%   www.mathworks.com/matlabcentral/fileexchange/authors/101715

if nargin < 6
    V = NaN;
end

switch lower([type(1:3) ' ' task(1)])
    case 'jet l'  %E_R_or_frac is endurance in s; SFC is TSFC in 1/s
        varargout{1} = exp(-E_R_or_frac.*SFC./LD);
        
    case 'jet c'  %E_R_or_frac is range in m; SFC is TSFC in 1/s
        varargout{1} = exp(-E_R_or_frac.*SFC./(V.*LD));
        
    case 'pro l' %with V; E_R_or_frac is endurance; SFC is PSFC in 1/m
        varargout{1} = exp(-E_R_or_frac.*SFC.*V./(LD.*eta_p));
        
    case 'pro c' %E_R_or_frac is range in m; SFC is PSFC in 1/m
        varargout{1} = exp(-E_R_or_frac.*SFC./(LD.*eta_p));
        
    case 'jet r'  % SFC is TSFC in 1/s
        varargout{2} = -LD.*log(E_R_or_frac)./SFC;
        varargout{1} = varargout{2}.*V;
      
    case 'pro r' % SFC is PSFC in 1/m
        varargout{1} = -LD.*eta_p.*log(E_R_or_frac)./SFC;
        varargout{2} = varargout{1}./V;
        
    otherwise
        error('unknown mission segment type and/or task string')
end
 
% See FUELFRACTIONSIZING for additional revision history.
% 2013-04-07/21 reformatted help block/table
