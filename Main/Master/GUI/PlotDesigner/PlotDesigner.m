classdef PlotDesigner
    %Maste soubor pro vsechny ostatn� okna pro editaci a n�vrh graf�.
    %Struktura je zalo�en� na tom, �e poprv� jak se nahraje data z
    %dataloadru do design�ra, tak by m�lo b�t mo�n� nastvit jak� jsou
    %popisov� prom�nn� jednotliv�ch m��en�
    
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

