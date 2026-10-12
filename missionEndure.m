function t_max_min = missionEndure(Qdot_need, COP, Energy_budget_kWh)
%This function ges the maximum time a fixed thermal energy budget can
%sustain a given heating load at the given COP.

    P_kW = max(Qdot_need,0)./COP/1000; %(kW)
    t_max_hr = Energy_budget_kWh./P_kW; %(hr)
    t_max_min = t_max_hr*60; %(min)
end
