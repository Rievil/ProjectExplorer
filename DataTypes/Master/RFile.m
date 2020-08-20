classdef RFile < DataNode
    %READFILE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Filename;
    end
    
    methods
        function obj = RFile(File)
            obj.Filename=File;
        end
        
    end
end

