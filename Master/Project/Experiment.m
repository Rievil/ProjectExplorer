classdef Experiment < handle
    %EXPERIMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TreeNode;
        Name;
        TypeSettings;
        Meas;
        Specimens;
        Parent; %ProjectObj
    end
    
    
    
    properties
        TypeSelWin;
        eEditTypes;
    end
    
    methods
        function obj = Experiment(parent)
            obj.Parent=parent;
        end
        
        function StartTypeEditor(obj)
            obj.TypeSelWin=AppTypeSelector(app.PNodeSelected,app.MasterFolder,1);
        end
        
        function stash=Pack(obj)
            stash=struct;
        end
    end
end

