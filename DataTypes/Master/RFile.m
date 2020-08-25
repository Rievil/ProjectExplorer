classdef RFile < DataNode
    %READFILE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Filename char;
        Data cell;
    end
    
    methods
        function obj = RFile(Filename)
            obj.Filename=Filename;
            d = System.IO.File.GetCreationTime(Filename);
            obj.CreationDate = datetime(d.Year, d.Month, d.Day, d.Hour, d.Minute, d.Second,'Format','dd.MM.yyyy');
        end
        
    end
end

