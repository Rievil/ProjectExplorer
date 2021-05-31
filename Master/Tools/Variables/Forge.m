classdef Forge < Item
    %FORGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Variables (1,:);
        Count;
        UIList;
%         T;
        VarPanel;
    end
    
    properties (Dependent)
        VarList;
    end
    
    methods
        function obj = Forge(~)
            obj@Item;

        end
        
        function Operations(obj)
            InterCat={'1D Interpolation','2D Interpolation'};
            ArrCat={'Normalize','Limit'};
            TimeCat={'ToNumber','ToTime','Reduce to start time'};
        end
        
        function list=ListOperators(obj)
            list={'Adress','ConCat','Inter'};
        end
        
        function AddVariable(obj)
            Smith=VarSmith(obj);
            obj.Variables=[obj.Variables, Smith];
            obj.Count=numel(obj.Variables);
            

%             row=GetEmptyVariable(obj);
%             row.ID(1)=Smith.ID;
%             row.Name(1)=sprintf('Variable %d',row.ID(1));
%             row.Index(1)=false;
%             
%             obj.T=[obj.T; row];
%             
%             obj.UITable.Data=obj.T;
%             obj.Count=numel(obj.Variables);
%             row=GetEmptyVariable(obj);
        end
        
        
        function row=GetEmptyVariable(obj)
            num=zeros(1,1);
            name=strings(1,1);
            bool=logical(zeros(1,1));
            
            row=table(num,name,bool,'VariableNames',{'ID','Name','Index'});
%             row.Properties.VariableNames={'ID','Name','Index'};
        end
        
        function list=get.VarList(obj)
            list=strings(obj.Count,1);
            for i=1:obj.Count
                list(i,1)=obj.Variables(i).Name;
            end
        end
        
        function FillList(obj)
            obj.UIList.Items=obj.VarList;
            obj.UIList.ItemsData=1:1:obj.Count;
        end
    end
    
        methods %abstract
            function DrawGui(obj)
                ClearGUI(obj);
                g=uigridlayout(obj.Fig);
                g.RowHeight = {25,'1x'};
                g.ColumnWidth = {60,60,'1x',25};
                
                lbox = uilistbox(g);
                lbox.Layout.Row=2;
                lbox.Layout.Column=[1 2];
                
                but1=uibutton(g,'Text','New operator');
            
                but1.Layout.Row=1;
                but1.Layout.Column=1;

                p=uipanel(g,'Title','Operation');
                p.Layout.Row=2;
                p.Layout.Column=[3 4];
            end
        
        
            function stash=Pack(obj)
                stash=struct;
                stash.Count=obj.Count;
                n=0;
                for VS=obj.Variables
                    n=n+1;
                    TMP=Pack(VS);  
                    stash.Variables(n)=TMP;
                end
            end
            
            function Populate(obj,stash)
                obj.Count=stash.Count;
                for i=1:obj.Count
                    Smith=VarSmith(obj);
                    Smith.Populate(stash.Variables(i));
                    obj.Variables=[obj.Variables, Smith];
                end
            end
        end
end


