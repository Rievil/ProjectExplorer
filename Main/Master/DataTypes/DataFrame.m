classdef DataFrame < GUILib & OperLib
    %DATAFRAME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    %Interface of class
    methods (Abstract)
        Read(obj,varargin);
    end
    
    methods
        %constructor
        function obj = DataFrame(GuiParent)
            obj@GUILib(GuiParent);
            obj@OperLib;
        end
    end   
end

