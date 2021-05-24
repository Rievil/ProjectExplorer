classdef Node < OperLib & GUILib
    %NODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parent;
    end
    
    methods (Abstract)
        FillUITab(obj,Tab);
        FillNode(obj);
        stash=Pack(obj);
        node=AddNode(obj);
        Populate(obj);
    end
    
    methods
        function obj = Node(~)
            obj@OperLib;
            obj@GUILib;

        end
        
        
        
        function sobj = saveobj(obj)
            switch class(obj)
                case 'experiment'
                case 'projectoverview'
                case 'projectobj'
                case 'measobj'
                otherwise
            end
        end
        
        
    end
end

