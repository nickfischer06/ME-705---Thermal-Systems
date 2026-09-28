%Thermal Systems Analysis and Design
%ME 705 HW 3 |09/23/26
%Nicholas Fischer

%Import CoolProp into the script.
addpath("..\..\Extracted_CoolProp\ThermoTablesCoolProp_v6_1_0\")
%Note: no add path for XSteam because it is a function and exists in the
%direcotry with the script so it can be freely called.

%Problem 1: T - U diagram using XSteam

%Hard coded parameters and inputs (Q1)
tIter = 1000; %number of temperature points to observe
isoPress = 7; % Bar (about 7 times atmospheric pressure)
isoTemp = 150; % degrees C

T_dome = linspace(0,373.874,tIter); %373.874 was expirimentally ditermined number

%U values for the dome line
UdomeF = zeros(1,tIter);
UdomeG = zeros(1,tIter);

for i = 1:tIter
    UdomeF(i) = XSteam('uL_T', T_dome(i));
    UdomeG(i) = XSteam('uV_T', T_dome(i));
end

%Isobar portion
%Temperature values on isobar
IsobarDomeTemp = XSteam('Tsat_p', isoPress);
isobarTemps = zeros(1,tIter);

%Internal energy values on isobar
%Because pressure remains constant throughout the saturation dome this
%allows to section the isobar line around that for accurate representation.
%There will be three sections that will comprise the isobar line
uisoBar = zeros(1,tIter);
SectIndex = [round(tIter/2)-1, round(tIter/2)]; %Sections Isobar graph so that it will look proper through the saturation region
isobarTemps(1:SectIndex(1)) = linspace(0,IsobarDomeTemp,SectIndex(1));
isobarTemps(SectIndex(2):tIter) = linspace(IsobarDomeTemp, 500, SectIndex(2)+1);

%Solving for the isobar in each region (liquid, mixture, and vapor)
for k = 1:SectIndex(1)-1
    uisoBar(k) = XSteam('u_pT',isoPress,isobarTemps(k));
end
uisoBar(SectIndex(1)) = XSteam('uL_T',isobarTemps(SectIndex(1)));
uisoBar(SectIndex(2)) = XSteam('uV_T',isobarTemps(SectIndex(2)));
for k = SectIndex(2)+1:tIter
    uisoBar(k) = XSteam('u_pT',isoPress,isobarTemps(k));
end

%Initializing Figure 1
figQ1 = figure("Name", "Homework 3: Q1");
axes1 = axes(figQ1, "XLim", [0,4000], "YLim", [0, 500], "NextPlot","add");
xlabel(axes1, "Specific Internal Energy (kJ/kg)");
ylabel(axes1, "Temperature (deg C)");
title("Temperature - Specific Internal Energy Diagram for Water");

%Clean up NaN Data points
%This computation eliminates any potential NaN values in the creation of
%the saturation dome.
cleanPts = ~(isnan(UdomeF) | isnan(UdomeG));
UdomeF = UdomeF(cleanPts);
UdomeG = UdomeG(cleanPts);
T_dome = T_dome(cleanPts);

%Saturation Dome Plotting
SatWatLine = plot(axes1, UdomeF, T_dome, "Color", [0,.5,.755], "LineWidth", 1.0, "HandleVisibility","on");
SatVapLine = plot(axes1, UdomeG, T_dome, "Color", [0,.5,.755], "LineWidth", 1.0, "HandleVisibility","off");

%Plot isobar
IsoBar = plot(axes1, uisoBar, isobarTemps,"Color", [.1,.76,.1], "LineWidth", 2);

%Plot isotherm
IsoTherm = plot(axes1, [0,4000], [isoTemp,isoTemp],"Color", [.95,.15,.1],"LineWidth", 2);

%Add Legend
legnd1 = legend(axes1, "Saturation Dome", append("Isobar at P = ",num2str(isoPress), " Bar"), ...
    append("Isotherm at T = ",num2str(isoTemp), " degrees celcius"), location="northwest");

%Additional notes on question 1:
%Chose the number of points for graph resolution.
%Chose pressure and temperature to observe.
%Used XSteam to determine T-u values along saturation dome as well as for
%the isobar and the isotherm (horizontal line).
%Plotted all features and added appropriate labels as needed.

%Problem 2: Using CoolProp to make a P-h diagram for any refrigerant
%Refrigerant of my choice: R32 - Difluoromethane (CH2F2)

%Clear prev vars
clear;

%Hardcoded parameters and inputs (Q2)
pIter = 1000; %number of pressure values to iterate on
isoTemp2 = 296.79; %degrees celcius
isentrope = 2000000; %Pressure of isentrope line (Pa)

%Pressure values for saturation curve
PresDome = linspace(11800,5782000,pIter); %Saturation dome pressure bounds (Pa) for R-32

%Enthalpy values for saturation curve
%Initiate the vectors to plot over
hDomeF = zeros(1,pIter);
hDomeG = zeros(1,pIter);

%Create the enthalpy values to plot for the saturation dome
for j = 1:pIter
    hDomeF(j) = CoolProp.PropsSI('H','P',PresDome(j),'Q',0,'R32');
    hDomeG(j) = CoolProp.PropsSI('H','P',PresDome(j),'Q',1,'R32');
end

%Pressure values on the isotherm
%similar to question one this sectioning allows for the isotherm line to be
%split into appropriate sctions through the saturation dome.
isoTHERMdomePres = CoolProp.PropsSI('P','T',isoTemp2,'Q',0,'R32');
SectIndex2 = [round(pIter/2)-1, round(pIter/2)];
isoTHERMPres = zeros(1,pIter);
isoTHERMPres(1:SectIndex2(1)) = linspace(10000,isoTHERMdomePres,SectIndex2(1));
isoTHERMPres(SectIndex2(1)+1:pIter) = linspace(isoTHERMdomePres,5800000,SectIndex2(2)+1);

%Enthalpy values on the isotherm
hisoTHERM = zeros(1,pIter);

for l = 1:SectIndex2(1)-1
    hisoTHERM(l) = CoolProp.PropsSI('H','P',isoTHERMPres(l),'T',isoTemp2,'R32');
end

hisoTHERM(SectIndex2(1)) = CoolProp.PropsSI('H','P',isoTHERMPres(l),'Q',0,'R32');
hisoTHERM(SectIndex2(2)) = CoolProp.PropsSI('H','P',isoTHERMPres(l),'Q',0,'R32');

for l = SectIndex2(2)+1:pIter
    hisoTHERM(l) = CoolProp.PropsSI('H','P',isoTHERMPres(l),'T',isoTemp2,'R32');
end

%Pressure values for isentrope
pisENTROPE = linspace(isentrope,5800000,pIter);

%Entropy at isentrope pressure
%Start the isentrope line when Q = 1
h0 = CoolProp.PropsSI('H','P',isentrope,'Q',1,'R32');
isENTROP_S = CoolProp.PropsSI('S','P',isentrope,'H',h0,'R32');

%Enthapy values for isentrope
hisENTROPE = zeros(1,pIter);

for m = 1:pIter
    hisENTROPE(m) = CoolProp.PropsSI('H','P',pisENTROPE(m),'S',isENTROP_S,'R32');
end

%Initializing figure 2
figQ2 = figure("Name", "Homework 3: Q2");
axes2 = axes(figQ2, "XLim", [0, 700000], "YLim", [0, 6000000], "NextPlot", "add");
xlabel(axes2, "Specific Enthalpy (J/kg)");
ylabel(axes2, "Pressure (Pa)");
title("Pressure - Enthalpy Diagram for R32");

%Clean up dome values
cleanPts2 = ~(isnan(hDomeF) | isnan(hDomeG));
hDomeF = hDomeF(cleanPts2);
hDomeG = hDomeG(cleanPts2);
PresDome = PresDome(cleanPts2);

%Saturation Dome Plotting
sat_lineL = plot(axes2,hDomeF,PresDome,"Color",[.1,.76,.1], "LineWidth", 1.0, "HandleVisibility","on");
sat_lineR = plot(axes2,hDomeG,PresDome,"Color",[.1,.76,.1],"LineWidth", 1.0, "HandleVisibility","off");

%Shade Saturation Dome Region
fillA = fill([hDomeG,flip(hDomeF)], [PresDome,flip(PresDome)],[.97,.1,.5],"FaceAlpha",.25,"LineStyle","-","HandleVisibility","off");

%Isotherm Plotting
isotherm2 = plot(axes2,hisoTHERM,isoTHERMPres,"Color",[.95,.15,.1],"LineWidth",2.0, "HandleVisibility", "on");

%Isentrope line
isentrope = plot(axes2,hisENTROPE,pisENTROPE,"Color",[.4,.62,.1], "LineWidth",2.0, "HandleVisibility", "on");

%Legend for P-h diagram
legnd2 = legend(axes2, "Saturation Dome", append("Istherm at T = ",num2str(isoTemp2), " degrees celcius"), ...
    append("Isentrope at S = ",num2str(isENTROP_S), " kJ/kgK"), location="northwest");

%Additional Notes on problem 2:
%Similar problem solving steps used: initialized isotherm and isentrope
%values and then built plot to display.
%Sectioned off the isotherm seeing as it behaves similar to the isobar on
%the T-u diagram from question one.
%Instead of using XSteam, Cool Prop was used allowing the evaluation of
%refridgerant R32.
%Plot was constructed and properly labeled to show all features.
%Points were cleaned on the saturation dome just as a precaution again to
%avoid errors and provide clean values.
