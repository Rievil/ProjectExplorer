classdef AE < MeasObj
    properties (SetAccess = public)
        
    end
    
    methods (Access = public)
        function obj=AE(BruteFolder,DataType)
            obj@MeasObj(BruteFolder,DataType);
        end
    end
end