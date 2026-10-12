%ME 705 Thermal Systems Analysis and Design
%Nicholas Fischer
%HW 4
%09/28/2026

%CoolProp path
addpath('..\..\Extracted_CoolProp\ThermoTablesCoolProp_v6_1_0\');

%Portfolio Problem 1: A P-h and T-s diagram of the vapor-compression
%refrigeration cycle

%Temperatures (K)
tL = 249;
tH = 312;
dT = 5; %Temperature that the refrigerant is above or below the tL and tH values
fluid = 'R290'; %A common choice in some refrigerators, 'R134a' is also popular.

%Create values to plot
%Generates data points and to then connect in graphing

%Saturation/Vapor domes
[tDomevals, sDomevals] = GenDome('T','S',100,fluid);
[pDomevals, hDomevals] = GenDome('P','H',100,fluid);

%Find Reasonable cycle temperature values (refridgerant lower or higher so
%that heat can be absorbed)
tL_minus = tL - dT;
tH_plus = tH + dT;

%Compute high and low cycle pressures
P_hi = CoolProp.PropsSI('P','T',tH_plus,'Q',1,fluid);
P_lo = CoolProp.PropsSI('P','T',tL_minus,'Q',1,fluid);

%Get the corner points for refrence on the T-s cycle - assign already known
%values
ts_corners = zeros(4,2);
ts_corners(1,1) = tL_minus;
ts_corners(1:2,2) = CoolProp.PropsSI('S','T',tL_minus,'Q',1,fluid);

%Evaluate for the ts condenser isobar and assign the endpoint
[tVals_cond, sVals_cond, ts_corners(3,1),ts_corners(2,1)] = Ts_isobar(P_hi,100,0,ts_corners(1,2),'L',fluid);
ts_corners(3,2) = sVals_cond(1);

%Evaluate for the ts expansion valve 'h' value and assign to a corner
[tVals_exp, sVals_exp, ts_corners(4,2)] = ts_isENTH(tH_plus,sVals_cond(1),tL_minus,100,fluid);
ts_corners(4,1) = tL_minus;

%Do the same process for the P-h diagram where points are assigned and then
%knowns are filled in
ph_corners = [P_lo,0;P_hi,0;P_hi,0;P_lo,0];
ph_corners(3:4,2) = CoolProp.PropsSI('H','P',P_hi,'Q',0,fluid);
ph_corners(1,2) = CoolProp.PropsSI('H','P',P_lo,'Q',1,fluid);

%Evaluate for the P-h compressor isentrope and assign the endpoint
[pVals_comp,hVals_comp,ph_corners(2,2)] = ph_isENTR(P_lo,ph_corners(1,2),P_hi,100,fluid);

%Plotting the Cycle

%Figure window init and display configureations
fig = figure("Name","Homework 4: P-h and T-s Refridge Cycles");
tiles = tiledlayout(fig,2,1);
title(tiles,append("P-h and T-s plots for a ",fluid," refrigeration cycle"));

%T-s plot axes
ts_axes = nexttile;
ts_axes.NextPlot = "add";
xlabel("Specific Entropy (J/kgK)");
ylabel("Temperature (K)");
ylim(ts_axes,[200,400]);
title(ts_axes, "T-s Plot");

%P-h plot axes
ph_axes = nexttile;
ph_axes.NextPlot = "add";
xlabel("Specific Enthalpy (J/kg)");
ylabel("Pressure (Pa)");
ylim(ts_axes,[200,400]);
title(ts_axes, "P-h Plot");

%T-s saturation dome diagram
tsDome = plot(ts_axes,ts_corners(1:2,2),ts_corners(1:2,1),"Color",[.3,.1,.8],"LineWidth",1,"HandleVisibility","off");
ts_fill = fill(ts_axes,sDomevals,tDomevals,[.3,.1,.8],"FaceAlpha",.25,"LineStyle","none");

%T-s system lines
ts_comp_line = plot(ts_axes,ts_corners(1:2,2),ts_corners(1:2,1),"LineWidth",1,"Color",[.99,.2,.2]);
ts_cond_line = plot(ts_axes,sVals_cond,tVals_cond,"LineWidth",1,"Color",[.2,.6,.5]);
ts_exp_line = plot(ts_axes,sVals_exp,tVals_exp,"LineWidth",1,"Color",[.2,.75,.25]);
ts_evap_line = plot(ts_axes, [ts_corners(4,2),ts_corners(1,2)],[tL_minus,tL_minus],"LineWidth",1,"Color",[.8,.35,.1]);


%T_lo and T_hi lines
Tlo_line = plot(ts_axes,sDomevals([1,length(sDomevals)]),[tL,tL],"b--");
Thi_line = plot(ts_axes,sDomevals([1,length(sDomevals)]),[tH,tH],"r--");

%Plot and label any significant points
ts_points_plt = zeros(4,1);
for i=1:4
    ts_points_plt(i) = plot(ts_axes,ts_corners(i,2),ts_corners(i,1),"k.");
    text(ts_axes,ts_corners(i,2),ts_corners(i,1)+5,num2str(i));
end

%Legend for the T-s Diagram
legend(ts_axes,"Saturation Dome","Compressor","Condenser","Expansion Valve","Evaporator","T-Low = 249K", "T-High = 312 K",Location="northwest");

%P-h Saturation Dome
phDome = plot(ph_axes,hVals_comp,pVals_comp,"Color",[.3,.1,.8],"LineWidth",1,"HandleVisibility","off");
ph_fill = fill(ph_axes,hDomevals,pDomevals,[.3,.1,.8],"FaceAlpha",.25,"LineStyle","none");

%P-h Refridgeration lines
ph_comp_line = plot(ph_axes,hVals_comp,pVals_comp,"LineWidth",1,"Color",[.99,.2,.2]);
ph_cond_line = plot(ph_axes,[ph_corners(2,2),ph_corners(3,2)],[P_hi,P_hi],"LineWidth",1,"Color",[.2,.6,.5]);
ph_evap_line = plot(ph_axes,[ph_corners(4,2),ph_corners(1,2)],[P_lo,P_lo],"LineWidth",1,"Color",[.8,.35,.1]);
ph_exp_line = plot(ph_axes,ph_corners(3:4,2),ph_corners(3:4,1),"LineWidth",1,"Color",[.2,.75,.25]);

%P-h legend
legend(ph_axes,"Saturation Dome","Compressor","Condenser","Expansion Valve","Evaporator",Location="northwest");

%Plot and label P-h corner points
ph_points_plot = zeros(4,1);
for i=1:4
    ph_points_plot(i) = plot(ph_axes,ph_corners(i,2),ph_corners(i,1),"k.","HandleVisibility","off");
    text(ph_axes,ph_corners(i,2),ph_corners(i,1)+120000,num2str(i));
end

%FUNCTIONS DEVELOPED TO HELP WITH THE ASSIGNMENT

%function [y_vals,x_vals,sEnd] = ts_isENTH(t_start,s_start,t_end,num_pts,fluid)
    %Similar to ph_isENTR function this takes the known fact that the
    %enthalpy remains constant then iterates to find the ending s value to
    %get a point on the t-s diagram.

    %calculate enthalpy values
%    enthalpy = CoolProp.PropsSI('H','T',t_start,'S',s_start,fluid);

    %Init output points and lists
%    y_vals = linspace(t_start,t_end,num_pts);
%    x_vals = zeros(1,num_pts);

    %Find the s values
%    for i = 1:num_pts
%        p = CoolProp.PropsSI('P','T',y_vals(i),'Q',0,fluid);
%        x_vals(i) = CoolProp.PropsSI('S','P',p,'H',enthalpy,fluid);
%    end
%    sEnd = x_vals(num_pts);
%end

%function [y_values,x_values,t_low,t_high] = Ts_isobar(pressure,num_pts,s_low,s_high,end_state,fluid)
    %Finding the points of the isobars on a T-s diagram. Using conditions
    %to make sure that the points output are proper for whether they exist
    %within the vapor dome or outside the vapor dome. Then giving the
    %outputs in the form of points that can be plotted in the T-s diagram.

  %  dome_s_rng = [CoolProp.PropsSI('S','P',pressure,'Q',0,fluid), CoolProp.PropsSI('S','P',pressure,'Q',1,fluid)];
  %  tin_Dome = CoolProp.PropsSI('T','P',pressure,'Q',0,fluid);

    %end_state input
  %  if (end_state == 'B')
  %      s_low = dome_s_rng(1);
  %      s_high = dome_s_rng(2);
  %  else
  %      if (end_state == 'L')
  %          s_low = dome_s_rng(1);
  %      end
  %      if (end_state == 'R')
  %          s_high = dome_s_rng(2);
  %      end
  %  end

    %Figure out if the provided s_low value is in or out of dome range
  % if (s_low >= dome_s_rng(1))
        %if inside the dome this becomes the left endpoint, and there is no
        %line in the liquid region
  %      liquid_s_pts = [];
  %      liquid_t_pts = [];
  %      dome_s_rng(1) = s_low;
  %      t_low = tin_Dome;
  %  else
        %if the value is outside the saturation dome... provide a line in
        %the liquid region
  %      t_low = CoolProp.PropsSI('T','P',pressure,'S',s_low,fluid);
  %      liquid_s_pts = zeros(1,num_pts);
  %      liquid_t_pts = linspace(t_low,tin_Dome-.01,num_pts);
  %      for i =1:num_pts
  %         liquid_s_pts(i) = CoolProp.PropsSI('S','T',liquid_t_pts(i),'P',pressure,fluid);
  %      end
  %  end

    %Figure out if provided s_high value is in or out of the dome range
  %  if (s_high <= dome_s_rng(2))
        %if inside the dome, same thing as above just make it the right
        %endpoint with no vapor area line
  %      vap_s_pts = [];
  %      vap_t_pts = [];
  %      dome_s_rng(2) = s_high;
  %      t_high = tin_Dome;
  %  else
        %if outside, do the line in the vapor area this time
  %     t_high = CoolProp.PropsSI('T','P',pressure,'S',s_high,fluid);
  %      vap_s_pts = zeros(1,num_pts);
  %      vap_t_pts = linspace(tin_Dome+.01,t_high,num_pts); %changed from 'zeros(1,num_pts)' after consulting Claude on error message *This edit was NOT generated by Claude*. More discussion in the attached document.
  %      for i=1:num_pts
  %          vap_s_pts(i) = CoolProp.PropsSI('S','T',vap_t_pts(i),'P',pressure,fluid);
  %      end
  %  end

    %Final output
  %  y_values = [liquid_t_pts,tin_Dome,tin_Dome,vap_t_pts];
  %  x_values = [liquid_s_pts,dome_s_rng,vap_s_pts];
%end

%function [y_vals,x_vals,h_end] = ph_isENTR(p_init,h_init,p_end,num_pts,fluid)
    %A function to get the isentrope values for the Ph Diagram. Takes in
    %the known values in terms of initial and final pressures, and the
    %initial enthalpy to find the entropy at the start, then goes and
    %iterates across a range to get the ending enthalpy based off the found entropy being constant.

    %Find entropy value
%    entropy = CoolProp.PropsSI('S','P',p_init,'H',h_init,fluid);

    %Generate outputs
%    y_vals = linspace(p_init,p_end,num_pts);
%    x_vals = zeros(1,num_pts);

    %find h values
%   for i=1:num_pts
%        x_vals(i) = CoolProp.PropsSI('H','P',y_vals(i),'S',entropy,fluid);
%    end
%    h_end = x_vals(num_pts);
%end

%function [y_vals, x_vals] = GenDome(y_param,x_param,num_pts,fluid)
    %GenDome gets the values for a saturation/vapor dome based off of the
    %fluid and desired inputs in the x and y parameter slots. As long as
    %any two thermodynamic properties are known these values can be found.

    %Gen Y values as a list
%    t_rng = [CoolProp.Props1SI([char(y_param),'MIN'],char(fluid)),CoolProp.Props1SI([char(y_param),'CRIT'],char(fluid))];
%    y_vals = [linspace(t_rng(1),t_rng(2),num_pts),flip(linspace(t_rng(1),t_rng(2),num_pts))];

    %Create q values in a logical matrix, zeros and ones in the first and
    %second halves respectively.
%    q_logic = zeros(1,2*num_pts);
%    q_logic(1:num_pts) = ~q_logic(1:num_pts);

    %X vlaues generation
%    x_vals = zeros(1,num_pts);
%    for i=1:num_pts*2
%        x_vals(i) = CoolProp.PropsSI(char(x_param),char(y_param),y_vals(i),'Q',q_logic(i),char(fluid));
%    end
%end
