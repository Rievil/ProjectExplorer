classdef Specimen < handle
    %SPECIMEN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ID;
        KeyName;
        Properties;
        DataTypes;
        MeasurementDate;
    end
    
    
    methods
        function obj = Specimen(parent) %parent je experiment
            %SPECIMEN Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        
        function stash=Pack(obj)
            
        end
    end
end
