classdef PEVar < handle
    %PEVAR will store sdresses to specific variables of stored data, and
    %do opeations such as data fabrication, interpolation at so on
    %Pevar will also pick data from complex data types such as Zedo, and
    %store only nessesary data for plot creation
    
    %it has to have ability to check talk to others pevars from point of
    %view of events
    %   Detailed explanation goes here
    
    properties
        InData;
        Parent; %general plot
        OutData;
    end
    
    events
        CheckCompatibility;
    end
    
    methods
        function obj = PEVar(InData,Parent)
            obj.Parent=Parent;
            obj.InData=InData;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

