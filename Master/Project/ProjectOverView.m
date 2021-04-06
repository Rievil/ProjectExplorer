classdef ProjectOverView < Node
    properties (SetAccess = public)
        Projects ProjectObj; %list of projects present in sandbox        
%         SandBoxFolder char;
        ProjectCount=0;

        UITree; %handle to ui tree in project explorer
        UITab;
        
%         MasterFolder;
        FigProjectDesign;
        Parent;
    end
    
    properties (SetAccess = private)
        ProjectID=0;
        ExperimentID=0;
        MeasID=0;
        SpecimenID=0;
    end
    
    methods %dependant
        function ID=get.ProjectID(obj)
            ID=obj.ProjectID+1;
            obj.ProjectID=ID;
        end
        
        function ID=get.ExperimentID(obj)
            ID=obj.ExperimentID+1;
            obj.ExperimentID=ID;
        end
        
        function ID=get.MeasID(obj)
            ID=obj.MeasID+1;
            obj.MeasID=ID;
        end
        
        function ID=get.SpecimenID(obj)
            ID=obj.SpecimenID+1;
            obj.SpecimenID=ID;
        end
    end
    
    methods (Access = public)
        %constructor of overview
        function obj=ProjectOverView(parent)
            obj@Node;
            obj.Parent=parent;
            GetLastID(obj);
%             UITree=
            
            
            obj.UITree=OperLib.FindProp(obj,'AppTree');
            
            SandBoxFolder=OperLib.FindProp(obj,'SandBoxFolder');
            
            obj.UITab=OperLib.FindProp(obj,'AppTabGroup');
        end
        
        
        function DesignNewProject(obj)
            obj.FigProjectDesign=EditProject(obj);
        end

        function obj2=CreateProject(obj,Name)
%             if newID>0
            %nový objekt byl v poøádku vytvoøen
            obj2=ProjectObj(Name,obj);
            obj2.ID=OperLib.FindProp(obj,'ProjectID');

            status=obj2.Status.Value;

            switch status
                case 1
                    FillNode(obj2);
                    obj.Projects=[obj.Projects, obj2];
                case 4
                    delete(obj2);
            end                
%             end
        end
        
        function DeleteProject(obj,ID)
            i=0;
            for P=obj.Projects
                i=i+1;
                if P.ID==ID
                    Remove(obj.Projects(i));
                    obj.Projects(i)=[];
                    break;
                end
            
            end
            obj.ProjectCount=numel(obj.Projects);
        end
        
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
                        'NodeData',{obj.Projects(i),'project'}); 
                    
                        obj.Projects(i).TreeNode=obj.TReeNodes{i};
                        AddMainExpNode(obj.Projects(i));

%                         LoadMeas(obj.Projects(i),obj.SandBoxFolder);
%                         FillPTree(obj.Projects(i),obj.TReeNodes{i});
                        
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
%         function HideProject(obj, nProject)
%             SetStatus(obj.Projects(nProject),3);
%             obj.TReeNodes{nProject}.delete;
%             save(obj);
%         end
%         
%         function ShowProjects(obj)
%             for i=1:numel(obj.Projects)
%                 SetStatus(obj.Projects(i),1);
%             end
%             FillTree(obj);
%         end
    end %end of public methods
    
    %Abstract methods
    methods         
        function FillUITab(obj,Tab)

        end
        
        function stash=Pack(obj)
            stash=struct;
            list=string(properties(obj))';
            for prop=list
                switch prop
                    case "ProjectCount"
                        stash.(prop)=obj.(prop);
                    case "ProjectID"
                        stash.(prop)=obj.(prop)-1;
                    case "ExperimentID"
                        stash.(prop)=obj.(prop)-1;
                    case "MeasID"
                        stash.(prop)=obj.(prop)-1;
                    case "SpecimenID"
                        stash.(prop)=obj.(prop)-1;
                    case "Projects"
                        n=0;
                        for Pr=obj.(prop)
                            n=n+1;
                            TMP=Pack(Pr);
                            stash.(prop)(n)=TMP;
                        end
                    otherwise
%                         stash.(prop)=obj.(prop);
                end
            end
        end
        
        function Populate(obj,stash)
            obj.ProjectCount=stash.ProjectCount;
            obj.ProjectID=stash.ProjectID;
            obj.ExperimentID=stash.ExperimentID;
            obj.MeasID=stash.MeasID;
            obj.SpecimenID=stash.SpecimenID;
            
            n=0;
            for St=stash.Projects
                n=n+1;
                obj.Projects(n)=ProjectObj('new project',obj);
                Populate(obj.Projects(n),St);
            end
        end

        function FillNode(obj)
            
        end

        function node=AddNode(obj)
%             CreateProject(obj,Name);
        end      
        
        function InitializeOption(obj)
            
        end
    end
    
    %private methods for controling project overview
    methods (Access = public)
        %save object
%         function save(obj)
%             if ~isempty(obj.Projects)
%                 Projects=obj.Projects;
%                 Meas=Projects.Meas;
%                 MTreeNodes=Projects.MTreeNodes;
%                 f1=waitbar(0,'Saving Projects ...');
%                 for i=1:numel(obj.Projects)
%                     waitbar(i/numel(obj.Projects),f1,'Saving Projects ...');
%                     if obj.Projects(i).MeasCount>0
%                         SaveMeas(obj.Projects(i),obj.SandBoxFolder)
% %                         for j=1:numel(obj.Projects(i).Meas)
% %                             saveobj(obj.Projects(i).Meas(j).Data);
% %                         end
%                          Projects(i).Meas=[];
%                          Projects(i).MTreeNodes=[];
%                     end
%                 end
%                 close(f1);
%                 save ([obj.SandBoxFolder 'Projects.mat'],'Projects');
%                 obj.Projects(i).Meas=Meas;
%                 obj.Projects(i).MTreeNodes=MTreeNodes;
%                 %obj.Projects=ProjectsAll;
%             end
%         end
        
%         function DeleteProject(obj,ID)
%             %delete folder
% %             fig = uifigure;
%             selection = uiconfirm(obj.Parent.UIFigure,'Do you really want to delete whole project?','Delete whole project',...
%                                     'Icon','question');
%             if selection=='OK'
%                 ProjectFolder=[obj.SandBoxFolder obj.Projects(ID).ProjectFolder(1:end-1)];
%                 [status, message, messageid]=rmdir(ProjectFolder,'s');
% 
%                 %delete data
%                 obj.Projects(ID)=[];
% 
%                 %reduce count
%                 if obj.ProjectCount>0
%                     obj.ProjectCount=obj.ProjectCount-1;
%                 end
%             end
%             FillTree(obj);
%         end
        function save(obj)
            val=obj;
            save('test.mat','val');
        end
    end
    
    methods %db
        function GetLastID(obj)
            Connect(obj);
            %project ID----------------------------------------------------
            querry=['SELECT TOP 1 ID FROM ProjectList ORDER BY ID DESC'];
            lastID=DBFetch(obj,querry);
            if size(lastID,1)==0
                obj.ProjectID=0;
            else
                obj.ProjectID=lastID.ID;
            end
            Disconnect(obj);
        end
    end
end