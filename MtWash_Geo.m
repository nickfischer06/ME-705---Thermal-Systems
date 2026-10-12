function [t_s, z_m, tripStage] = MtWash_Geo(z_base_m, z_summit_m, trackLength, Vup_ms, Vdown_ms, t_stationary, dt_s)

%MtWash_Geo - Allows for a geometrical discription of Mount Washington to
%be called during the scinario plotting portion of the project.

    tUp_s = trackLength/Vup_ms;
    tDown_s = trackLength/Vdown_ms;

    t_up = (0:dt_s:tUp_s)';
    z_up = z_base_m + (z_summit_m-z_base_m).*(t_up./tUp_s);
    
    t_stationary = (dt_s:dt_s:t_stationary)' + t_up(end);
    z_stationary = z_summit_m*ones(size(t_stationary));

    t_down = (dt_s:dt_s:tDown_s)' + t_stationary(end);
    z_down = z_summit_m - (z_summit_m - z_base_m).*((t_down - t_down(1) + dt_s)./tDown_s);

    t_s = [t_up; t_stationary; t_down];
    z_m = [z_up; z_stationary; z_down];

    tripStage = [repmat("Ascent", numel(t_up),1); repmat("Stationary", numel(t_stationary),1); repmat("Descent", numel(t_down),1)];
end

