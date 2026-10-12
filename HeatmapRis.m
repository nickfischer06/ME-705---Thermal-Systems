function COP_Resist_grid = HeatmapRis(T_out, T_in)
    %Resistive heatmap models the efficiency for a resistive heater (PTC)
    %This will serve as a direct comparison to the heatmap of the heatpump
    %efficencies which can then lead to more informed decision making.

    [Tout_grid, Tin_grid] = meshgrid(T_out,T_in);
    COP_Resist_grid = ones(size(Tin_grid'))';
    COP_Resist_grid = ones(numel(T_in),numel(T_out));
end
