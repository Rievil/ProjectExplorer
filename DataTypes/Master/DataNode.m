classdef DataNode
%data node will give unifical data package based on the RFile or RFolder
%this will be drawn from the subclases
    properties
        CreationDate datetime;
    end
    methods (Abstract)
        function Node=getData(obj)
        Node=obj.Data;
        end
    end
end

