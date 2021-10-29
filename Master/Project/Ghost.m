classdef Ghost < Node
    %GHOST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = Ghost(Entry,Parent)
            %GHOST Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
    end
    
    %abstact methods
    methods 
        function FillUITab(obj,Tab)
        end
        
        function FillNode(obj)
        end
        
        function stash=Pack(obj)
        end
        
        function node=AddNode(obj)
        end
        
        function Populate(obj)
        end
    end
end

