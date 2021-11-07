classdef Specimen < handle
    %SPECIMEN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ID;
        MeasID;
        Key;
        Data struct;
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
        
        function Compare(obj,spec)
            %obj is already in specimen group
%             if obj.Key==spec.Key
            CompareData(obj,spec.Data);
%             end
        end
    end
    
    methods (Access=private)
        function CompareData(obj,data)
            
            for i=1:size(data,2)
                mytype=data(i).type;
                ch=false;
                for j=1:size(obj.Data,2)
                    
                    newtype=obj.Data(j).type;
                    
                    if strcmp(mytype,newtype)
                        %updating alrady present data
                        ch=true;
                        obj.Data(j)=data(i);
                        break;
                    end
                end
                
                if ~ch
                    %adding new data to specimen
                    obj.Data=[obj.Data, data(i)];
                end
            end

        end
    end
end

