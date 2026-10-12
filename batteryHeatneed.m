function Qbat = batteryHeatneed(T_inside, T_outside, Qlossbat)
    
    dT = T_inside - T_outside;
    Qbat = Qlossbat.*dT;
end
