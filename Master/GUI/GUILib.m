classdef GUILib < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
        GUIParents struct; 
        GuiParent;
        GUICount=0;
        Children;
        TypeSet;
        Init=0;
        Pos;
    end
    
    %interface
    methods (Abstract)

    end
    %         PlotType(obj);
    methods (Access = public)
        %Constructor
        function obj=GUILib(~)
            obj.Init=false;
            ResetParents(obj);

        end
        
        function ResetParents(obj)
            obj.GUIParents=struct('Parent',[],'Class',[],'Name',[],'Pos',[]);
        end

        
        function T=GetTypeSpec(obj)
            T=obj.TypeSet{1, 1};  
        end
        
        function InitTypeOption(obj)
            

            if obj.Init
                ShowComponents(obj)
            else
                obj.Init=1;
                SetParent(obj,'type');
                CreateTypeComponents(obj);
                CreateContainerComponents(obj);
            end
        end
        
        function AddParent(obj,parent,name)
            sz=size([obj.GUIParents(:).Parent],2); 
            
            obj.GUIParents(sz+1).Parent=parent;
            obj.GUIParents(sz+1).Class=class(parent);
            obj.GUIParents(sz+1).Name=lower(name);
            
            obj.GUIParents(sz+1).Pos=[10,...
                    obj.GUIParents(sz+1).Parent.InnerPosition(4),...
                    obj.GUIParents(sz+1).Parent.InnerPosition(3),...
                    20];
        end
        
        function p=GetParent(obj,in)
            %will find saved parent by either name or number
            sz=size(obj.GUIParents,2);
            switch class(in)
                case 'char'
                    %getting by name
                    for i=1:sz
                        if strcmp(in,obj.GUIParents(i).Name)
                            find=i;
                            break;
                        else 
                            find=0;
                        end
                    end
                case 'double'
                    %getting by number
                    find=in;
            end
            
            if find<=sz && find>0
                p=obj.GUIParents(find);            
            else
                warning('You try to get parent index which was not defined!');
                p=[];
            end
        end
        
        
        function SetParent(obj,n)
            p=GetParent(obj,n);
            obj.GuiParent=p.Parent;
            obj.Pos=p.Pos;
        end
        
        function SetGuiParent(obj,Parent)
            ResetParents(obj);
            switch class(Parent)
                case 'matlab.ui.container.TabGroup'
                    for ch=Parent.Children'
                        AddParent(obj,ch,lower(ch.Title));
                    end
                otherwise
                    obj.GuiParent=Parent;
            end
        end
        
        function NewRow(obj)
            obj.GUICount=obj.GUICount+1;
        end

    end
    
    %methods for drawing of options in plotter object
    methods
        function delete(obj)
        end
    end
    
    %methods for drawing gui for options in typetable settings
    methods (Access = public) 
        
        function HideComponents(obj)
%             for j=1:numel(obj.GUIParents)
%                 SetParent(obj,obj.GUIParents(j).Name);
                for i=1:numel(obj.Children)
                    obj.Children(i,1).Visible=false;
                end
                
                for i=1:numel(obj.ContChildren)
                    obj.ContChildren(i,1).Visible=false;
                end
%             end
            
        end
        
        function ShowComponents(obj)

                for i=1:numel(obj.Children)
                    obj.Children(i,1).Visible=true;  
                end
                
                for i=1:numel(obj.ContChildren)
                    obj.ContChildren(i,1).Visible=true;
                end
        end
        
        %clear GUI COntainer
        function Clear(obj)
            
            obj.GUICount=0;
            for i=1:size(obj.GUIParents,2)
                Ch=obj.GUIParents(i).Parent;
                if isvalid(Ch)
                    delete(Ch.Children);
                    if numel(obj.Children)>0
                        for j=1:numel(obj.Children)
                        delete(obj.Children{j});
                        end
                        obj.Children=[];
                    end
                    obj.GUIParents(i).Pos=[10,...
                        obj.GUIParents(i).Parent.InnerPosition(4),...
                        obj.GUIParents(i).Parent.InnerPosition(3),...
                        20];
                end
            end
            
        end
        
        %Init of GUI per children
        function GuiInit(obj)
            %obj.GUICount=0;
            obj.Init=true;
        end
        
        %------------------------------------------------------------------
        %dropdown
        function han=DrawDropDownMenu(obj,Items,Key)
            obj.GUICount=obj.GUICount+1;
            %obj.Pos=obj.GuiParent.InnerPosition;
            
            yP=obj.Pos(2)-20-(obj.GUICount*20);
            Pos=[10,yP,120,20];
            obj.Pos(2)=yP;
            
            han=uidropdown(obj.GuiParent,'Items',Items,...
                     'Value',Items{1},'Position',Pos,...
                     'UserData',{Key, obj.GUICount},...
                     'ValueChangedFcn',@(src,event)DropDownChange(obj,event));   
             if ~obj.Init
                Key(obj,Items{1},obj.GUICount);
             end
             obj.Children{obj.GUICount}=han;
        end

        %dropdown callback
        function DropDownChange(obj,event)
            event.Source.UserData{1}(obj,event.Source.Value,event.Source.UserData{2});
        end
        %------------------------------------------------------------------
        %spinner
        function han=DrawSpinner(obj,Limits,Target,Key)
            
            obj.GUICount=obj.GUICount+1;
            yP=obj.Pos(2)-(obj.GUICount*20);
            Pos=[10,yP,120,20];
            obj.Pos(2)=yP;
            
            han=uispinner(obj.GuiParent,'Limits',Limits,...
                     'Visible','off',...
                     'Value',Limits(1),'Position',Pos,...
                     'UserData',{Key, obj.GUICount,Target},...
                     'ValueChangedFcn',@(src,event)SpinnerChange(obj,event));   
             if ~obj.Init
                Key(obj,han.Value,obj.GUICount,Target);
             end
             obj.Children{obj.GUICount}=han;
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
        function han=DrawUITable(obj,Data,Key,inHeight)
            arguments
                obj;
                Data;
                Key;
                inHeight;
            end
            
            if inHeight>~0
                Height=inHeight;
            else
                Height=300;
            end
               
            obj.GUICount=obj.GUICount+1;
            %Pos=obj.GuiParent.InnerPosition;

            yP=obj.Pos(2)-Height-(obj.GUICount*20);
            
            Pos=[10,yP,obj.Pos(3)-15,Height];
            obj.Pos(2)=yP;
            
            %Pos=[10,Pos(4)-200-(obj.GUICount*23),Pos(3)-15,180];
            
            han=uitable(obj.GuiParent,'Data',Data,...
                     'Position',Pos,...
                     'UserData',{Key, obj.GUICount},...
                     'ColumnEditable',true,...
                     'ColumnWidth','auto',...
                     'CellEditCallback',@(src,event)UITableChange(obj,event));  
                 
             if ~obj.Init
                Key(obj,Data,obj.GUICount);
             end
             obj.Children{obj.GUICount}=han;
        end
        
         %uitable callback
        function UITableChange(obj,event)
            event.Source.UserData{1}(obj,event.Source.Data,event.Source.UserData{2});
        end
        
        %------------------------------------------------------------------
        %ui label
        function han=DrawLabel(obj,String,Dim)
            obj.GUICount=obj.GUICount+1;
            
            yP=obj.Pos(2)-Dim(2);
            Pos=[10,yP,obj.Pos(3)-15,Dim(2)];
            obj.Pos(2)=yP;
            
            han = uilabel(obj.GuiParent,'Text',sprintf(String),'Position',Pos);
            obj.Children{obj.GUICount}=han;
        end
        
        %------------------------------------------------------------------
        %uitree
        function han=DrawUITree(obj,Key)
            obj.GUICount=obj.GUICount+1;
            %obj.Pos=obj.GuiParent.InnerPosition;
            H=200;
            yP=obj.Pos(2)-H-(obj.GUICount*20);
            Pos=[10,yP,obj.Pos(3)-100,H];
            obj.Pos(2)=yP;
            
            han=uitree(obj.GuiParent,'Position',Pos,...
                     'UserData',{Key, obj.GUICount},...
                     'SelectionChangedFcn',@(src,event)UITreeChange(obj,event));   
                 
             obj.Children{obj.GUICount}=han;
        end
        
        %uitree node 
        function node=DrawUITreeNode(obj,Parent,Type,Key)
            obj.GUICount=obj.GUICount+1;
            
            node=uitreenode(Parent,'Text',Type,...
                     'NodeData',{Key, obj.GUICount});
        end
        
        %uitree callback
        function UITreeChange(obj,event)
            event.Source.SelectedNodes.NodeData{1}(obj,event.Source.SelectedNodes.NodeData{2},event.Source.SelectedNodes);
        end
        
        %uieditfield-------------------------------------------------------
        function han=DrawUIEditField(obj,Type,Key)
            obj.GUICount=obj.GUICount+1;
            
            yP=obj.Pos(2)-20;
            Pos=[10,yP,obj.Pos(3)-15,20];
            obj.Pos(2)=yP;
            
            han=uieditfield(obj.GuiParent,'Position',Pos,...
                'Value',Type,...
                'UserData',{Key, obj.GUICount},...
                'ValueChangedFcn',@(src,event)UIEditFieldChange(obj,event));
            
            obj.Children{obj.GUICount}=han;
        end
        
        %uieditfield callback
        function UIEditFieldChange(obj,event)
            event.Source.UserData{1}(obj,event.Value);
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

