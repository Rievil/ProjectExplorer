classdef ProjectObj < handle
    properties (SetAccess=public)
        Name char; %name of project
        ProjectFolder char; %created path in sandbox folder, all MData will be stored there
        Status;
        CreationDate datetime;
        LastChange datetime;
        Meas MeasObj; %list of measuremnts objects in the specific object
        %each object is stored as a separate file in project folder, for
        %clarity this is must - user bight want to manualy load data
        %container of specific measuremnt to access the data, in a long
        %term and debuging this is importnat
        MTreeNode;
    end
    
    methods (Access=public) 
        %creation of project objects
        function obj=ProjectObj(Name,SandBox)
            obj.Name=Name;
            obj.ProjectFolder=[Name '\'];

            CurrFiles = dir(obj.ProjectFolder);
            CurrFiles(ismember( {CurrFiles.name}, {'.', '..'})) = []; 
            
            [A]=ismember({CurrFiles.name},obj.Name);
            if sum(A)==0
                %folder doesnt exist we can create folder for project
                obj.CreationDate=datetime(now(),'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss');
                mkdir([SandBox Name '\']);
                SetStatus(obj,1);
            else
                %folder does exist, promt the user to set different name
                SetStatus(obj,4);
            end
        end
        
        %creation of measuremnts of given object
    end
    
    
    methods (Access = private)
        %set of project status; project have statuses to understand in what
        %state is work and data stored in it, its also used to recognize if
        %projectexplorer can load the data, or not ->this will be different
        %for different users
        function SetStatus(obj,phase)            
            if phase>0 && phase<4
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
    end %end of private methods
end