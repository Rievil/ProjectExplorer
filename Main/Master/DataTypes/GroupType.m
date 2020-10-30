classdef GroupType < handle
    %GROUPTYPE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Group table;
    end
    
    methods
        function obj = GroupType(Group)
            obj.Group=Group;
        end
    end
end

