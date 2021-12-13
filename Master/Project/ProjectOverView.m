classdef ProjectOverView < Node
    properties (SetAccess = public)
        Projects ProjectObj; %list of projects present in sandbox  
        ProjectList table;

        ProjectCount=0;

        UITree; 
        UITab;
        
        FigProjectDesign;
    end
    
    properties (SetAccess = private)
        ProjectID=0;
    end
    
    
    methods
        function ID=get.ProjectID(obj)
            ID=obj.ProjectID+1;
            obj.ProjectID=ID;
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
            
            obj.ProjectList=table([],[],[],[],[],'VariableNames',{'Name','ID','Folder','State','ProjectObj'});
%             FillNode(obj);
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
                    
                    CheckFolder(obj2);
                    AddProjectEntry(obj,obj2);
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
                    case "ProjectList"
                        stash.(prop)=obj.(prop)(:,1:end-1);
%                         for i=1:size(stash.ProjectList,1)
%                         stash.ProjectList.ProjectObj=[];
%                         end
                    case "Projects"
                        n=0;
                        
                        for Pr=obj.(prop)
                            n=n+1;
                            switch obj.ProjectList.State(n)
                                case 1
                                    Save(Pr);
                                case 0
                            end
                        end
                    otherwise
%                         stash.(prop)=obj.(prop);
                end
            end
        end
        
        function row=CheckProjectEntry(obj,ID)
            row=find(obj.ProjectList.ID==ID,1);
        end
        
        function list=GetProjectList(obj)
            list=obj.ProjectList;
        end
        
        function AddProjectEntry(obj,ob2)
%             idx=obj.ProjectList.ID==ob2.ID;
            
%             if sum(idx)==0
                obj.ProjectList=[obj.ProjectList;
                    table(string(ob2.Name),ob2.ID,ob2.ProjectFolder,1,ob2,'VariableNames',{'Name','ID','Folder','State','ProjectObj'})];
%             end
        end
        
        function ChangeState(obj,obj2,state)
            row=CheckProjectEntry(obj,obj2.ID);
            if ~isempty(row)
                obj.ProjectList.State(row)=state;
            end
        end
        
        function RemoveProjectEntry(obj,ob2)
            row=CheckProjectEntry(obj,ob2.ID);
            if ~isempty(row)
                obj.ProjectList(row,:)=[];
            end
        end
        
        function ClearIns(obj)
        end
        
        function LoadIndividualProject(obj)
            
        end
        
        function Populate(obj,stash)
            obj.ProjectCount=stash.ProjectCount;
            obj.ProjectID=stash.ProjectID;

            n=0;
            for i=1:size(stash.ProjectList,1)
                n=n+1;
                obj2=ProjectObj('new project',obj);
                switch stash.ProjectList.State(i)
                    case 1
                        Load(obj2,stash.ProjectList.Folder(i));
                    case 0
                        obj2.Name=stash.ProjectList.Name(i);
                        obj2.ID=stash.ProjectList.ID(i);
                        obj2.ProjectFolder=stash.ProjectList.Folder(i);
                        obj2.State=0;
                        FillGhostNode(obj2);
                end
                AddProjectEntry(obj,obj2);
                obj.Projects(n)=obj2;
                
            end
        end
        
        function LoadProject(obj,filename)
%             obj2=ProjectObj('new project',obj);
            load(filename);
            row=CheckProjectEntry(obj,stash.ID);
            
            if isempty(row)
                obj2=ProjectObj('new project',obj);
                obj.Projects(end+1)=obj2;
                Populate(obj2,stash);
                AddProjectEntry(obj,obj2)
            else
                
            end
        end
        
        
        
        function FillNode(obj)
            obj.TreeNode=uitreenode(obj.UITree,'Text','Project OverView',...
                'NodeData',{obj,'projectoverview'});
            
            
            UIFig=OperLib.FindProp(obj,'UIFig');
            cm = uicontextmenu(UIFig);
            m1 = uimenu(cm,'Text','New project','MenuSelectedFcn',@obj.MNewProject);
            m2 = uimenu(cm,'Text','Load project','MenuSelectedFcn',@obj.MLoadProject);
            obj.TreeNode.ContextMenu=cm;
        end

        function node=AddNode(obj)
%             CreateProject(obj,Name);
        end      
        
        function InitializeOption(obj)
            
        end
    end
    
    %private methods for controling project overview
    methods (Access = public)

        function save(obj)
            val=obj;
            save('test.mat','val');
        end
        
        function MRemoveSpecificProject(obj,src,evnt)
            disp('test');
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
    
    methods %callbacks
        function MNewProject(obj,~,~)
            DesignNewProject(obj);
        end
        
        function MLoadProject(obj,~,~)
            SandBox=OperLib.FindProp(obj,'SandBoxFolder');
            [file,path] = uigetfile('*.mat','Select project main file',SandBox);
            switch class(path)
                case 'double'
                    disp('nothing selected');
                case 'char'
                    filename=sprintf("%s\%s",path,file);
                    LoadProject(obj,filename);
            end
            
        end
    end
end