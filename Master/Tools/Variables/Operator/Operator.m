classdef Operator < NumOper & Item
    %VARCONCEPT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        Adress table;
        Name char; %class name
        Title char; %civil name
%         Type;
%         Operations;
        Input;
        Output;
        
        Children;
        ChildrenBool=0;
        First=0;
    end
    
    methods (Abstract)
        RunTool(obj);
    end
    
    methods
        function obj = Operator(~)
            obj@NumOper;
            obj@Item;
%             obj.Parent=parent;
            

        end
        
        function SetParent(obj,parent)
            obj.Parent=parent;
            if strcmp(class(obj.Parent),'VarSmith')
                obj.First=1;
            end
        end
        
        function Run(obj)
            RunTool(obj);
            if obj.ChildrenBool==1
                Run(obj.Children);
            end
        end
        
        function ChAddOperator(obj)
            if obj.First==1
                AddOperator(obj.Parent,obj);
            else
                ChAddOperator(obj.Parent);
            end
        end
        
        function AddChildren(obj,children)
            obj.ChildrenBool=1;
            obj.Children=children;
            AssociateParent(obj.Children,obj);
        end
        
        function stash=OpPack(obj)
            stash=struct;
            stash.Name=obj.Name;
            stash.Title=obj.Title;
            
            TMP=Pack(obj);
            stash.Spec=TMP;
        end
        
        function OpPopulate(obj,stash)
            obj.Name=stash.Name;
            obj.Title=stash.Title;
            
            Populate(obj,stash.Spec);
        end
    end
end


