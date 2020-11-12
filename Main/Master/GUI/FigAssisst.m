classdef FigAssisst < handle
    %FIGASSISST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Lines;
        Thick;
        Marker;
        Line;
        Axes;
        Figure;
        Data;
        D3Plot logical;
        Y2Axis logical;
    end
    
    methods
        function obj = FigAssisst(Struct)
            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

