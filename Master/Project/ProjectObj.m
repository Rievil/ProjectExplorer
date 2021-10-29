classdef ProjectObj < Node
    properties (SetAccess=public)
        ID;
        Name char; %name of project
        ProjectFolder string; %created path in sandbox folder, all MData will be stored there
        Description;
        State=1;
        Status;
        
        CreationDate datetime;
        LastChange datetime;
        Plotter;
        ExpMainNode;
        Experiments;        
        ExpCount=0;

            
        
        SelectorSets struct;
    
        CurrentSelector;
        EvListener;
        Version=1;
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
    
    
    %Main methods, consturction, destruction etc.
    methods (Access=public) 
        %creation of project objects
        function obj=ProjectObj(Name,parent)
%             obj@Node;
            
            obj.Parent=parent;
            obj.Name=Name;
            SetStatus(obj,1);
            obj.Plotter=Plotter(obj);
%             SetGuiParent(obj.Plotter,obj);
%             obj.ID=OperLib.FindProp(obj,'ProjectID');
        end
        
        function CheckFolder(obj)
            SandBox=OperLib.FindProp(obj,'SandBoxFolder');
            folder=sprintf("%sP_%d_%s\\",SandBox,obj.ID,obj.Name);
            if ~exist(folder)
                obj.CreationDate=datetime(now(),'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss');
                mkdir(folder);
                prfolder=sprintf("P_%d_%s",obj.ID,obj.Name);
                obj.ProjectFolder=prfolder;
            end
        end
        
        function NewExperiment(obj) %volání aplikací
            obj2=AddExperiment(obj);
            FillNode(obj2);
            ExpID=OperLib.FindProp(obj,'ExperimentID');
            obj2.ID=ExpID;
            obj2.TypeFig=AppTypeSelector(obj2);
        end

        function obj2=AddExperiment(obj)
            obj2=Experiment(obj);   
            obj.Experiments=[obj.Experiments, obj2];
            obj.ExpCount=numel(obj.Experiments);
        end
        
        function DeleteExperiment(obj,name)
            i=0;
            for E=obj.Experiments
                i=i+1;
                if strcmp(E.Name,name)
                    Remove(obj.Experiments(i));
                    obj.Experiments(i)=[];
                    break;
                end
            end
            obj.ExpCount=numel(obj.Experiments);
        end
        
        function AddMainExpNode(obj)
            iconFolder=[OperLib.FindProp(obj,'MasterFolder'), 'Master\Gui\Icons\'];
            obj.ExpMainNode=uitreenode(obj.TreeNode,'Text','Experiments','NodeData',{obj,'expmain'},...
                'Icon',[iconFolder 'Experiment.gif']);
        end
        
        %set of project status; project have statuses to understand in what
        %state is work and data stored in it, its also used to recognize if
        %projectexplorer can load the data, or not ->this will be different
        %for different users
        
        function SetStatus(obj,phase)            
            if phase>0 && phase<5
                switch phase
                    case 1
                        obj.Status.Label='created';
                        obj.Status.Value=1;
                        obj.Status.LoadRule=true;
                    case 2
                        obj.Status.Label='ended';
                        obj.Status.Value=2;
                        obj.Status.LoadRule=true;
                    case 3
                        obj.Status.Label='hiden';
                        obj.Status.Value=3;
                        obj.Status.LoadRule=false;
                    case 4
                        obj.Status.Label='error';
                        obj.Status.Value=4;
                        obj.Status.LoadRule=false;
                end
            end
        end %end of status funciton
  
        
        %set master data table for project
        function SetDataTypesTable(obj,TypeTable)
            obj.DataTypesTable=TypeTable;
        end
        
        
    end
    
    %Abstract methods
    methods 
        %showing editable window in project explorer
        function FillUITab(obj,Tab)

        end
        
        function icon=Geticon(obj)
            iconFolder=[OperLib.FindProp(obj,'MasterFolder'), 'Master\Gui\Icons\'];
            switch obj.State
                case 1
                    icon=[iconFolder 'project_active.gif'];
                case 0
                    icon=[iconFolder 'project_deactive.gif'];
            end
        end
        
        function FillGhostNode(obj)
            
            
            treenode=uitreenode(obj.Parent.TreeNode,...
            'Text',obj.Name,...
            'NodeData',{obj,'project'},'Icon',Geticon(obj)); 
            obj.TreeNode=treenode;
            UIFig=OperLib.FindProp(obj,'UIFig');
            cm = uicontextmenu(UIFig);
            m1 = uimenu(cm,'Text','Delete project','MenuSelectedFcn',@obj.MRemoveProject);%,...
            m2 = uimenu(cm,'Text','Deactivate project','MenuSelectedFcn',@obj.MDeactivate);
            m3 = uimenu(cm,'Text','Activate project','MenuSelectedFcn',@obj.MActivate);
            obj.TreeNode.ContextMenu=cm;
            
        end
        
        function ClearIns(obj)
        end
        
        %filling the node
        function FillNode(obj)
%             if obj.State==0
            if isempty(obj.TreeNode)
                 FillGhostNode(obj);
            else
                if ~isvalid(obj.TreeNode)
                    FillGhostNode(obj);
                end
            end
%             end
            AddMainExpNode(obj);
            FillNode(obj.Plotter);
            
            
        end
        
        %saving
        function stash=Pack(obj)
            stash=struct;
            stash.Name=obj.Name;
            stash.ID=obj.ID;
            stash.ProjectFolder=obj.ProjectFolder;
            stash.Status=obj.Status;
            stash.State=obj.State;
            stash.CreationDate=obj.CreationDate;
            stash.LastChange=obj.LastChange;
            
            stash.ExperimentID=obj.ExperimentID;
            stash.MeasID=obj.MeasID;
            stash.SpecimenID=obj.SpecimenID;
            
            stash.ExpMainNode=[];
            stash.Version=obj.Version;
            if isvalid(obj.Plotter)
                stash.Plotter=Pack(obj.Plotter);
            end
%             stash.Experiments=struct;
            n=0;
            for E=obj.Experiments
                n=n+1;
                stash.Experiments(n)=Pack(E);            
            end
            if n==0
                stash.Experiments=struct;
            end
            stash.ExpCount=n;
                
        end
        
        %fill the object
        function Populate(obj,stash)
            obj.Name=stash.Name;
            obj.ID=stash.ID;
            obj.ProjectFolder=stash.ProjectFolder;
            obj.Status=stash.Status;
            obj.CreationDate=stash.CreationDate;
            obj.LastChange=stash.LastChange;
            if isfield(stash,'ExpCount')
                obj.ExpCount=stash.ExpCount;
            end
            
            if isfield(stash,'State')
                obj.State=stash.State;
            end
            
            if isfield(stash,'ExperimentID')
            obj.ExperimentID=stash.ExperimentID;
            end
            
            if isfield(stash,'MeasID')
            obj.MeasID=stash.MeasID;
            end
            
            if isfield(stash,'SpecimenID')
            obj.SpecimenID=stash.SpecimenID;
            end
            

            FillNode(obj);

            if obj.ExpCount>0
                n=0;
                for Ex=stash.Experiments
                    n=n+1;
                    obj2=AddExperiment(obj);
                    Populate(obj2,Ex);
                end
            end


            if isfield(stash,'Plotter')
                Populate(obj.Plotter,stash.Plotter);
            end

            if isfield(stash,'Version')
                obj.Version=stash.Version;
            end
        end
        
        function AddNode(obj)
            AddExperiment(obj);
        end
        
        function InitializeOption(obj)
        end
    end
   
    
    %Gui methods
    methods
                
        function FillPTree(obj,TreeNode)

        end
    end
    
    
    
    %Save, load, delete, copy methods
    methods 
        
        function Save(obj)
            obj.Version=obj.Version+1;
            obj.CheckFolder;
            stash=Pack(obj);
            SandBox=OperLib.FindProp(obj,'SandBoxFolder');
            filename=sprintf("%s%s\\main.mat",SandBox,stash.ProjectFolder);
%             file=sprintf("%s\\main.mat",stash.ProjectFolder);
            save(filename,'stash');
        end
        
        function Load(obj,filename)
            SandBox=OperLib.FindProp(obj,'SandBoxFolder');
            file=sprintf("%s%s\\main.mat",SandBox,filename);
            load(file);
            Populate(obj,stash);
        end
              
        function Remove(obj)
            UITab=OperLib.FindProp(obj,'UIFig');
            selection = uiconfirm(UITab,sprintf("Do you want to remove whole project '%s'?",obj.Name),'Delete project', ...
               'Options',{'Yes','No'}, ...
               'DefaultOption',2,'CancelOption',2);
            switch selection
                case 'Yes'
                    RemoveProjectEntry(obj.Parent,obj);
                    SandBox=OperLib.FindProp(obj,'SandBoxFolder');
                    status = rmdir(sprintf("%s%s",SandBox,obj.ProjectFolder));
                    delete(obj.TreeNode);
                    delete(obj);
                case 'No'
            end
        end
        
        %class destructor of object
        function delete(obj)
            delete(obj.TreeNode);
        end
        

    end
    
    methods %callbacks
        function MRemoveProject(obj,~,~)
            Remove(obj);
        end
        
        function MDeactivate(obj,~,~)
            ChangeState(obj.Parent,obj,0);
            delete(obj.Plotter);
%             obj.Plotter=[];
            delete(obj.ExpMainNode);
%             obj.ExpMainNode=[];
            delete(obj.Experiments);
%             obj.Experiments=[];
            obj.State=0;
            obj.TreeNode.Icon=Geticon(obj);
        end
        
        function MActivate(obj,~,~)
            ChangeState(obj.Parent,obj,1);
            obj.Plotter=Plotter(obj);
            Load(obj,obj.ProjectFolder);
            obj.State=1;
            obj.TreeNode.Icon=Geticon(obj);
        end
    end
    
    methods %db
        function AddProject(obj)
            Connect(obj);
            data=table(string(obj.Name),"",'VariableNames',{'ProjectName','Description'});
            DBWrite(obj,'ProjectList',data);
            [bool,user]=DBCheckForAlias(obj,alias);
            
            Disconnect(obj);
        end
        
        function project=GetProjects(obj)
            
        end
    end
        
end