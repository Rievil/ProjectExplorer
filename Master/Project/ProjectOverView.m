classdef ProjectOverView < handle
    properties (SetAccess = public)
        Projects ProjectObj; %list of projects present in sandbox
        SandBoxFolder char;
        ProjectCount=0;
        TReeNodes;
        UITree; %handle to ui tree in project explorer
        CurrentMasterFolder;
        Parent;
    end
    
    methods (Access = public)
        %constructor of overview
        function obj=ProjectOverView(SandBoxFolder,UITree,parent)
            obj.SandBoxFolder=SandBoxFolder;
            obj.UITree=UITree;
            obj.Parent=parent;
            obj.CurrentMasterFolder=obj.Parent.MasterFolder;
            if isfile([obj.SandBoxFolder 'Projects.mat'])
                %project overview already exists
                load([obj.SandBoxFolder 'Projects.mat'],'-mat','Projects');
                obj.Projects=Projects;
            else
                %it does not exist, so create it
                
            end
            %save(obj);
        end
        
        %create new project
        function [status,newID]=CreateNewProject(obj,Name)
            newID=numel(obj.Projects) + 1;
            if newID>0
                %nový objekt byl v poøádku vytvoøen
                obj.Projects(newID)=ProjectObj(Name,obj.SandBoxFolder,obj.Parent);
                obj.Projects(newID).ID=newID;
                
                status=obj.Projects(newID).Status.Value;
                
                if status==4
                    %
                    obj.Projects(newID)=[];
                end
            end
%             save(obj);
        end
        
        %count number of stored projects
        function [ProjectCount]=Count(obj)
            ProjectCount=numel(obj.Projects);
            obj.ProjectCount=ProjectCount;
        end
        
        %fill tree node in main app
        function FillTree(obj)
            Nodes = obj.UITree.Children;
            Nodes.delete;
            if Count(obj)>0
                for i=1:Count(obj)
                    if obj.Projects(i).Status.Value==1
                    obj.TReeNodes{i}=uitreenode(obj.UITree,...
                        'Text',obj.Projects(i).Name,...
                        'NodeData',{i,obj.Projects(i)}); 
                        LoadMeas(obj.Projects(i),obj.SandBoxFolder);
                        FillPTree(obj.Projects(i),obj.TReeNodes{i});
                    else
                        obj.TReeNodes{i}=[];
                    end
                end
            else

            end
            %save(obj);
        end
        
        %delete the node and its children (actualy will leave the node
        %intacked, but will set the project status to hidden)
        function HideProject(obj, nProject)
            SetStatus(obj.Projects(nProject),3);
            obj.TReeNodes{nProject}.delete;
            save(obj);
        end
        
        function ShowProjects(obj)
            for i=1:numel(obj.Projects)
                SetStatus(obj.Projects(i),1);
            end
            FillTree(obj);
        end
    end %end of public methods
    
    %private methods for controling project overview
    methods (Access = public)
        %save object
        function save(obj)
            if ~isempty(obj.Projects)
                Projects=obj.Projects;
                Meas=Projects.Meas;
                MTreeNodes=Projects.MTreeNodes;
                f1=waitbar(0,'Saving Projects ...');
                for i=1:numel(obj.Projects)
                    waitbar(i/numel(obj.Projects),f1,'Saving Projects ...');
                    if obj.Projects(i).MeasCount>0
                        SaveMeas(obj.Projects(i),obj.SandBoxFolder)
%                         for j=1:numel(obj.Projects(i).Meas)
%                             saveobj(obj.Projects(i).Meas(j).Data);
%                         end
                         Projects(i).Meas=[];
                         Projects(i).MTreeNodes=[];
                    end
                end
                close(f1);
                save ([obj.SandBoxFolder 'Projects.mat'],'Projects');
                obj.Projects(i).Meas=Meas;
                obj.Projects(i).MTreeNodes=MTreeNodes;
                %obj.Projects=ProjectsAll;
            end
        end
        
        function DeleteProject(obj,ID)
            %delete folder
%             fig = uifigure;
            selection = uiconfirm(obj.Parent.UIFigure,'Do you really want to delete whole project?','Delete whole project',...
                                    'Icon','question');
            if selection=='OK'
                ProjectFolder=[obj.SandBoxFolder obj.Projects(ID).ProjectFolder(1:end-1)];
                [status, message, messageid]=rmdir(ProjectFolder,'s');

                %delete data
                obj.Projects(ID)=[];

                %reduce count
                if obj.ProjectCount>0
                    obj.ProjectCount=obj.ProjectCount-1;
                end
            end
            FillTree(obj);
        end
        
    end
end