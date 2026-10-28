%ME 705 | F26
%HW 5 - Brayton Cycle T-s and P-v diagrams
%Nicholas Fischer
%10/23/26

%Problem Setup: Bagdhad, Iraq 2003- A Lockheed Martin F-117 fighter jet is flying
%at an altitude of 45,000 ft (13700 m). The jet, using its two GE F404-F1D2 turbofan engines
%is approaching its target at its maximum cruising speed of mach .92 (305
%m/s). Plot the T-s and P-v diagrams for the brayton cycle of these
%engines. (All statistics for scinario found on F-117 spec page here:
%https://migflug.com/aircraft/f-117-nighthawk/)

%reference enteropy and enthalpy information
p0 = 14.5; %kPa, inlet pressure
T0 = 216.65; %K, inlet temperature
s0 = 7.1; %kJ/kg, reference entropy
h0 = 216.5; %kJ/kg, referance enthalpy
Cp = 1.004; %kJ/kgK, Cp of Air
R = .287; %kJ/kgK, R of Air
Tmax = 1400; %K, maximum temperature of working fluid in engine
p_ratio = 26; %Pressure ratio from GE F404 engine specs
turb_output_power = 0; %kJ/kg (no extra turbine work)

%Equations describing relationships
s_pt = @(p,T) s0 + Cp.*log(T./T0) - R.*log(p/p0); %entropy at (p,T)
h_pt = @(p,T) h0 + Cp.*(T - T0); %enthalpy at (p,T)
gamma = Cp/(Cp-R);
isen_v = @(pa,va,pv) va.*(pa./pv).^(1/gamma); %isentrope v at pressure pv

%Corner points from function
corner_pts = brayton_cycle_pts(p0,T0,Tmax,p_ratio,turb_output_power);
T = corner_pts(:,1);
s = corner_pts(:,2);
p = corner_pts(:,3);
v = corner_pts(:,4);
h = corner_pts(:,5);

n = 1000; %points per curve (1000 should give good resolution

names = {'Compressor (1-2)', 'Combustor (2-3)', 'Turbine (3-4)', 'Nozzle (4-5)', 'Heat Rejection to Ambient (5-1)'};
colors = [0 .45 .74; %Compressor - blue
          .85 .33 .10; %Combustor - red/orange
          .47 .67 .19; %Turbine - green
          .49 .18 .56; %Nozzle - purple
          .5 .5 .5]; %rejection - gray
styles = {'-','-','-','-','--'}; %rejection is dashed because it is not actually following that path

%T-s diagram
%Isentropic process are vertical lines (Compressor and Turbine+Nozzle)
T_comb = linspace(T(2), T(3), n);
s_comb = s_pt(p(2), T_comb); %Combustor where p = p2

T_rej = linspace(T(5), T(1), n);
s_rej = s_pt(p(1), T_rej); %Rejection where p = pamb

ts_s = {[s(1) s(2)], s_comb, [s(3) s(4)], [s(4) s(5)], s_rej};
ts_T = {[T(1) T(2)], T_comb, [T(3) T(4)], [T(4) T(5)], T_rej};

figure('Name', 'Brayton Cycle T-s Diagram');
hold on;
grid on;
box on;
H = gobjects(1,5);
for i = 1:5
    H(i) = plot(ts_s{i}, ts_T{i}, styles{i}, 'Color', colors(i,:), 'LineWidth', 2);
end
plot(s,T, 'kx', 'MarkerSize', 12, 'LineWidth', 2, 'HandleVisibility', 'off');
for i = 1:5
    text(s(i), T(i), sprintf('  %d',i), "FontSize",12,"FontWeight","bold","VerticalAlignment","bottom","HorizontalAlignment","left");
end
xlabel('Specific Entropy, s (kJ/kg K)');
ylabel('Temperature, T (K)');
xlim([6,9]); %entropy limits on axes
ylim([0,1500]); %temperature limits on axes
title(sprintf('Jet Engine Brayton Cycle for F-117 Nighthawk: T-s Diagram'));
legend(H, names, 'Location','best');

%P-v diagram
%Isentropic processes follow a p*v^k = constant (Compressor and
%Turbine+nozzle); combustor and rejection are horizontal
p_comp = linspace(p(1),p(2),n);
v_comp = isen_v(p(1),v(1),p_comp); %compressor
p_turb = linspace(p(3),p(4),n);
v_turb = isen_v(p(3),v(3),p_turb); %turbine
p_noz = linspace(p(4),p(5),n);
v_noz = isen_v(p(4),v(4),p_noz); %nozzle

pv_v = {v_comp, [v(2) v(3)], v_turb, v_noz, [v(5) v(1)]};
pv_p = {p_comp, [p(2) p(3)], p_turb, p_noz, [p(5) p(1)]};

figure('Name', 'Brayton Cycle P-v Diagram');
hold on;
grid on;
box on;
H2 = gobjects(1,5);
for i = 1:5
    H2(i) = plot(pv_v{i}, pv_p{i}, styles{i}, 'Color', colors(i,:), 'LineWidth', 2);
end
plot(v, p, 'kx', 'MarkerSize',12, 'LineWidth',2,'HandleVisibility','off');
for i = 1:5
    text(v(i), p(i), sprintf('  %d', i), "FontSize",12, 'FontWeight','bold', 'VerticalAlignment','bottom','HorizontalAlignment','left');
end
xlabel('Specific volume, v (m^3/kg)');
ylabel('Pressure, P (kPa)');
title(sprintf('Jet Engine Brayton Cycle for F-117 Nighthawk: P-v Diagram'));
legend(H2, names, 'Location','best');

%% Additional Function I made to help with analysis
%function [corner_points] = brayton_cycle_pts(p_amb,T_amb,T_max,p_ratio,turb_output_power)
%'brayton_cycle_pts' outputs the corner points for states 1 through 5 (for
%jet engine application) of the brayton cycle in air.

%ambient pressure is in kPa
%ambient temperature is in K
%turb_output_power is extra power extracted by the turbine (if not extra
%then just equal to the work input to compressor)
% -enter 0 for none, 'all' for maximum possible (0 thrust)
%uses constant Cp/Cv in calculations.

%corner_points = zeros(5,5);

%reference enteropy and enthalpy information
%p0 = 14.5; %kPa
%T0 = 216.65; %K
%s0 = 7.1; %kJ/kg
%h0 = 216.5; %kJ/kg
%Cp = 1.004; %kJ/kgK
%R = .287; %kJ/kgK

%entropy and enthalpy calcs
%s_pt = @(p,T) s0 + Cp.*log(T./T0) - R.*log(p/p0);
%h_pt = @(p,T) h0 + Cp.*(T - T0);

%input of knowns
%corner_points([1,5],3) = p_amb;
%corner_points(1,1) = T_amb;
%corner_points([2,3],3) = p_amb.*p_ratio;
%corner_points(3,1) = T_max;

%compute other properties
    %Compressor entropy
%    corner_points(1:2,2) = s_pt(corner_points(1,3),corner_points(1,1));

    %Temperature at point 2
%    corner_points(2,1) = T_amb*exp((R./Cp)*log(p_ratio));

    %Turbine entropy
%    corner_points(3:5,2) = corner_points(1,2) + Cp.*log(T_max./corner_points(2,1));

    %check for invalid T_max
%    if (T_max <= corner_points(2,1))
%        error("Provided T_max is below compressor exit temperature, please adjust parameters");
%    end
%
    %find enthalpy of points 1-3
%    corner_points(1:3,5) = h_pt(corner_points(1:3,3),corner_points(1:3,1));

% find point 5 temperature, enthalpy
%
% corner_points(5,5) = h_pt(p_amb,corner_points(5,1));

%find point 4 enthalpy
%if isnumeric(turb_output_power)
%    corner_points(4,5) = corner_points(3,5) + corner_points(1,5) - corner_points(2,5) - turb_output_power;
%elseif string(turb_output_power) == "all"
%    corner_points(4,5) = corner_points(5,5);
%else
%    error("turb_output_power variable not recognised, use a numeric value or 'all'");
%end

%find point 4 pressure and temperature
%corner_points(4,1) = corner_points(3,1) + (corner_points(4,5)-corner_points(3,5))./Cp;
%corner_points(4,3) = corner_points(3,3) .* exp((Cp./R).*log(corner_points(4,1)./corner_points(3,1)));

%check turbine overload
%if corner_points(4,3) < corner_points(5,3)
%    error("Turbine Overloaded, reduce requested turbine output power")
%end

%find specific volumes
%corner_points(:,4) = R.*corner_points(:,1)./corner_points(:,3);

%end