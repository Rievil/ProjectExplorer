classdef PlotPlot < PlotObj
    %PLOTPLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = PlotPlot(parent)
            obj@PlotObj(parent);
            obj.Name='PlotPlot';

        end
        
    end
    
    methods %abstract
        function CoPack(obj)

        end
        
        function CoPopulate(obj,stash)

            
        end
    end
end

