classdef PlotPropConcept < Item
    %PLOTPROPCONCEPT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = PlotPropConcept(parent)
            obj.Parent=parent;

        end

    end
    
            
    methods %abstract
        function DrawGui(obj)
            ClearGUI(obj);
            g=uigridlayout(obj.Fig(1));

        end
        
        function stash=Pack(obj) 
            
        end
        
        function Populate(obj,stash) 
            
        end
    end
end
