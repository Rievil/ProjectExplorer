classdef ProjectObj < handle
    properties (SetAccess=public)
        ID;
        Name char; %name of project
        ProjectFolder char; %created path in sandbox folder, all MData will be stored there
        
        Status;
        
        CreationDate datetime;
        LastChange datetime;

        ExpMainNode;
        Experiments;        
        ExpCount=0;

        TreeNode;    
        
        SelectorSets struct;
    
        CurrentSelector;
        EvListener;
        
        Parent;        
    end

    
    %Main methods, consturction, destruction etc.
    methods (Access=public) 
        %creation of project objects
        function obj=ProjectObj(Name,parent)
            obj@Node;
            
            obj.Parent=parent;
            obj.Name=Name;
            SandBox=OperLib.FindProp(obj,'SandBoxFolder');
            
%             obj.Meas=struct('Data',[],'ID',[],'Row',[]);
            
            if ~exist([SandBox obj.Name '\'],'dir')
                %folder doesnt exist we can create folder for project
                obj.CreationDate=datetime(now(),'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss');
                mkdir([SandBox Name '\']);
                obj.ProjectFolder=[Name '\'];
                SetStatus(obj,1);
                
            else
                %folder does exist, promt the user to set different name
                SetStatus(obj,4);
                error('Folder already exists! use different name!');
            end
%             AddMainExpNode(obj);
%             InitSelectorSets(obj,App);
        end
        
        function NewExperiment(obj) %vol�n� aplikac�
            obj2=AddExperiment(obj);
            obj2.TypeFig=AppTypeSelector(obj2);
        end

        function obj2=AddExperiment(obj)
            obj.ExpCount=obj.ExpCount+1;
            
            ExpID=OperLib.FindProp(obj,'ExperimentID');
            
            obj2=Experiment(obj,ExpID);   
            FillNode(obj2);
            obj.Experiments=[obj.Experiments, obj2];
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
            %Nyn� se mus� spustit data loader s sou�asn�m nastaven�m
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
            treenode=uitreenode(obj.Parent.UITree,...
            'Text',obj.Name,...
            'NodeData',{obj,'project'}); 

            obj.TreeNode=treenode;
            AddMainExpNode(obj);
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
            n=0;
            for E=obj.Experiments
                n=n+1;
                stash.Experiments(n)=Pack(E);            
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
                %p�e��sluje do spr�vn�ho po�ad� jednotliv� selektory
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
    
    %Overview of all meas, data preparation
    methods      
        function Out=MakeOverView(obj)
            Out=table;
            for i=1:size(obj.Meas,2)
                M=obj.Meas(i).Data;
                MeaName=strings([size(M.Data,1),1]);
                MeaName(:,1)=string(M.Name);
                MTab=table;
                for j=1:size(M.Data,1)
                    MTab=[MTab; M.Data.MainTable(j).Data];
                end
                
                Out=[Out; table(MeaName), MTab];
            end
            [file,path,indx] = uiputfile('OverViewTable.xlsx');
            filename=[path file];
            writetable(Out,filename);
        end
        
        function Stack(obj,Sel)
            FilterStack=table;
            OutStack=table;
            for i=1:numel(obj.Meas)
                M=obj.Meas(i).Data;
                ID=obj.Meas(i).ID;
                IDSpec=[];
                if ~isempty(M)
                    idx=M.Selector{:,Sel};
                    
                    
                    IDMeas(1:size(M.Data,1),1)=ID;
                    IDMeas=IDMeas(idx,1);
                    
                    IDSpec(:,1)=linspace(1,size(M.Data,1),size(M.Data,1))';
                    IDSpec=IDSpec(idx,1);
                    
                    Filter=M.Data(idx,:);
                    if size(Filter,1)>0
                        Filter=[table(IDMeas,IDSpec,'VariableNames',{'IDMeas','IDSpec'}), Filter];
                        
                        FilterStack=[FilterStack; Filter];
                    end
                end
            end
            obj.TotalTable=FilterStack;
            %obj.TotalTable=OutStack;
        end
        
        function SignSpecimen(obj,meas,spec)
            if obj.CurrentSelector>0
                val=obj.Meas(meas).Data.Selector{spec,obj.CurrentSelector};
                obj.Meas(meas).Data.Selector{spec,obj.CurrentSelector}=~val;
            end
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

        function SaveMeas(obj,SandBox)
            %sobj = saveobj@MeasObj(obj);
            f1=waitbar(0,'Saving meas: ...');
            try
                MSize=size(obj.Meas,2);
                for i=1:MSize
                    
                    warning ('off','all');
                    meas=obj.Meas(i);
                    meas.Data.Parent=[];
                    save([SandBox obj.ProjectFolder 'Meas_' char(num2str(meas.ID)) '.mat'],'meas');
                    waitbar(i/MSize,f1,['Saving meas: ''' char(meas.Data.Name) '''']);
                    warning ('on','all');
                end
            catch ME
                close(f1);
            end
            close(f1);
        end
        
        
        function LoadMeas(obj,SandBox)
            obj.Meas=[];
            Files = dir([SandBox obj.ProjectFolder '*.mat']);
            if size(Files,1)>0
                for i=1:size(Files,1)
                    load([Files(i).folder '\' Files(i).name],'meas');
                    
                    row=meas.Row;
                    obj.Meas(row).Data=meas.Data;
                    obj.Meas(row).ID=meas.ID;
                    obj.Meas(row).Row=meas.Row;
                    
                    obj.Meas(row).Data.SandBox=SandBox;
                    obj.Meas(row).Data.FName=[Files(i).folder '\' Files(i).name];
                    obj.Meas(row).Data.Parent=obj;
                end
                InitSelectorSets(obj);
            end
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
        
              
        %delete measurment
        function DeleteM(obj,i,Meas,Node)
            Node.delete;
            delete(Meas);
            obj.Meas(i)=[];
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
end