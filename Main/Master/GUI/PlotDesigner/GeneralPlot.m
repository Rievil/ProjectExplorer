classdef GeneralPlot
    %GENERALPLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PlotPlan; %table with have its plot order, general options, legends, data sources
        Property1
        Parent; %PlotDesigner
    end
    
    methods
        function obj = GeneralPlot(inputArg1,inputArg2)
            %GENERALPLOT Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

