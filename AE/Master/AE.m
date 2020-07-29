classdef AE < MeasObj
    properties (SetAccess = public)
    end
    
    methods (Access = public)
        function obj=AE(folder)
            obj@MeasObj(folder);
        end
    end
end