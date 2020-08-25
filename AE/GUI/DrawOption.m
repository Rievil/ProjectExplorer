classdef DrawOption < handle
    properties
    end
    
    methods
        function obj=DrawOption (obj)
            
        end
        
        function DrawDropDownMenu(obj)
            PanelPos=obj.Panel.Position;
            Pos=[PanelPos(1)+5 PanelPos(4)-60 ...
                PanelPos(3)-20 20];
            
            
            obj.Children{1}=uidropdown(obj.Panel,'Items',{'-',':','--'},...
                     'Value','-','Position',Pos,...
                     'ValueChangedFcn',@(src,event)DropDownChange(obj,event));                        
        end
        
        function DropDownChange(obj,event)
            for i=1:numel(obj.GObj)
                obj.GObj{i}.LineStyle=event.Value;
            end
        end
    end
end