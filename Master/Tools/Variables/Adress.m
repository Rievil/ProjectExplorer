classdef Adress < VarOperator
    %ADRESS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Inspector;
        AdressList table;
        Count;
    end
    
    methods
        function obj = Adress(~)
        end
        
        function SetInspector(obj,ins)
            obj.Inspector=ins;
        end
        
        function AddAdress(obj,T)
            obj.AdressList=[obj.AdressList; T];
            obj.Count=size(obj.AdressList,1);
        end
        
        function GetVar(obj)
            for i=1:obj.Count
                [A,name]=GetVar(obj.Inspector,ID);
                obj.Out{i,1}=A;
                obj.Out{i,2}=name;
            end
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


