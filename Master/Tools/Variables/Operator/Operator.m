classdef Operator < NumOper & Item
    %VARCONCEPT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        
        Name char; %class name
        Title char; %civil name
        Description cell;
        
        Input;
        Output;
        
        Children;
        ChildrenBool=0;
        First=0;
        VarSmith;
        Labels;
    end


    
    methods (Abstract)
        RunTool(obj);
    end
    
    methods
        function obj = Operator(~)
            obj@NumOper;
            obj@Item;
        end
        

        
        function SetParent(obj,parent)
            obj.Parent=parent;
            if strcmp(class(obj.Parent),'VarSmith')
                obj.First=1;
            end
        end
        
        function list=GetVarList(obj)
            obj2=obj;
            name=class(obj2);
            while ~strcmp(name,'OPVarTake')
                obj2=obj2.Parent;
                name=class(obj2);
            end
            list=obj2.VarList;%
        end
        
        function RunCh(obj,data)
            RunTool(obj,data);
            if obj.ChildrenBool==1
                RunCh(obj.Children,obj.Output);
            end
        end
        
        function ChAddOperator(obj,obj2)
            if obj.First==1
                AddOperator(obj.Parent,obj2);
            else
                ChAddOperator(obj.Parent,obj2);
            end
        end
        
        function OpDrawGui(obj)
%             function 
            ClearGUI(obj);
            DrawGui(obj);
        end
        
        function obj2=GetInspector(obj)
            obj2=OperLib.FindProp(obj.VarSmith,'Inspector');
            obj2.CurrDialog=obj;
        end
        
        function obj2=GetVarExp(obj)
            obj2=OperLib.FindProp(obj.VarSmith,'VarExp');
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


