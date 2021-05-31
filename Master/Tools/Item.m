classdef Item < handle
    %ITEM is supercalss for tools used in project explorer, it 
    
    properties
        Fig;
        FigBool=0;
        Parent;
    end
    
    methods (Abstract)
        DrawGui(obj);
        stash=Pack(obj);
        Populate(obj);
    end
    
    
    methods
        function obj = Item(~)
%             obj.Parent=parent;
        end
        
        function SetGui(obj,gui)
            obj.Fig=gui;
            obj.FigBool=1;
        end
        
        function ClearGUI(obj)
            if obj.FigBool==1
                a=obj.Fig.Children;
                a.delete;
            end
%             obj.Fig=[];
        end
        
        function SetParent(obj,parent)
            obj.Parent=parent;
        end
        
        function saveobj(obj)
            ClearGUI(obj);
            obj.Parent=[];
        end
        
%         function 
        
        function delete(obj)
%             ClearGUI(obj);
            obj.Parent=[];
        end
      
    end
end

