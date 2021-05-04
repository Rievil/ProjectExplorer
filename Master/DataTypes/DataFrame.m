classdef DataFrame < OperLib & GUILib
    %DATAFRAME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data; %universal container, Data might be table, array, structure
        Filename; %for files type
        Folder; %for folder types
        Parent;
    end
    
    properties %File / folder container
        ContainerType;
        KeyWord;
        Sufix;
        KeyName;
        SheetName;
        HeadersRow;
    end
    
    %Interface of class
    methods (Abstract)
        Read(obj);
        TabRows(obj);
        Copy(obj);
        PackUp(obj);
        GetVariables(obj);
        
        GetVarNames;
        %GetVarByName
    end

    methods
        %constructor
        function obj = DataFrame(parent)
            obj@GUILib;
            obj@OperLib;
            obj.Parent=parent;
        end
        
        function SetTypeSet(obj,TypeSet)
            obj.TypeSet=TypeSet;
        end
        
        function SetKeyWord(obj,key)
            obj.KeyWord=key;
        end
        
        function SetSuffix(obj,suffix)
            obj.Sufix=suffix;
        end
        
        function SetConType(obj,type)
            obj.ContainerType=type;
        end
    end   
    
    %Gui for datatypes
    methods
        
    end
end

