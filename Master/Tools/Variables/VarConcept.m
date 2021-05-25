classdef VarConcept < NumOper & Item
    %VARCONCEPT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        Adress table;
        Name char;
%         Type;
%         Operations;
        Input;
        Output;
        
        Children;
        ChildrenBool=0;
    end
    
    methods (Abstract)
        RunTool(obj);
    end
    
    methods
        function obj = VarConcept(~)
            obj@NumOper;
            obj@Item;
        end
        
        function Run(obj)
            RunTool(obj);
            if obj.ChildrenBool==1
                Run(obj.Children);
            end
        end
        
        
        function AddChildren(obj,children)
            obj.ChildrenBool=1;
            obj.Children=children;
            AssociateParent(obj.Children,obj);
        end
    end
end

