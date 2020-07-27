classdef ProjectObj < super
    properties (SetAccess=public)
        Name char; %name of project
        CreationDate datetime; %date of creation of project
        ID uint32; %identification number of project
        Meas MeasObj; %stacked objects of measurements
        Users; %list of users, who is author | editor | visitor
        UITreeNode; %tree node of object itself
        SBOrigFolder; %original SB folder retrived from useroptions
        ProjectFolder string; %created path in sandbox folder, all MData will be stored there
        Status;
    end
    
    methods (Access=public)
        %will create folder in SB folder, with specified unique name of
        %project
        function MakeProjectPath(obj)
            obj.ProjectFolder=[obj.SBOrigFolder name];

            CurrFiles = dir();
            CurrFiles(ismember( {CurrFiles.name}, {'.', '..'})) = []; 
            
            if ~ismember({CurrFiles.name},name)
                %folder doesnt exist we can create folder for project
                obj.CreationDate=datetime(now(),'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss');
                mkdir(obj.ProjectFolder);
                set.Status(obj,1);
            else
                %folder does exist, promt the user to set different name
            end
        end
        
        %will delete 
        function DeleteProject(obj)
            
        end
        
        %will save object itself
        function sobj = saveobj(obj)
            % Call superclass saveobj method
            sobj = saveobj@super(obj); 
            % Perform subclass save operations
        end

    end
    
    methods 
        %set of project status; project have statuses to understand in what
        %state is work and data stored in it, its also used to recognize if
        %projectexplorer can load the data, or not ->this will be different
        %for different users
        function set.Status(obj,phase)
            arguments
                obj;
                phase uint32;
            end
            
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
                end
            end
        end %end of status funciton
    end
end