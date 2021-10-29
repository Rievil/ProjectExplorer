classdef ProjectObj < Node
    properties (SetAccess=public)
        ID;
        Name char; %name of project
        ProjectFolder char; %created path in sandbox folder, all MData will be stored there
        Description;
        
        Status;
        
        CreationDate datetime;
        LastChange datetime;
        Plotter;
        ExpMainNode;
        Experiments;        
        ExpCount=0;

        TreeNode;    
        
        SelectorSets struct;
    
        CurrentSelector;
        EvListener;
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
        
        function SetFolder(obj)
            SandBox=OperLib.FindProp(obj,'SandBoxFolder');
            
            folder=[SandBox 'P_' char(num2str(obj.ID)) '\'];
            if ~exist(folder,'dir')
                %folder doesnt exist we can create folder for project
                obj.CreationDate=datetime(now(),'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss');
                mkdir([SandBox 'P_' char(num2str(obj.ID)) '\']);
                obj.ProjectFolder=['P_',char(num2str(obj.ID)) '\'];
                SetStatus(obj,1);
                
            else
                %folder does exist, promt the user to set different name
                SetStatus(obj,4);
                error('Folder already exists! use different name!');
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
            obj.ExpMainNode=uitreenode(obj.TreeNode,'Text','Experiments','NodeData',{obj,'expmain'},...
                'Icon',[obj.Parent.Parent.Parent.MasterFolder '\Master\Gui\Icons\Experiment.gif']);
        end
        
        %creation of meas
        function CreateMeas(obj,app,SandBox,TreeNode)
            obj.MeasCount=obj.MeasCount+1;
            ID=obj.MeasCount;
            Row=size(obj.Meas,2)+1;
            %Nyní se musí spustit data loader s souèasným nastavením
            %projektu
            
            Loader=DataLoader(ID,obj.ProjectFolder,SandBox,Row,obj);
            try
            
                if Loader.BruteFolderSet==true
                    SetDataTypes(Loader,obj.DataTypesTable);
                    ReadData(Loader);

                    obj.Meas(Row).Data=Loader;
                    obj.Meas(Row).ID=ID;
                    obj.Meas(Row).Row=Row;

                    obj.Meas(Row).Data.TypeTable=obj.DataTypesTable;
                    CheckSel(obj.Meas(Row).Data,obj.SelectorSets);
                    FillPTree(obj,TreeNode);    
                else
                    delete(Loader);
                    InfoUser(app,'warning','measurement wasnt created');
                end

            catch ME
                obj.Meas(Row)=[];
                Row=Row-1;
                obj.MeasCount=obj.MeasCount-1;
            end         
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
        
        %filling the node
        function FillNode(obj)
            treenode=uitreenode(obj.Parent.TreeNode,...
            'Text',obj.Name,...
            'NodeData',{obj,'project'}); 

            obj.TreeNode=treenode;
            AddMainExpNode(obj);
            FillNode(obj.Plotter);
            
            UIFig=OperLib.FindProp(obj,'UIFig');
            cm = uicontextmenu(UIFig);
            m1 = uimenu(cm,'Text','Delete project','MenuSelectedFcn',@obj.RemoveNode);%,...
            m2 = uimenu(cm,'Text','Deactivate project','MenuSelectedFcn',@obj.MenuRead);
            m3 = uimenu(cm,'Text','Activate project','MenuSelectedFcn',@obj.MenuRead);
            obj.TreeNode.ContextMenu=cm;
        end
        
        %saving
        function stash=Pack(obj)
            stash=struct;
            stash.Name=obj.Name;
            stash.ID=obj.ID;
            stash.ProjectFolder=obj.ProjectFolder;
            stash.Status=obj.Status;
            stash.CreationDate=obj.CreationDate;
            stash.LastChange=obj.LastChange;
            
            stash.ExpMainNode=[];
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
            obj.ExpCount=stash.ExpCount;
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
        end
        
        function AddNode(obj)
            AddExperiment(obj);
        end
        
        function InitializeOption(obj)
        end
    end
    %Data selectors
    methods 
        %work with selectors
        function InitSelectorSets(obj,App)
            if isempty(fieldnames(obj.SelectorSets))

                SelectorSets=struct;
                SelectorSets.Sets=1;
                SelectorSets.Description='Default_set';   
                
                obj.SelectorSets=SelectorSets;

                App.DropDownSelector.Value='Default_set';
                App.DropDownSelector.Items={'Default_set'};
                App.DropDownSelector.ItemsData=1;
                obj.CurrentSelector=1;
            end
        end
        
        %add selector
        function AddSelector(obj)
            if ~isempty(fieldnames(obj.SelectorSets))
                n=size(obj.SelectorSets,2);
                obj.SelectorSets(n+1).Sets=n+1;
                obj.SelectorSets(n+1).Description=sprintf("New set %i",n+1);
                for i=1:size(obj.Meas,2)
                    AddSelRows(obj.Meas(i).Data,n+1,obj.SelectorSets(n+1).Description);
                end
            else
                InitSelectorSets(obj);
            end
        end
        
        %change name of selector group
        function ChangeSelName(obj,nSet,NewName)
            obj.SelectorSets(nSet).Description=string(NewName);
            for i=1:size(obj.Meas,2)
                if ~isempty(obj.Meas(i).Data)
                    obj.Meas(i).Data.Selector.Properties.VariableNames{nSet}=char(NewName);
                end
            end
        end
        
        function ResetSelectors(obj)
            
            if size(obj.Meas,1)>0
                for i=1:size(obj.Meas,2)
                    M=obj.Meas(i).Data;
                    ResetSelectors(M);
                end
            end
        end
        
        
        %delete selecetor group
        function DeleteSel(obj,nSet)
            obj.SelectorSets(nSet)=[];
            for i=1:size(obj.SelectorSets,2)
                %pøeèísluje do správného poøadí jednotlivé selektory
                obj.SelectorSets(i).Sets=i;
            end
            
            for i=1:size(obj.Meas,2)
                DeleteSelCol(obj.Meas(i).Data,nSet)
            end
        end
    end
    
    %Gui methods
    methods
                
        function FillPTree(obj,TreeNode)

        end
    end
    
    
    
    %Save, load, delete, copy methods
    methods 
        function ReLoadData(obj)
            f3 = waitbar(0,'Please wait...','Name','Feature extraction');
            f3.Position(2)=f3.Position(2)+60;
            
            count=0;
            for i=1:numel(obj.Meas)
                M=obj.Meas(i).Data;
                if ~isempty(M)
                    count=count+1;
                end
            end
            
            %obj.notify('ReloadData');
            j=0;
            for i=1:numel(obj.Meas)
                M=obj.Meas(i).Data;
                if ~isempty(M)
                    j=j+1;
                    waitbar(j/count,f3,['Processing meas: ''' M.Name '''']);
                    ReLoadData(M);
%                     ResetSelectors(M);
                end
            end
            close(f3);
        end

        
        
        %pull data from meas
        function [StructData]=PullData(obj,Set)
            StructData=struct;
            for i=1:numel(obj.Meas)
                [Data,Cat]=PullData(obj.Meas{i},Set);
                StructData(i).PulledData=Data;
                StructData(i).Names=fieldnames(StructData(i).PulledData);
                StructData(i).Size=size(StructData(i).PulledData);
                StructData(i).Cat=Cat;
            end
        end
        
       %will copy options for data loading to its measobj
        function CloneDataType(obj,TypeTable)
            for i=1:size(obj.Meas,2)
                obj.Meas(i).Data.TypeTable=TypeTable;
            end
        end
        
              
        function Remove(obj)
            if ~isempty(obj.ProjectFolder)
                folder=[obj.Parent.SandBoxFolder, obj.ProjectFolder];
                rmdir(folder,'s');
            end
            delete(obj.TreeNode);
        end
        
        %class destructor of object
        function delete(obj)
            delete(obj.TreeNode);
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