classdef AnSHearTensile < Analysis
    %ANSHEARTENSILE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = AnSHearTensile(inputArg1,inputArg2)
            obj@Analysis;
        end
        
        function GiveData(obj,data)
            HitCount;
            HitDuration;
            RiseTime;
            HitAmplitude;
            
            AvgFreq=HitCount./HitDuration.*1e-9;
            RAVal=RiseTime./HitAmplitude.*1e-7;
            
            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

