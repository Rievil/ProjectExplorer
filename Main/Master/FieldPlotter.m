classdef FieldPlotter < handle
    %FIELDPLOTTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data;
    end
    
    methods
        function obj = FieldPlotter(Data)
            obj.Data=Data;
            PlotBasic(obj);
        end
        
    end
    
    methods %Plotting methods
        function PlotBasic(obj)
            for i=1:size(obj.Data,1)
                M=obj.Data.Zedo(i);
                Out=GetParams(M);
            end
        end
    end
end

