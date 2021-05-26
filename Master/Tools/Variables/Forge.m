classdef Forge < Item
    %FORGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Variables;
    end
    
    methods
        function obj = Forge(~)

        end
        
        function Operations(obj)
            InterCat={'1D Interpolation','2D Interpolation'};
            ArrCat={'Normalize','Limit'};
            TimeCat={'ToNumber','ToTime','Reduce to start time'};
        end
        
        function list=ListOperators(obj)
            list={'Adress','ConCat','Inter'};
        end
        
        function AddVariable(obj,var)
            newSmith=VarSmith;
            SetParent(newSmith,obj);
            row=GetEmptyVariable(obj);
        end
        
        function AddOperator(obj,variable,id)
            
        end
        
        function row=GetEmptyVariable(obj)
            row=table([],[],[],[],[]);
            row.Properties.VariableNames={'ID','Name','Coord','Size','Type'};
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
%                 but1.Icon=IconFilePlus;

                p=uipanel(g,'Title','Operation');
                p.Layout.Row=2;
                p.Layout.Column=[3 4];
            end
        
        
            function stash=Pack(obj)
            end
            
            function Populate(obj)
            end
        end
end

