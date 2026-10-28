function [corner_points] = brayton_cycle_pts(p_amb,T_amb,T_max,p_ratio,turb_output_power)
%'brayton_cycle_pts' outputs the corner points for states 1 through 5 (for
%jet engine application) of the brayton cycle in air.

%ambient pressure is in kPa
%ambient temperature is in K
%turb_output_power is extra power extracted by the turbine (if not extra
%then just equal to the work input to compressor)
% -enter 0 for none, 'all' for maximum possible (0 thrust)
%uses constant Cp/Cv in calculations.

corner_points = zeros(5,5);

%reference enteropy and enthalpy information
p0 = 14.5; %kPa
T0 = 216.65; %K
s0 = 7.1; %kJ/kg
h0 = 216.5; %kJ/kg
Cp = 1.004; %kJ/kgK
R = .287; %kJ/kgK

%entropy and enthalpy calcs
s_pt = @(p,T) s0 + Cp.*log(T./T0) - R.*log(p/p0);
h_pt = @(p,T) h0 + Cp.*(T - T0);

%input of knowns
corner_points([1,5],3) = p_amb;
corner_points(1,1) = T_amb;
corner_points([2,3],3) = p_amb.*p_ratio;
corner_points(3,1) = T_max;

%compute other properties
    %Compressor entropy
    corner_points(1:2,2) = s_pt(corner_points(1,3),corner_points(1,1));

    %Temperature at point 2
    corner_points(2,1) = T_amb*exp((R./Cp)*log(p_ratio));

    %Turbine entropy
    corner_points(3:5,2) = corner_points(1,2) + Cp.*log(T_max./corner_points(2,1));

    %check for invalid T_max
    if (T_max <= corner_points(2,1))
        error("Provided T_max is below compressor exit temperature, please adjust parameters");
    end

    %find enthalpy of points 1-3
    corner_points(1:3,5) = h_pt(corner_points(1:3,3),corner_points(1:3,1));

% find point 5 temperature, enthalpy
corner_points(5,1) = T_max*exp((R./Cp)*log(1./p_ratio));
corner_points(5,5) = h_pt(p_amb,corner_points(5,1));

%find point 4 enthalpy
if isnumeric(turb_output_power)
    corner_points(4,5) = corner_points(3,5) + corner_points(1,5) - corner_points(2,5) - turb_output_power;
elseif string(turb_output_power) == "all"
    corner_points(4,5) = corner_points(5,5);
else
    error("turb_output_power variable not recognised, use a numeric value or 'all'");
end

%find point 4 pressure and temperature
corner_points(4,1) = corner_points(3,1) + (corner_points(4,5)-corner_points(3,5))./Cp;
corner_points(4,3) = corner_points(3,3) .* exp((Cp./R).*log(corner_points(4,1)./corner_points(3,1)));

%check turbine overload
if corner_points(4,3) < corner_points(5,3)
    error("Turbine Overloaded, reduce requested turbine output power")
end

%find specific volumes
corner_points(:,4) = R.*corner_points(:,1)./corner_points(:,3);

end