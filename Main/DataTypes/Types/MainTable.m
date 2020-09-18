classdef MainTable < DataFrame
    %MAINTABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = MainTable(varargin)
            obj@DataFrame;
            if numel(varargin)>0
                Tab(i).T=readtable([files(Index).folder '\' files(Index).name]);
            else
                
            end
            %MAINTABLE Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function Read(obj,varargin)
            
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

