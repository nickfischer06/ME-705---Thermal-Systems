function zones = load_inputs(file)
    %Table parsing
    Table = readtable(file, "Sheet", "geometry","VariableNamingRule","preserve");
    names = matlab.lang.makeValidName(string(Table{:,1}));
    zoneNames = Table.Properties.VariableNames(3:end);

    %R value layering: one R value per layer then summed up per zone and
    %surface
    Lyr = readtable(file, "Sheet", "layers", "TextType", "string", "VariableNamingRule", "preserve");
    Rl = Lyr.Thickness_m ./ Lyr.k_WmK; %Conduction layers
    fx = isnan(Rl);
    Rl(fx) =Lyr.R_fixed(fx);
    if any(isnan(Rl))
        error("Layers sheet: row(s) %s have neither thickness nor R_fixed values", mat2str(find(isnan(Rl)).'));
    end

    surfaces = ["wall","roof","floor","window"];

    for i = 1:numel(zoneNames)
        z = char(zoneNames(i));
        p = cell2struct(num2cell(double(Table.(z))), cellstr(names), 1);

        if isnan(p.V) 
            p.V = p.L*p.W*p.H;
        end
        
        geometry = struct('L',p.L,'W',p.W,'H',p.H,'V',p.V,'Awindow',p.Awindow);

        Rmats = struct();
        for s = surfaces
            Rs = sum(Rl(Lyr.Zone == z & Lyr.Surface == s));
            if Rs == 0
                error("No layers found for zone '%s', surface '%s'.",z,s);
            end
            Rmats.(s) = Rs;
        end

        zones.(matlab.lang.makeValidName(z)) = struct('geometry',geometry,'Rmats',Rmats,'Hi',p.Hi,'Air_infil',p.Air_infil,'kWind',p.kWind,'numOcc',p.numOcc,'Qperson',p.Qperson);
    end
end

