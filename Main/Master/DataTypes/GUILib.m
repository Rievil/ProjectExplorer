classdef GUILib < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
        GuiParent;
        Count=0;
        Children;
        Init;
    end
    
    
    methods
        function obj=GUILib(GuiParent)
            obj.GuiParent=GuiParent;
            obj.Init=false;
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
            if numel(obj.Children)>0
                for i=1:numel(obj.Children)
                delete(obj.Children{i});
                end
            end
        end
        
        %New row in panel
        function GuiInit(obj)
            obj.Count=0;
            obj.Init=true;
        end

        %dropdown
        function han=DrawDropDownMenu(obj,Items,Key)
            Clear(obj);
            obj.Count=obj.Count+1;
            Pos=obj.GuiParent.InnerPosition;
            
            Pos=[10,Pos(4)-20-(obj.Count*23),120,20];
            
            han=uidropdown(obj.GuiParent,'Items',Items,...
                     'Value',Items{1},'Position',Pos,...
                     'UserData',Key,...
                     'ValueChangedFcn',@(src,event)DropDownChange(obj,event));   
             if ~obj.Init
                Key(obj,Items{1});
             end
            
            obj.Children{obj.Count}=han;
        end

        %dropdown callback
        function DropDownChange(obj,event)
            event.Source.UserData(obj,event.Source.Value);
        end
        
        %uitable
        function han=DrawUITable(obj,Data,Key)
        end
        
    end
end

