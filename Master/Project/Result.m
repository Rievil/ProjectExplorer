classdef Result < handle
    %RESULT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data
        Key
        Count
        Type
    end
    
    methods
        function obj = Result(data,key,count,type)
            obj.Data=data;
            obj.Key=key;
            obj.Count=count;
            obj.Type=type;
        end
    end
end

