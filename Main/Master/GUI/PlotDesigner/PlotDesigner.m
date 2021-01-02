classdef PlotDesigner
    %Maste soubor pro vsechny ostatní okna pro editaci a návrh grafù.
    %Struktura je založená na tom, že poprvé jak se nahraje data z
    %dataloadru do designéra, tak by mìlo být možné nastvit jaké jsou
    %popisové promìnné jednotlivých mìøení
    
    properties
        Property1
    end
    
    methods
        %konstruktor
        function obj = PlotDesigner(inputArg1,inputArg2)

        end
        
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

