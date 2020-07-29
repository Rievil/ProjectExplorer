classdef ProjectOverView < handle
    properties (SetAccess = public)
        Projects ProjectObj; %list of projects present in sandbox
        SandBoxFolder char;
        ProjectCount;
        TReeNodes;
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
                
            end
            save(obj);
        end
        
        %create new project
        function CreateNewProject(obj,Name)
            
            newID=numel(obj.Projects) + 1;
            if newID>0
                %nový objekt byl v poøádku vytvoøen
                obj.Projects(newID)=ProjectObj(Name,obj.SandBoxFolder);
            else
                %
            end
            save(obj);
        end
        
        %count number of stored projects
        function [ProjectCount]=Count(obj)
            ProjectCount=numel(obj.Projects);
            obj.ProjectCount=ProjectCount;
        end
        %fill tree node in main app
        function FillTree(obj,UITree)
        Nodes = UITree.Children;
        Nodes.delete;
            if Count(obj)>0
                for i=1:Count(obj)
                    obj.TReeNodes(i)=uitreenode(UITree,...
                        'Text',obj.Projects(i).Name,...
                        'NodeData',[]); 
                end
            else
                
            end
            save(obj);
        end
        
    end %end of public methods
    
    %private methods for controling project overview
    methods (Access = private)
        %save object
        function save(obj)
            Projects=obj.Projects;
            save ([obj.SandBoxFolder 'Projects.mat'],'Projects');
        end
    end
end