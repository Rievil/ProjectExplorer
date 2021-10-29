classdef ProjectOverView < Node
    properties (SetAccess = public)
        Projects ProjectObj; %list of projects present in sandbox        
%         SandBoxFolder char;
        ProjectCount=0;
        TreeNode;
        UITree; %handle to ui tree in project explorer
        UITab;
        
%         MasterFolder;
        FigProjectDesign;
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
        
        function SaveProject(obj,proj)
            SandBox=OperLib.FindProp(obj,'SandBoxFolder');
            filename=[SandBox '\' sprintf("%d_%s.mat",proj.ID,proj.Name)];
            save(filename,'proj');
        end
        
        
        function Populate(obj,stash)
            obj.ProjectCount=stash.ProjectCount;
            obj.ProjectID=stash.ProjectID;
            obj.ExperimentID=stash.ExperimentID;
            obj.MeasID=stash.MeasID;
            obj.SpecimenID=stash.SpecimenID;
%             FillNode(obj);
            
            n=0;
            for St=stash.Projects
                n=n+1;
                obj.Projects(n)=ProjectObj('new project',obj);
                Populate(obj.Projects(n),St);
            end
        end

        function FillNode(obj)
            obj.TreeNode=uitreenode(obj.UITree,'Text','Project OverView',...
                'NodeData',{obj,'projectoverview'});
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
end