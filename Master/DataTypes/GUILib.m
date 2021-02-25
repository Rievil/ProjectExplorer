classdef GUILib < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
        GuiParent;
        Count=0;
        Children;
        TypeSet;
        Init;
        Pos;
    end
    
    %interface
    methods (Abstract)
        InitializeOption(obj);
        PlotType(obj);
    end
    
    methods (Access = public)
        
        %will draw options for current data type
        function DrawTypeOption(obj)
            if obj.Init
                InitializeOption(obj);
                CheckOptions(obj);
            else
                InitializeOption(obj);
            end
            
            if numel(obj.Children)>0
                GuiInit(obj);
            end
        end
        
        function T=GetTypeSpec(obj)
            T=obj.TypeSet{1, 1};  
        end
        
        function obj=GUILib(~)
            obj.Init=false;
        end
        
        
        function SetGuiParent(obj,Parent)
            obj.GuiParent=Parent;
        end
        
        function NewRow(obj)
            obj.Count=obj.Count+1;
        end

    end
    
    %methods for drawing of options in plotter object
    methods (Access = public)
    end
    
    %methods for drawing gui for options in typetable settings
    methods (Access = public) 
        
        %clear GUI COntainer
        function Clear(obj)
            obj.Count=0;
            delete(obj.GuiParent.Children);
            if numel(obj.Children)>0
                for i=1:numel(obj.Children)
                delete(obj.Children{i});
                end
                obj.Children=[];
            end
            obj.Pos=[10,obj.GuiParent.InnerPosition(4),obj.GuiParent.InnerPosition(3),20];
        end
        
        %Init of GUI per children
        function GuiInit(obj)
            %obj.Count=0;
            obj.Init=true;
        end
        
        %------------------------------------------------------------------
        %dropdown
        function han=DrawDropDownMenu(obj,Items,Key)
            obj.Count=obj.Count+1;
            %obj.Pos=obj.GuiParent.InnerPosition;
            
            yP=obj.Pos(2)-20-(obj.Count*20);
            Pos=[10,yP,120,20];
            obj.Pos(2)=yP;
            
            han=uidropdown(obj.GuiParent,'Items',Items,...
                     'Value',Items{1},'Position',Pos,...
                     'UserData',{Key, obj.Count},...
                     'ValueChangedFcn',@(src,event)DropDownChange(obj,event));   
             if ~obj.Init
                Key(obj,Items{1},obj.Count);
             end
             obj.Children{obj.Count}=han;
        end

        %dropdown callback
        function DropDownChange(obj,event)
            event.Source.UserData{1}(obj,event.Source.Value,event.Source.UserData{2});
        end
        %------------------------------------------------------------------
        %spinner
        function han=DrawSpinner(obj,Limits,Target,Key)
            
            obj.Count=obj.Count+1;
            yP=obj.Pos(2)-(obj.Count*20);
            Pos=[10,yP,120,20];
            obj.Pos(2)=yP;
            
            han=uispinner(obj.GuiParent,'Limits',Limits,...
                     'Visible','off',...
                     'Value',Limits(1),'Position',Pos,...
                     'UserData',{Key, obj.Count,Target},...
                     'ValueChangedFcn',@(src,event)SpinnerChange(obj,event));   
             if ~obj.Init
                Key(obj,han.Value,obj.Count,Target);
             end
             obj.Children{obj.Count}=han;
             han.Visible='on';
        end
        %spinner callback
        function SpinnerChange(obj,event)
            event.Source.UserData{1}(obj,event.Source.Value,...
                event.Source.UserData{2},...
                event.Source.UserData{3});
        end
        
        %------------------------------------------------------------------
        %uitable
        function han=DrawUITable(obj,Data,Key)
            obj.Count=obj.Count+1;
            %Pos=obj.GuiParent.InnerPosition;
            
            yP=obj.Pos(2)-300-(obj.Count*20);
            Pos=[10,yP,obj.Pos(3)-15,300];
            obj.Pos(2)=yP;
            
            %Pos=[10,Pos(4)-200-(obj.Count*23),Pos(3)-15,180];
            
            han=uitable(obj.GuiParent,'Data',Data,...
                     'Position',Pos,...
                     'UserData',{Key, obj.Count},...
                     'ColumnEditable',true,...
                     'ColumnWidth','auto',...
                     'CellEditCallback',@(src,event)UITableChange(obj,event));   
             if ~obj.Init
                Key(obj,Data,obj.Count);
             end
             obj.Children{obj.Count}=han;
        end
         %uitable callback
        function UITableChange(obj,event)
            event.Source.UserData{1}(obj,event.Source.Data,event.Source.UserData{2});
        end
        
        %------------------------------------------------------------------
        %ui label
        function han=DrawLabel(obj,String,Dim)
            obj.Count=obj.Count+1;
            
            yP=obj.Pos(2)-Dim(2);
            Pos=[10,yP,obj.Pos(3)-15,Dim(2)];
            obj.Pos(2)=yP;
            
            han = uilabel(obj.GuiParent,'Text',sprintf(String),'Position',Pos);
            obj.Children{obj.Count}=han;
        end
        
        %------------------------------------------------------------------
        %uitree
        function han=DrawUITree(obj,Key)
            obj.Count=obj.Count+1;
            %obj.Pos=obj.GuiParent.InnerPosition;
            H=200;
            yP=obj.Pos(2)-H-(obj.Count*20);
            Pos=[10,yP,obj.Pos(3)-100,H];
            obj.Pos(2)=yP;
            
            han=uitree(obj.GuiParent,'Position',Pos,...
                     'UserData',{Key, obj.Count},...
                     'SelectionChangedFcn',@(src,event)UITreeChange(obj,event));   
                 
             obj.Children{obj.Count}=han;
        end
        
        %uitree node 
        function node=DrawUITreeNode(obj,Parent,Type,Key)
            obj.Count=obj.Count+1;
            
            node=uitreenode(Parent,'Text',Type,...
                     'NodeData',{Key, obj.Count});
        end
        
        %uitree callback
        function UITreeChange(obj,event)
            event.Source.SelectedNodes.NodeData{1}(obj,event.Source.SelectedNodes.NodeData{2},event.Source.SelectedNodes);
        end
        
        %uieditfield-------------------------------------------------------
        function han=DrawUIEditField(obj,Type,Key)
            obj.Count=obj.Count+1;
            
            yP=obj.Pos(2)-20;
            Pos=[10,yP,obj.Pos(3)-15,20];
            obj.Pos(2)=yP;
            
            han=uieditfield(obj.GuiParent,'Position',Pos,...
                'Value',Type,...
                'UserData',{Key, obj.Count},...
                'ValueChangedFcn',@(src,event)UIEditFieldChange(obj,event));
            
            obj.Children{obj.Count}=han;
        end
        
        %uieditfield callback
        function UIEditFieldChange(obj,event)
            
        end
        
        %setting for dimensions--------------------------------------------
        %Save current settings
        function SetDimensions(obj,idx,dim)
            
        end
        
        %data asociasing---------------------------------------------------
        %will update gui according to row in tabletype selector
        function CheckOptions(obj)
            for i = 1:numel(obj.Children)
                switch lower(obj.Children{i}.Type)
                    case 'dropdownmenu'
                        obj.Children{i}.Value=obj.TypeSet{i};
                    case 'uispinner'
                        obj.Children{i}.Value=obj.TypeSet{i};
                    case 'uitable'
                        obj.Children{i}.Data=obj.TypeSet{i};
                    otherwise %label
                end
                
            end
        end
        
    end
end

