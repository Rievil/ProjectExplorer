classdef Meas < handle
    properties
        DateOfMeasurement datetime;
        BruteFolder char;
        Filename char;
        IsExcel logical;
        Sheet double;
        ColStart double;
    end
    
    methods
        function obj = Meas(filename)
            %MEAS Construct an instance of this class
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

