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
        end
        
        %creation of meas
        function CreateMeas(obj,SandBox,TreeNode)
            ID=numel(obj.Meas)+1;
            obj.Meas{ID}=AE(ID,obj.ProjectFolder,SandBox);

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
        
        function InitSelectorSets(obj)
            for i=1:numel(obj.Meas)
                if isempty(obj.SelectorSets)
                    obj.SelectorSets(i).Sets=1;
                    obj.SelectorSets(i).Description="Default set";
                end
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
    end
end