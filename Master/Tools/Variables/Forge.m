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
        
        function ListOperators(obj)
            
        end
        
        function AddOperator(obj,variable,id)
            
        end
    end
    
        methods %abstract
            function DrawGui(obj)
                ClearGUI(obj);
                g=uigridlayout(obj.Fig);
                g.RowHeight = {25,'1x'};
                g.ColumnWidth = {80,'1x',25};
                
                lbox = uilistbox(g);
                lbox.Layout.Row=[1 2];
                lbox.Layout.Column=1;
                
                p=uipanel(g,'Title','Operation');
                p.Layout.Row=2;
                p.Layout.Column=[2 3];
            end
        
        
            function stash=Pack(obj)
            end
            
            function Populate(obj)
            end
        end
end

