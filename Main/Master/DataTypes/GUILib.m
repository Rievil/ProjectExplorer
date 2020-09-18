classdef GUILib (Abstract)
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
%         GuiParent;
        Children;
        Count;
    end
    
    methods (Abstract)
        DrawTypeOption(obj);
    end
    
    methods
        %constructor
        function obj = GUILib(~)

        end
        

    end
    
    %methods for drawing of options in plotter object
    methods (Access = public)
    end
    
    %methods for drawing gui for options in typetable settings
    methods (Access = public) 
        
        %New row in panel
        function NewRow(obj)
            obj.Count=numel(obj.Count)+1;
        end

        %dropdown
        function DrawDropDownMenu(obj,Parent,Items)
            NewRow(obj);
            Pos=Parent.InnerPosition;
            Pos=[10,Pos(4)-5-(obj.Count*20),160,20];

            obj.Children(obj.Count)=uidropdown(Parent,'Items',Items,...
                     'Value',Items{1},'Position',Pos,...
                     'ValueChangedFcn',@(src,event)DropDownChange(obj,event));                        
        end

        %dropdown callback
        function DropDownChange(obj,event)
                auto=5;
        end
    end
end

