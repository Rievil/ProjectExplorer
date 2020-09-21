classdef DataFrame < GUILib & OperLib
    %DATAFRAME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data; %universal container, Data might be table, array, structure
    end
    
    %Interface of class
    methods (Abstract)
        Read(obj);
    end
    
    methods
        %constructor
        function obj = DataFrame(~)
            obj@GUILib;
            obj@OperLib;
        end
    end   
end

