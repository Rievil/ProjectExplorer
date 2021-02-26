classdef ExplorerObj < handle
    %PROJECTEXPLORER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        App;
        DbConn;
    end
    
    methods
        function obj = ExplorerObj(~)
            obj.App=ProjectExplorer(obj);
        end
    end
end

