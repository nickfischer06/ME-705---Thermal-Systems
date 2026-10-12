function [y_vals,x_vals,h_end] = ph_isENTR(p_init,h_init,p_end,num_pts,fluid)
    %A function to get the isentrope values for the Ph Diagram. Takes in
    %the known values in terms of initial and final pressures, and the
    %initial enthalpy to find the entropy at the start, then goes and
    %iterates across a range to get the ending enthalpy based off the found entropy being constant.

    %Find entropy value
    entropy = CoolProp.PropsSI('S','P',p_init,'H',h_init,fluid);

    %Generate outputs
    y_vals = linspace(p_init,p_end,num_pts);
    x_vals = zeros(1,num_pts);

    %find h values
    for i=1:num_pts
        x_vals(i) = CoolProp.PropsSI('H','P',y_vals(i),'S',entropy,fluid);
    end
    h_end = x_vals(num_pts);
end