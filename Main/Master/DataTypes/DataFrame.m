classdef DataFrame < GUILib & OperLib
    %DATAFRAME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data; %universal container, Data might be table, array, structure
        Filename; %for files type
        Folder; %for folder types
    end
    
    %Interface of class
    methods (Abstract)
        Read(obj);
        TabRows(obj);
        Copy(obj);
        PackUp(obj);
    end
    
    methods
        %constructor
        function obj = DataFrame(~)
            obj@GUILib;
            obj@OperLib;
        end
        
        function SetTypeSet(obj,TypeSet)
            obj.TypeSet=TypeSet;
        end
    end   
end

