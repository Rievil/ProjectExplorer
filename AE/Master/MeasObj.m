classdef MeasObj < handle
    properties (SetAccess = public)
        FileName char; %filename within the project folder
        Date datetime; %oficial name for measurement
        DataC; %data containers per that measurment (ae classifer, ie data, uz data, fc data, fct data)
        BruteFolder char; %folder with measured data, from which DataC construct itrs container
    end
    
    methods (Access = public)
        %constructor of object
        function obj=MeasObj(BruteFolder,DataType)
            obj.BruteFolder=BruteFolder;
            switch DataType
                case 'AE'
                    
                case 'IE'
                case 'UZ'
                otherwise
            end
        end
    end
    
    %save load delete operations
    methods (Access = private)
        
    end
end
