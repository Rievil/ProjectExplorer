classdef ProjectObj < handle
    properties (SetAccess=public)
        Name char; %name of project
        ProjectFolder char; %created path in sandbox folder, all MData will be stored there
        Status;
        CreationDate datetime;
        LastChange datetime;
        Meas; %list of measuremnts objects in the specific object
        %each object is stored as a separate file in project folder, for
        %clarity this is must - user might want to manualy load data
        %container of specific measuremnt to access the data, in a long
        %term and debuging this is importnat
        MTreeNodes;     
        SelectorSets struct;
        
        MasterDataTypesTable; 
        DataTypesTable;
        %master data table, which all measruemnts will or will not clone for
        %their ussage
    end
    
    methods (Access=public) 
        %creation of project objects
        function obj=ProjectObj(Name,SandBox)
            obj.Name=Name;
            obj.ProjectFolder=[Name '\'];

            if ~exist([SandBox obj.Name '\'],'dir')
                %folder doesnt exist we can create folder for project
                obj.CreationDate=datetime(now(),'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss');
                mkdir([SandBox Name '\']);
                SetStatus(obj,1);
            else
                %folder does exist, promt the user to set different name
                SetStatus(obj,4);
            end
            InitSelectorSets(obj);
        end
        
        %creation of meas
        function CreateMeas(obj,SandBox,TreeNode)
            ID=numel(obj.Meas)+1;
            %Nyní se musí spustit data loader s souèasným nastavením
            %projektu
            
            Loader=DataLoader(ID,obj.ProjectFolder,SandBox);
            SetDataTypes(Loader,obj.DataTypesTable);
            ReadData(Loader);
            obj.Meas{ID}=Loader;
            %obj.Meas{ID}=StoreData(Loader,ID,obj.ProjectFolder,SandBox);
            %obj.Meas{ID}=AE(ID,obj.ProjectFolder,SandBox);
            
            FillPTree(obj,TreeNode);    
        end
        
        function FillPTree(obj,TreeNode)
            if numel(obj.MTreeNodes)>0
                Nodes=TreeNode.Children;
                Nodes.delete;
            end
            
            for i=1:numel(obj.Meas)
%                 tmp=char(datestr(obj.Meas{i}.Date));
%                 tmp2=obj.Meas{i}.Name;
                obj.MTreeNodes{i}=uitreenode(TreeNode,...
                        'Text',[char(num2str(i)) ' - ' obj.Meas{i}.Name],...
                        'NodeData',{i,obj.Meas{i},TreeNode}); 
            end
        end
        
        %work with selectors
        function InitSelectorSets(obj)
            %for i=1:numel(obj.Meas)
            SelectorSets=struct;
            SelectorSets.Sets=1;
            SelectorSets.Description="Default set";                    
            obj.SelectorSets=SelectorSets;
            %end
        end
        
        %add selector
        function AddSelector(obj)
            if ~isempty(fieldnames(obj.SelectorSets))
                n=size(obj.SelectorSets,2);
                obj.SelectorSets(n+1).Sets=n+1;
                obj.SelectorSets(n+1).Description=sprintf("New set %i",n+1);
                for i=1:numel(obj.Meas)
                    AddSelRows(obj.Meas{i},n+1,obj.SelectorSets(n+1).Description);
                end
            else
                InitSelectorSets(obj);
            end
        end
        
        %change name of selector group
        function ChangeSelName(obj,nSet,NewName)
            obj.SelectorSets(nSet).Description=string(NewName);
            for i=1:numel(obj.Meas)
                obj.Meas{i}.Selector.Properties.VariableNames{nSet}=char(NewName);
            end
        end
        
        %delete selecetor group
        function DeleteSel(obj,nSet)
            obj.SelectorSets(nSet)=[];
            for i=1:size(obj.SelectorSets,2)
                obj.SelectorSets(i).Sets=i;
            end
            
            for i=1:numel(obj.Meas)
                DeleteSelCol(obj.Meas{i},nSet)
            end
        end
        
        function LoadMeas(obj,SandBox)
            obj.Meas=[];
            Files = dir([SandBox obj.ProjectFolder '*.mat']);
            for i=1:size(Files,1)
                load([Files(i).folder '\' Files(i).name],'meas');
                obj.Meas{i}=meas;
                obj.Meas{i}.SandBox=SandBox;
                obj.Meas{i}.FName=[Files(i).folder '\' Files(i).name];
            end
            InitSelectorSets(obj);
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
        
        %delete measurment
        function DeleteM(obj,i,Node)
            Node.delete;
            filename=obj.Meas{i}.FName;
            delete(filename);  
            obj.Meas{i}=[];                      
        end
        %class destructor of object
        function delete(obj)
            
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
        
        %set master data table for project
        function SetDataTypesTable(obj,TypeTable)
            obj.DataTypesTable=TypeTable;
        end
        
        %will copy options for data loading to its measobj
        function CloneDataType(obj,n)
            
        end
    end
end