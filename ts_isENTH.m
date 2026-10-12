function [y_vals,x_vals,sEnd] = ts_isENTH(t_start,s_start,t_end,num_pts,fluid)
    %Similar to ph_isENTR function this takes the known fact that the
    %enthalpy remains constant then iterates to find the ending s value to
    %get a point on the t-s diagram.

    %calculate enthalpy values
    enthalpy = CoolProp.PropsSI('H','T',t_start,'S',s_start,fluid);

    %Init output points and lists
    y_vals = linspace(t_start,t_end,num_pts);
    x_vals = zeros(1,num_pts);

    %Find the s values
    for i = 1:num_pts
        p = CoolProp.PropsSI('P','T',y_vals(i),'Q',0,fluid);
        x_vals(i) = CoolProp.PropsSI('S','P',p,'H',enthalpy,fluid);
    end
    sEnd = x_vals(num_pts);
end
