classdef MeasObj < handle
    properties (SetAccess = public)
        ID double; %filename within the project folder
        Date datetime; %oficial name for measurement
        LastChange datetime;
        Data; %data containers per that measurment (ae classifer, ie data, uz data, fc data, fct data)
        BruteFolder char; %folder with measured data, from which DataC construct itrs container
        ProjectFolder char;
        ExtractionState; %status of extraction of data from brute folder
        
        %if 'extracted', then we already have DataC created in project
        %folder, and we dont have to check if BruteFolder is avaliable, or
        %not
        SandBox char; 
        %this path may change between instances per users, its important 
        %for creation of new object
    end
    
    methods (Access = public)
        %constructor of object
        function obj=MeasObj(ID,ProjectFolder,SandBox)
            obj.ID=ID;
            obj.ProjectFolder=ProjectFolder;
            obj.BruteFolder=uigetdir(cd,'Select folder with your measurmenets');
            obj.Date=datetime(now(),'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss');    
            obj.SandBox=SandBox; 
        end
    end
    
    %save load delete operations
    methods (Access = private)

    end
end
