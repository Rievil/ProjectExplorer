classdef Node < OperLib & GUILib
    %NODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MasterFolder;
    end
    methods (Abstract)
        FillUITab(obj);
%         PlotType(obj);
    end
    methods
        function obj = Node(~)
            obj@OperLib;
            obj@GUILib;

        end
    end
end

