% ME 705 Project 1A | 10/06/2026
% Project by Nicholas Fischer

% Problem Statement: consider whether a heat pump should or should not
%be used in the vehicle.

addpath('..\..\..\Extracted_CoolProp\ThermoTablesCoolProp_v6_1_0\') %ADD COOLPROP path here - user specific, only fill out if COOLPROP is not in the directory in which this file is running.
%UNCOMMENT ADD PATH WHEN GRADING!!

%Import Geometry and R values for thermal resistance calculations later on
zones = load_inputs("structural_properties.xlsx");
c = zones.Cabin;
v = zones.VIP;

%Initialize Variables
Refridge = 'R32'; %Used in Heat Pump; Chose R32 as refrigerant B/C I used it in HW3... Can vary to user needs

g = 9.81; %(m/s^2) gravitational constant

z_base = 820; %(m) The elevation of Marshfield base station of the Cog Railway
z_summit = 1917; %(m) The elevation of the highest point on the railway.
%Both z vales taken from the Cog Railway website

t_trip = 1800; %(s) Time to do a trip to the summit and back (15min each way)

h_mount = z_summit - z_base; %(m) height change of vechicle up the mountain

T_cabin = 22; %Temperature in operating cabin (deg C)
T_bat = 30; %Temperature of battery (deg C)
T_vip = 22; %Temperature of vip area (deg C)

mVehic = 4082.33; %(kg) 9000lb as taken from the URC poster

%General code structuring:
Tout_rng = -45:.5:35; %Degrees Celcius (Mount Washington Temp Range)
Tin_rng = 15:.5:35; %Degrees Celcius (Desired indoor temperatures)
T_kout = Tout_rng + 273.15; %Convert to Kelvin
T_kin = Tin_rng + 273.15; %Convert to Kelvin

T_in = [T_cabin, T_bat, T_vip]; %The desired teperatures inside each of the modules

%Energy needed to get the train up the mountain (using mgh as the measure
%of energy needed)

E_minBat = ((mVehic*g*h_mount)/(t_trip))/1000; %(kW)

batSplit = 0.6; %This is the percentage of battery power allocated to powering the system

Bat_size = (E_minBat/batSplit)*(t_trip/3600); %(kWh) - The battery size needed for the trip in kWh
Bat_size = Bat_size*1.75; %(kWh) - To account for longer trips the battery size from the standard trip was doubled to allow for more heating capacity or longer trips.

%Plot the COP of the heatpump based on the Temperature differences. This is
%based off of the idealized Heat Pump cycle assuming 2isobaric,
%1isenthalpic, and 1isentropic process. Furthermore, there is no
%overshooting into the liquid or vapor regions (Assuming to stop at Q is 0
%and Q is 1).

%Pressure Ratio limits
PressureRatio_lim = 10;

[COP_grid, PressureRatio_grid, Tout_grid, Tin_grid] = COPheatmap(T_kout, T_kin, Refridge,PressureRatio_lim);

%Resistance heater COP Plot
[COP_Resist_grid] = HeatmapRis(T_kout,T_kin);

%COP grid cleanup to fit the limit

COP_plot = COP_grid;

%Figure generation for the heatmaps
figure('Name','Heatpump COP Colormap at Temperature Range')
levels = 1:.2:7;
[C, hC] = contourf(Tout_grid - 273.15, Tin_grid - 273.15, COP_plot, levels, 'LineColor','none');
colormap("turbo");
cb = colorbar;
Clim = ([1,7]);
cb.Label.String = 'Heating COP for heat pump [-]';
hold on;

xlabel('Ambient (outdoor) temperature [deg C]');
ylabel('Required Condenser/Delivery Temperature [deg C]');
title('Heat Pump Heating COP heatmap against Indoor and OutdoorTemperatures');

%Overlay the deisred heating regions into the heatmap
region_names = {'Cabin', 'Battery', 'VIP'};
for k = 1:3
    yline(T_in(k), 'w:', region_names{k}, 'LabelHorizontalAlignment','left', 'LineWidth', 1.2);
end

xlabel('Outside Temperature (deg C)');
ylabel('Desired temperature (deg C)');

%Resistance Heater COP Heatmap plotting
figure('Name', "Resistance Heater COP at Temperature Range");
imagesc(Tout_rng, Tin_rng, COP_Resist_grid);
set(gca,'YDir','normal');
colormap('turbo');
clim([1,8]);
cb = colorbar;
cb.Label.String = 'COP';
xlabel('Ambient (outdoor) temperature (deg C)');
ylabel('Required Condenser/Delivery Temperature (deg C)');
title('Resitive (PTC) Heater: COP = 1 Everywhere');
grid on;
box on;

unique(COP_Resist_grid(:))

%Endurance mapping: Heatpump, versus resistance heater, versus hybrid
%model.
%This is done to show if it is a good idea to invest money into a heatpump
%system and will payoff with segnificant gains to heating or operation
%range.

E_batTh_kWh = Bat_size*(1-batSplit); %Remaining energy from the battery allocated to provide work for thermal systems

V_windExp = 15.6; %[m/s] CONSIDER A RANGE FOR THIS!! - This is the harshest at the summit

%Battery pack heat loss conductance (W/K) - Edit as needed. Values are
%assumed based on size of train and needs for the battery
packL = 1.2; %(m) Length of battery pack
packW = .8; %(m) Width of battery pack
packH = .3; %(m) Height of battery pack

A_bat = 2*(packL*packW + packL*packH + packW*packH);
R_insul = .025/.03; %25mm insulation - XPS typical for a battery
R_films = .1; %small film allowance
BattQLoss = A_bat/(R_insul  + R_films); %W/K

%Find heat loading/need for the system
Qcab_end = heatNeed(Tout_rng,T_cabin,V_windExp,c.geometry,c.Rmats,c.Hi,c.Air_infil,c.kWind,c.numOcc,c.Qperson);
QVIP_end = heatNeed(Tout_rng,T_vip,V_windExp,v.geometry,v.Rmats,v.Hi,v.Air_infil,v.kWind,v.numOcc,v.Qperson);
Qbat_end = batteryHeatneed(T_bat,Tout_rng,BattQLoss);
Qtot_end = Qcab_end + QVIP_end + Qbat_end; %in Watts

%Heat demanded per zone or Qdot in the plots is as follows. This takes
%previously calculated values and forces them into row vectors and cuts
%them off at 0.
Q_cabin = max(Qcab_end(:).',0);
Q_VIP = max(QVIP_end(:).',0);
Q_bat = max(Qbat_end(:).',0);
Q_dot = Q_bat + Q_VIP + Q_cabin; %This is the total heat dilivered to all regions.

%Heat pump COP at each zone of dilivery
COP_cabin = COPheatmap(T_kout, T_cabin+273.15,Refridge,PressureRatio_lim);
COP_VIP =  COPheatmap(T_kout, T_vip+273.15,Refridge,PressureRatio_lim);
COP_bat = COPheatmap(T_kout, T_bat+273.15,Refridge,PressureRatio_lim);

%Where Pressure Ratio > Pressure Ratio limit or T_out >= T_in COPheatmap
%returns a NaN value. Therefore, a resistance heater is used as a fallback
%in those areas with COP = 1.
COP_cabin(isnan(COP_cabin)) = 1;
COP_VIP(isnan(COP_VIP)) = 1;
COP_bat(isnan(COP_bat)) = 1;

%Electrical power from the battery
Wdot_HP = Q_cabin./COP_cabin + Q_VIP./COP_VIP + Q_bat./COP_bat;
Wdot_res = Q_dot; %The reisitance heater work is 1:1 so W=Q.

%Effective COP of the heatpump system
COP_eff = ones(size(Q_dot));
tru = Wdot_HP > 0;
COP_eff(tru) = Q_dot(tru)./Wdot_HP(tru);

%Endurance curves
COP_resEnd = ones(size(COP_eff));
tmax_hp_min = missionEndure(Q_dot, COP_eff, E_batTh_kWh);
tmax_res_min = missionEndure(Q_dot, COP_resEnd, E_batTh_kWh);
pctGain = 100*(tmax_hp_min - tmax_res_min)./tmax_res_min;

need = Q_dot > .05*max(Q_dot); %This is taking into account areas where heat is really needed. If not the warm end divides by something close to zero and values get too large.
tmax_hp_min(~need) = NaN;
tmax_res_min(~need) = NaN;
pctGain(~need) = NaN;

%Train endurance versus outside temperature
figure("Name", "Train Endurance versus Temperature", "Position",[100 100 800 600]);
plot(T_kout, tmax_hp_min, 'r--', "LineWidth", 2);
hold on;
plot(T_kout, tmax_res_min, 'k--', "LineWidth",2);
xlabel("Outdoor Temperature (K)");
ylabel("Max Mission Duration before Energy is Exhausted (min)");
title("Endurance vs Outside Temperature")
legend('Heat pump', 'Resistive heater', "Location","northwest");
grid on;

%Percent endurance gain
figure("Name","Percent Endurance Gain", "Position",[100 100 800 600]);
plot(T_kout, pctGain, 'r.', "LineWidth", 2);
xlabel("Outside Temperature (K)");
ylabel("Endurance Gain from the Addition of Heatpump (%)");
title("Percent Increase in Misson Endurance, Heat Pump vs. Resistance Heater");
grid on;

%Additional plots as discussed in lecture on 10/2/2026: COP vs T_L, Qdot vs
%T_L, and Wdot vs T_L

%Figure generation of the three plots discussed in lecture
figure("Name","COP, Q_dot, W_dot vs Outdoor Temperatures","Position",[100,100,500,500]);
tiles = tiledlayout(3,1,"TileSpacing","compact");

%COP vs T_L plot
nexttile;
plot(Tout_rng, COP_eff, 'r-', "LineWidth",2); %Heatpump system
hold on;
plot(Tout_rng, ones(size(Tout_rng)), 'k--', "LineWidth", 2); %PTC/Resistance System
%Both plotted to see where one becomes better than the other
ylabel("COP (-)");
legend("Heat pump","Resistive heater/PTC","Location","northwest");
title("COP vs Outdoor Temperatures");
grid on;

%Q_dot vs T_L plot
nexttile;
plot(Tout_rng,Q_dot/1000,"b-","LineWidth",2);
ylabel("Heating needs (kW)");
title("Heating needs vs Outdoor Temperature");
legend("System heat needed","Location","northwest");
grid on;

%W_dot vs T_L plot
nexttile;
plot(Tout_rng,Wdot_HP/1000,"g-","LineWidth",2);
hold on;
plot(Tout_rng,Wdot_res/1000,"k-","LineWidth",2);
ylabel("Electrical Input (kW)");
legend("Heat pump","Resistive heater/PTC","Location","northwest");
title("Electrical Power Input vs Outdoor Temperature");
grid on;

xlabel(tiles, "Outdoor temperature (deg C)")

%Scinario Building and Plotting

%GLOBAL SCINARIO VARIABLES - Edit as needed to fit needs of the user
dt_s = 10; %s, time step
trackLength = 5000; %m, track length (approximate)
eta_drive = .75; %Drivetrain effiecency (energy from battery output to wheels)
lapse = 6.5; %K per km, temperature drop with altitude up the mountain

HP.Qrated = 6000; %W, heat pump capacity at Tref (Placeholder)
HP.Tref = 7; %deg C, reference temperature for rated capacity
HP.capDerate = .025; %Capacity loss per K below Tref
HP.capFloor = .25; %capacity never drops below 25 percent of rated capacity
COP_minHP = 1; %Heat pump only runs whenever COP is defined
COP_minHybrid = 1.5; %Hybrid system only uses the heatpup if COP is greater than this value

Ttab_C = -60:1:30; %deg C, COP lookup table range

%The Scinario definitions (Editable)
sc(1) = struct("Name","VIP tour", "Temp_base",2,"Vwind_base",4,"Vwind_summit",12,"occCab",2,"occVIP",8,"TempVIP",22,"infilMult",1,"Vtrain_up",trackLength/900,"Vtrain_down",trackLength/900,"Tstationary",1200,"Plowdrag",1);
sc(2) = struct("Name","Snow plowing","Temp_base",-15,"Vwind_base",10,"Vwind_summit",30,"occCab",2,"occVIP",0,"TempVIP",0,"infilMult",1,"Vtrain_up",1.5,"Vtrain_down",2.5,"Tstationary",900,"Plowdrag",1.6);
sc(3) = struct("Name","Search and rescue","Temp_base",-25,"Vwind_base",12,"Vwind_summit",40,"occCab",3,"occVIP",10,"TempVIP",22,"infilMult",2.5,"Vtrain_up",4,"Vtrain_down",4,"Tstationary",7200,"Plowdrag",1.2);

nS = numel(sc);
copCache = containers.Map('KeyType','double','ValueType','any');

E_resist = zeros(nS,1);
E_HP = E_resist;
E_hybrid = E_resist;
Eunmet_HP = E_resist;

E_available = E_resist;
hold_resist = E_resist;
hold_hybrid = E_resist;
Q_peak = E_resist;

tAll = cell(nS,1);
W_resist_all = tAll;
W_HP_all = tAll;
W_hybrid_all = tAll;

for s = 1:nS
    P = sc(s);

    %Mission Profile
    [t, z, stage] = MtWash_Geo(z_base, z_summit, trackLength, P.Vtrain_up, P.Vtrain_down, P.Tstationary, dt_s);
    n = numel(t);
    Vtrain = zeros(n,1);
    Vtrain(stage=="Ascent") = P.Vtrain_up;
    Vtrain(stage=="Descent") = P.Vtrain_down;

    frac_upMt = (z - z_base)/(z_summit - z_base);
    Tamb = P.Temp_base - lapse * (z-z_base)/1000; %degrees C
    Vrel = P.Vwind_base + (P.Vwind_summit - P.Vwind_base)*frac_upMt + Vtrain; %Velocity of wind relative to the train (m/s)
    
    %Heating loads/needs (W)
    %In the following section c indicates cabin, v indicates vip, and b
    %indicates battery.
    cc = c;
    cc.numOcc = P.occCab;
    cc.Air_infil = v.Air_infil * P.infilMult;
    
    vv = v;
    vv.numOcc = P.occVIP;
    vv.Air_infil = v.Air_infil * P.infilMult;

    Qc = zeros(n,1);
    Qv = zeros(n,1);

    for i = 1:n
        Qc(i) = heatNeed(Tamb(i), T_cabin, Vrel(i), cc.geometry, cc.Rmats, cc.Hi, cc.Air_infil, cc.kWind, cc.numOcc, cc.Qperson);
        Qv(i) = heatNeed(Tamb(i), P.TempVIP, Vrel(i), vv.geometry, vv.Rmats, vv.Hi, vv.Air_infil, vv.kWind, vv.numOcc, vv.Qperson);
    end

    Qb = BattQLoss*max(T_bat - Tamb,0);
    Qtot = Qc + Qv + Qb;
    Q_peak(s) = max(Qtot);

    %COP at each time step (NaN means the heat pump can not run)
    COPc = interp1(Ttab_C, getCOP(T_cabin, Ttab_C, Refridge, PressureRatio_lim, copCache), Tamb, "Linear", NaN);
    COPv = interp1(Ttab_C, getCOP(P.TempVIP, Ttab_C, Refridge, PressureRatio_lim, copCache), Tamb, "Linear", NaN);
    COPb = interp1(Ttab_C, getCOP(T_bat, Ttab_C, Refridge, PressureRatio_lim, copCache), Tamb, "Linear", NaN);

    %Electrical power needs for each system (W)
    Wresist = Qtot; %risistance heater/PTC system
    
    %Resistive heater
    [W_HP, unmet_HP] = hpSystem(Qc,Qv,Qb,COPc,COPv,COPb,Tamb,HP,COP_minHP); %heat pump only system
    [W_HP2, unmet_h] = hpSystem(Qc,Qv,Qb,COPc,COPv,COPb,Tamb,HP,COP_minHybrid); %hybrid system

    W_hybrid = W_HP2 + unmet_HP; %resistance heater covers the gaps

    %Energies (kWh)
    kWh = @(W,idx) trapz(t(idx), W(idx))/3.6e6;
    all_ = true(n,1);
    asc = stage=="Ascent";
    sta = stage=="Stationary";
    dsc = stage=="Descent";

    E_resist(s) = kWh(Wresist,all_);
    E_HP(s) = kWh(W_HP,all_);
    E_hybrid(s) = kWh(W_hybrid,all_);
    Eunmet_HP(s) = kWh(unmet_HP, all_);

    %Battery budget for the thermal systems
    E_prop = mVehic*g*(z_summit-z_base)/eta_drive * P.Plowdrag/3.6e6; %kWh
    E_available(s) = Bat_size - E_prop;

    if E_available(s) <= 0
        warning('%s: drivetrain system uses the whole battery (%.1f kWh). Thermal allowance at 0.',P.name,E_prop);
        E_available(s) = 0;
    end
    
    %Maximum summit stay: energy left after ascent and descen divided by
    %the summit power
    if any(sta)
        for sysName = ["resist","hybrid"]
            if sysName=="resist"
                W = Wresist;
            else
                W = W_hybrid;
            end
            Eleft = E_available(s) - kWh(W,asc) - kWh(W,dsc);
            hold_min = max(0,Eleft) / (mean(W(sta))/1000) * 60;

            if sysName=="resist"
                hold_resist(s) = hold_min;
            else
                hold_hybrid(s) = hold_min;
            end
        end
    end

    tAll{s} = t/60;
    W_resist_all{s} = Wresist/1000;
    W_HP_all{s} = W_HP/1000;
    W_hybrid_all{s} = W_hybrid/1000;
end

%Table of results
names = [sc.Name]';
Results = table(names, E_available, E_resist, E_hybrid, E_HP, 100*(E_resist-E_hybrid)./E_resist, Eunmet_HP, hold_resist,hold_hybrid,Q_peak/1000, ...
    'VariableNames', {'Scenario', 'Budget_kWh','Resistive_kWh','Hybrid_kWh','HP_only_kWh','HybridSaving_pct','HPonly_UnmetHeat_kWh','Hold_resistive_min','Hold_Hybrid_min','PeakThermalLoad_kW'});
disp(Results);

%Plots
figure("Name","Electrical Power vs Time during Missions", "Position", [200,100,900,500]);
tiles2 = tiledlayout(nS,1,"TileSpacing","compact");
for s = 1:nS
    nexttile;
    plot(tAll{s}, W_resist_all{s}, "green*", "LineWidth", 1.5);
    hold on;
    plot(tAll{s}, W_hybrid_all{s}, "blue-", "LineWidth", 1.5);
    plot(tAll{s}, W_HP_all{s}, "r--", "LineWidth", 1.5);
    title(sc(s).Name);
    ylabel("Electrical Power (kW)");
    grid on;

    if s==1
        legend("Resistive", "Hybrid", "Heat Pump only", "Location", "northwest");
    end
end
xlabel(tiles2, "Mission time (min)");

figure("Name","Thermal Energy per Mission", "Position",[100,100,800,500]);
bar([E_resist, E_hybrid, E_HP]);
hold on;
plot(1:nS, E_available, "red_", "MarkerSize", 40, "LineWidth", 2.5);
xticks(1:nS);
xticklabels(names);
ylabel("Thermal Electrical Energy (kWh)");
legend("Resistive","Hybrid","Heat Pump Only","Battery Budget","Location","northwest");
title("Energy Used vs Available Energy");
grid on;

figure("Name","Max Summit Stay time","Position",[100,100,800,500]);
bar([hold_resist,hold_hybrid]);
xticks(1:nS);
xticklabels(names);
ylabel("Max summit stay before descent reserve is depleted (min)");
legend("Resistve","Hybrid","Location","northwest");
title("Summit Endurance");
grid on;

%Local functions
function cop = getCOP(Tset, Ttab_C, fluid, PRlim, cache)
%COP versus outdoor temperature for a single delivery temperature found in
%the cache.
    if isKey(cache, Tset)
        cop = cache(Tset);
        return;
    end
    cop = COPheatmap(Ttab_C + 273.15, Tset + 273.15, fluid, PRlim);
    cop = cop(:).';
    cache(Tset) = cop;
end

function [W, unmet] = hpSystem(Qc,Qv,Qb,COPc,COPv,COPb,Tamb,HP,COPmin)
%Heat pump electrical power (W) and heat it can not diliver (W)
%The heat pump only can serve a zone wher COP is defined and >= COPmin
    ac = ~isnan(COPc) & COPc >= COPmin;
    av = ~isnan(COPv) & COPv >= COPmin;
    ab = ~isnan(COPb) & COPb >= COPmin;

    COPc(~ac) = 1;
    COPc(~av) = 1;
    COPc(~ab) = 1;
    %Avoid any NaN*0

    Qdem = Qc.*ac + Qv.*av + Qb.*ab;
    Qcap = HP.Qrated * max(HP.capFloor, min(1,1-HP.capDerate*(HP.Tref - Tamb)));

    f = min(1, Qcap./max(Qdem, eps));

    Qhc = f.*Qc.*ac;
    Qhv = f.*Qv.*av;
    Qhb = f.*Qb.*ab;

    W = Qhc./COPc + Qhv./COPv + Qhb./COPb;
    unmet = (Qc+Qv+Qb) - (Qhc+Qhv+Qhb);
end







        



