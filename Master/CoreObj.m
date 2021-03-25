classdef CoreObj < handle
    %COREOBJ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ProjectOverview; %data structure and containers save load
        IsApp=0;
        App;        
        Parent;
    end
    
    properties
        AppTree;
        AppTabGroup;
    end
    
    %----------------------------------------------------------------------
    methods
        %konstruktor
        function obj = CoreObj(parent)
            obj.Parent=parent;   
        end
        
        function AssociateApp(obj,app)
            obj.App=app;
            obj.IsApp=1;
            obj.AppTree=obj.App.PTree;
            obj.AppTabGroup=obj.App.TabGroup;
        end
    end
    %----------------------------------------------------------------------
    methods
        function CreateOverview(obj)
            obj.ProjectOverview=ProjectOverView(obj);
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

