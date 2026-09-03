% Thermal Systems HW 1
% A script by Nicholas Fischer | 08/31/2026

%Setup and Assumptions:

%Environmental Parameters -
%These will influence the factor I will call 'k' in the T_L equation. This
%aims to establish the properties of the room that the engine runs in and
%how well it ventelates any heat given off to the environment by the
%engine.

k = .05; 

%This takes into account the ventilation, and size of the room as well as the density of the air in the room where the engine is running.
%This is done to have more control over the T_L equation given the room
%(right now is a hardcoded value, could be an equation in future iterations).

T_H = linspace(300, 1500, 1000);
%This 'T_H' setup allows for an operating range of about 29 C to 1227 C
%which is a typical range for a veriety of combustion engines that also explores extremes.

T_L = 293.15 + k.*T_H; 
%Version 1: 'T_L = 293.15' This assumes an environment temperature of room temperature in celcius (20 C).

%Version 2: allows for T_L to be a function that varies as T_H increases
%as the consistent running of the engine affects the temperature in the
%room even if ventilation is present (small factor of .05 considered
%first).

eta_T = 1 - T_L./T_H;
%This builds the equation we wish to plot based of the Carnot efficiency
%equation for theoretical efficiencies.

eta_TP = (eta_T)*100;
%This second version takes the teperature related efficiency and converts
%to a percentage.

%Actually plot the thing:
figure();
plot3(T_H, T_L , eta_TP, 'LineWidth', 2); %plot3 allows 3D plotting.
xlabel('Operating Temperature (K)');
ylabel('Environment Temperature (K)');
zlabel('Efficiency (%)');

%Limits for axes
xlim([min(T_H), max(T_H)]);
ylim([293.15, max(T_L)]);
zlim([0 100]);

%Legend adapted and utilized from ClaudeAI.
legend({'Carnot limit: \eta = 1 - T_L/T_H'}, 'Location', 'northeast', 'FontSize', 12);

%Title
title('Theoretical Maximum Heat Engine Efficiency');
grid on;