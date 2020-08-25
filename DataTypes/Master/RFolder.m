classdef RFolder < DataNode
    %READFOLDER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       Folder char;
    end
    
    methods
        function obj = RFolder(Folder)
            obj.Folder=Folder;
            %READFOLDER Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
    end
end

