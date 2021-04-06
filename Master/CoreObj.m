classdef CoreObj < handle
    %COREOBJ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ProjectOverview; %data structure and containers save load
%         IsApp=0;
        App=[];        
%         App=[];
        AppRunning=0;
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
        
        function AssociateApp(obj)
            obj.App=ProjectExplorer(obj);
            obj.AppRunning=1;
%             obj.App=app;
%             obj.IsApp=1;
            obj.AppTree=obj.App.PTree;
            obj.AppTabGroup=obj.App.TabGroup;
        end
    end
    %----------------------------------------------------------------------
    methods
        function CreateOverview(obj)
            obj.ProjectOverview=ProjectOverView(obj);
            Load(obj);
        end
        
        function Save(obj)
            stash=Pack(obj.ProjectOverview);
            SandBox=OperLib.FindProp(obj,'SandBoxFolder');
            stashFile=[SandBox,'\Stash.mat'];
            save(stashFile,'stash');
        end
        
        function Load(obj)
            SandBox=OperLib.FindProp(obj,'SandBoxFolder');
            stashFile=[SandBox,'Stash.mat'];
            if isfile(stashFile)
                stash=load(stashFile);
                Populate(obj.ProjectOverview,stash.stash);
            end
            
        end
    end
    
    methods %callbacks for app controlling
        
    end
    %----------------------------------------------------------------------
end

