classdef VarSmith < Item
    %SMITH Summary of this class goes here
    %   Detailed explanation goes here
    %'ID','Name','Coord','Size','Type'
    
    properties
        Operators;
        ID;
        Name (1,1) string;
        Coord;
        Size;
        Type;
    end
    
    methods
        function obj = VarSmith(parent)
            obj.Parent=parent;
            obj.ID=numel(obj.Parent.Variables)+1;
            obj.Name=sprintf('Variable %d',obj.ID);
        end
        
        function AddOperator(obj,id)
            
        end
    end
    
    methods %abstract
        function DrawGui(obj)
        end
        
        function stash=Pack(obj) 
            stash=struct;
            stash.ID=obj.ID;
            stash.Name=obj.Name;
        end
        
        function Populate(obj,stash) 
            obj.ID=stash.ID;
            obj.Name=stash.Name;
        end
    end
end

