classdef ProjectOverView < handle
    properties (SetAccess = public)
        Projects; %list of projects present in sandbox
        SandBoxFolder char;
    end
    
    methods (Access = public)
        %constructor of overview
        function obj=ProjectOverView(SandBoxFolder)
            obj.SandBoxFolder=SandBoxFolder;
            if isfile([obj.SandBoxFolder 'Projects.mat'])
                %project overview already exists
                load([obj.SandBoxFolder 'Projects.mat'],'-mat','Projects');
                obj.Projects=Projects;
            else
                %it does not exist, so create it
                InicializeOverview(obj);
                save(obj);
            end
        end
        
        %create new project
        function CreateNewProject(obj,Name)
            
            newID=size(obj.Projects,2)+1;
            TMPP=ProjectObj(Name,obj.SandBoxFolder);
            if TMPP.Status.Value==1
                %nový objekt byl v poøádku vytvoøen
                obj.Projects(newID).ProjectOBJ=TMPP;
            else
                
            end
            save(obj);
        end
        
        %fill tree node in main app
        function FillTree(obj,UITree)
        Nodes = UITree.Children;
        Nodes.delete;
        
            for i=1:size(obj.Projects,2)
                if ~isempty(obj.Projects(i).ProjectOBJ)
                    obj.Projects(i).UITreeNode=uitreenode(UITree,...
                        'Text',obj.Projects(i).ProjectOBJ.Name,...
                        'NodeData',obj.Projects(i).ProjectOBJ); 
                end
            end
            save(obj);
        end
        
    end %end of public methods
    
    %private methods for controling project overview
    methods (Access = private)
        %inicialize projects
        function InicializeOverview(obj)
            obj.Projects=struct('ProjectOBJ',[],'Folder',[],'UITreeNode',[]);            
        end
        
        %save object
        function save(obj)
            Projects=obj.Projects;
            save ([obj.SandBoxFolder 'Projects.mat'],'Projects');
        end
    end
end