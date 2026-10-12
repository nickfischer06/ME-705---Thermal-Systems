function [y_vals, x_vals] = GenDome(y_param,x_param,num_pts,fluid)
    %GenDome gets the values for a saturation/vapor dome based off of the
    %fluid and desired inputs in the x and y parameter slots. As long as
    %any two thermodynamic properties are known these values can be found.

    %Gen Y values as a list
    t_rng = [CoolProp.Props1SI([char(y_param),'MIN'],char(fluid)),CoolProp.Props1SI([char(y_param),'CRIT'],char(fluid))];
    y_vals = [linspace(t_rng(1),t_rng(2),num_pts),flip(linspace(t_rng(1),t_rng(2),num_pts))];

    %Create q values in a logical matrix, zeros and ones in the first and
    %second halves respectively.
    q_logic = zeros(1,2*num_pts);
    q_logic(1:num_pts) = ~q_logic(1:num_pts);

    %X vlaues generation
    x_vals = zeros(1,num_pts);
    for i=1:num_pts*2
        x_vals(i) = CoolProp.PropsSI(char(x_param),char(y_param),y_vals(i),'Q',q_logic(i),char(fluid));
    end
end
