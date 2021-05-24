classdef Forge < handle
    %FORGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Adress;
        Input;
        Size;
        DoList;
        Output;
    end
    
    methods
        function obj = Forge(parent)
%             obj.Parent=parent;
        end
        
        function Operations(obj)
            InterCat={'1D Interpolation','2D Interpolation'};
            ArrCat={'Normalize','Limit'};
            TimeCat={'ToNumber','ToTime','Reduce to start time'};
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

