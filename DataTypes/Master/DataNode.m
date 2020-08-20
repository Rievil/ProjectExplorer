classdef DataNode < handle
%data node will give unifical data package based on the RFile or RFolder
%this will be drawn from the subclases
    properties
        CreationDate datetime;
    end
    methods (Access = protected, Abstract)

    end
end

