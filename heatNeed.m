function [Q_need, parts] = heatNeed(Tamb_C,Tinside_C,Vwind_ms,geometry,Rmats,Hi,Air_infil,kWindInfil,numOccupants,Qpersons)
    %heatNeed - this function handles all the thermal resistances of the
    %system. It calculates based off of properties of the air as well as
    %geometric properties and matirial properties put into the
    %'structural_properties.xlsx' sheet. At the end it summs the Q needed
    %for all different types of heat transfer and creates a struct that can
    %be referenced later on by the user for specific heating needs.

    rho_air = 1.2; %kg/m^3
    cp_air = 1005; %J/kg-K
    
    %Area calculations (m^2)
    Aroof = geometry.L * geometry.W;
    Afloor = Aroof;
    Awall = 2*(geometry.L + geometry.W)*geometry.H - geometry.Awindow;
    
    %U value for each surface
    H_0 = windConvectCoeff(Vwind_ms); %This is a coefficient for the exterior film of the vechicle
    Rfilm = 1/Hi + 1/H_0; %R value for that film
    
    U_area = Awall/(Rfilm + Rmats.wall) + Aroof/(Rfilm + Rmats.roof) + Afloor/(Rfilm + Rmats.floor) + geometry.Awindow/(Rfilm + Rmats.window); %Total thermal conductance (W/K)

    %Heating needs

    dT = Tinside_C - Tamb_C; %C
    Q_cond = U_area .* dT; %Heat loss to conduction for this area (W/K)
    
    Air_infillEFF = Air_infil + kWindInfil.*Vwind_ms; %The air changes and infiltration per hour
    m_dot_infill = rho_air*geometry.V.*(Air_infillEFF/3600); %kg/s
    Qinfill = m_dot_infill*cp_air.*dT; %infiltration due to environment/convection effects (W)

    Q_gainPPL = numOccupants*Qpersons; %(W), this is because people release body heat and will offset heat needed (albeit slightly)
    
    %Net heating/cooling need
    Q_need = Q_cond + Qinfill - Q_gainPPL;

    parts = struct("Conduction",Q_cond,"Infiltration",Qinfill,"People",Q_gainPPL,"UperArea", U_area);
end

function H_0 = windConvectCoeff(v, L)
%Exterior film coefficient for a wind of velocity v along the length of the
%vechicle in the flow direction. The default will be set to 10m (the length
%of the Car. nu is a constant which discribes the flow.

if nargin < 2
    L = 10;
end

%Air properties near freezing
k_air = .0243; %W/m/K
nu = 1.33e-5; %m^2/s
Pr = .71;

Re = max(v, 0.1) * L / nu;
Nu = .037 * Re.^.8 * Pr^(1/3);
H_0 = max(Nu * k_air / L, 5.7); %This sets it so that H_0 never drops below a natural convection floor
end 
