classdef CoreObj < handle
    %COREOBJ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    properties (Access = private)
        Parent;
    end
    
    methods
        function obj = CoreObj(parent)
            obj.Parent=parent;
            
        end
    end
end

