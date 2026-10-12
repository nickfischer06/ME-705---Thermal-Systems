function [COP_grid, PressureRatio_grid, Tout_grid, Tin_grid] = COPheatmap (T_out, T_in, Refridgerant, Max_PressureRatio,dT_evap,dT_cond,isent_eff,COP_max)
    %Finds the COP values at a given T_L and T_H using CoolProp calls at
    %all four points of interest on the heat pump cycle.
    %Conditional statements to start help with setting a
    %baseline for the dT at both ends of the system, pressure ratio, the efficiency of the compressor, and maxCOP limit, should additional data not be known to the user.

    if nargin < 4 || isempty(Max_PressureRatio)
        Max_PressureRatio = Inf; 
    end
    if nargin < 5 || isempty(dT_evap)
        dT_evap = 8;
    end
    if nargin < 6 || isempty(dT_cond)
        dT_cond = 10;
    end
    if nargin < 7 || isempty(isent_eff)
        isent_eff = 0.65;
    end
    if nargin < 8 || isempty(COP_max)
        COP_max = 7;
    end


    [Tout_grid, Tin_grid] = meshgrid(T_out, T_in); %grids stay in terms of air temperatures
    numIn = numel(T_in);
    numOut = numel(T_out);

    %Evaporator states: find dependant only on T_out
    T0 = T_out(:) - dT_evap;
    p_evap = props('P','T',T0,'Q',1,Refridgerant);
    h_evap = props('H','T',T0,'Q',1,Refridgerant);
    s_evap = props('S','T',T0,'Q',1,Refridgerant);

    %Condenser states: only dependant on T_in:
    Ti = T_in(:) + dT_cond;
    p_cond = props('P','T',Ti,'Q',0,Refridgerant);
    h_cond = props('H','T',Ti,'Q',0,Refridgerant);
    
    %Pressure ratio on the full grid
    PressureRatio_grid = p_cond ./ p_evap.';

    %Compression only within limits bounded by 1 and max pressure ratio are
    %kept
    validated = PressureRatio_grid > 1 & PressureRatio_grid <= Max_PressureRatio;

    S1 = repmat(s_evap.', numIn, 1);
    PCond = repmat(p_cond, 1, numOut);

    h_comp_s = nan(numIn, numOut);
    h_comp_s(validated) = props('H','S',S1(validated),'P',PCond(validated),Refridgerant);

    %Actual compressure enthalpy because the compressor does extra work I
    %have a constant that adjusts for this

    h_comp = h_evap.' + (h_comp_s - h_evap.') ./ isent_eff;

    COP_grid = (h_comp - h_cond)./(h_comp - h_evap.');

    COP_grid(COP_grid > COP_max) = COP_max;
end

function out = props(output, n1, v1, n2, v2, fluid)
    %This local function gives one Cool Prop call for a whole vector (my
    %priveous one made one call per grid point which made code slow... this
    %hopefully optimizes)
    i = max(numel(v1), numel(v2));
    if isscalar(v1)
        v1 = repmat(v1, i, 1);
    end
    if isscalar(v2)
        v2 = repmat(v2, i, 1);
    end
    out = nan(i,1);
    for j = 1:i
        out(j) = CoolProp.PropsSI(output,n1,v1(j),n2,v2(j),fluid);
    end
end
