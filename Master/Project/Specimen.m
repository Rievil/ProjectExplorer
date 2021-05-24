classdef Specimen < handle
    %SPECIMEN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ID;
        MeasID;
        Key;
        Data;
        Version;
        Parent;
%         Features;
%         Metadata;
    end
    
    
    methods
        function obj = Specimen(parent) %parent je experiment
            obj.Parent=parent;
        end
        
        function T=GetT(obj)
            if numel(obj.ID)>0
                T=table(obj.ID,obj.Key,obj.MeasID,{obj.Data},...
                    'VariableNames',{'ID','Key','MeasID','Data'});
            else
                T=table(0,obj.Key,obj.MeasID,{obj.Data},...
                    'VariableNames',{'ID','Key','MeasID','Data'});                
            end
        end
    end
end

