classdef VarSpecConcept < Item
    %VARSPECCONCEPT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = VarSpecConcept(parent)
            obj.Parent=parent;
            %VARSPECCONCEPT Construct an instance of this class

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

