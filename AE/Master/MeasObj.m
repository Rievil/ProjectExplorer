classdef MeasObj < handle
    properties (SetAccess = public)
        Date datetime;
        DataC; %data container (ae classifer, ie data, uz data, fc data, fct data)
        BruteFolder char; %folder with measured data, from which DataC construct itrs container
    end
    
    methods (Access = public)
        %constructor of object
        function obj=MeasObj(BruteFolder)
            obj.BruteFolder=BruteFolder;
        end
    end
    
    %save load delete operations
    methods (Access = private)
    end
end
