classdef CoreObj < handle
    %COREOBJ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ProjectOverview; %data structure and containers save load
        App; 
        
        Parent;
    end
    
    properties (Access = private)
        
    end
    
    %----------------------------------------------------------------------
    methods
        function obj = CoreObj(parent)
            obj.Parent=parent;   
%             CreateOverview(obj);
        end
    end
    %----------------------------------------------------------------------
    methods
        function CreateOverview(obj)
            obj.ProjectOverview=ProjectOverView(ParentCare(obj.Parent,'sandbox'),...
                obj.App.PTree,obj.App.TabGroup,obj);
            
%             FillTree(obj.ProjectOverview);
        end
        
        function Save(obj)
    
        end
        
        function Load(obj)
            
        end
    end
    
    methods %callbacks for app controlling
        
    end
    %----------------------------------------------------------------------
end

