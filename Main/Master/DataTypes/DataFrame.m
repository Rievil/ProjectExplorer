classdef DataFrame < GUILib & OperLib
    %DATAFRAME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    %Interface of class
    methods (Abstract)
        Read(obj,varargin);
    end
    
    methods
        %constructor
        function obj = DataFrame(varargin)
            obj@GUILib;
            obj@OperLib;
        end
        
    end
end

