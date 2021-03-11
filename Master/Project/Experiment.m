classdef Experiment < handle
    %EXPERIMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TreeNode;
        Name;
        TypeSettings;
        Meas;
        Parent; %ProjectObj
    end
    
    methods
        function obj = Experiment(parent)
            obj.Parent=parent;

        end

    end
end

