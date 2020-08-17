classdef CurveData < Meas
    %CURVEDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Array (:,5) double;
        Units (1,5) char;
        ColNames (1,5) char;
    end
    
    properties (Dependent)
        Freq (1,1) double;
        Period (1,1) double;
        Samples (1,1) double;
        RelativeStartTime (1,1) double;
        RelativeEndTime (1,1) double;
    end
    
    
    methods
        function obj = CurveData(inputArg1,inputArg2)
            obj@Meas(filename,opt)
            %CURVEDATA Construct an instance of this class
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

