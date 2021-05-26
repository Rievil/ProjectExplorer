classdef VarSmith < Item
    %SMITH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Operators;
    end
    
    methods
        function obj = VarSmith(~)

        end
        
        function AddOperator(obj,id)
            
        end
    end
    
    methods %abstract
        function DrawGui(obj)
        end
        
        function stash=Pack(obj) 
        end
        
        function Populate(obj) 
        end
    end
end

