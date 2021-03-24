classdef Node < OperLib & GUILib
    %NODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Abstract)
        FillUITab(obj,Tab);
        FillNode(obj);
        stash=Pack(obj);
        node=AddNode(obj);
    end
    
    methods
        function obj = Node(~)
            obj@OperLib;
            obj@GUILib;

        end
    end
end

