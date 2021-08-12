classdef ConCat < VarOperator
    %CONCAT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = ConCat(~)

        end
        
    end
    
    methods %abstract
        
        function DrawGui(obj)
        end
        
        function RunTool(obj)
        end
        
        function stash=Pack(obj)
        end
        
        function Populate(obj)
        end
    end
end

