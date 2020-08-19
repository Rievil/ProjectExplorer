classdef DataCore < handle
    properties
        PO ProjectObj;
        Set double;   
        Data struct;
        Count double;
        Cat table;
        
    end
    properties (Hidden)
        RawData struct;
    end
    
    methods (Access = public)
        function obj = DataCore(ProjectObj,Set)
            obj.PO=ProjectObj; %handle to project obj
            obj.Set=Set; %current set            
        end
        
        function PullData(obj)
            obj.RawData=PullData(obj.PO,obj.Set); 
            obj.Count=size(obj.RawData,2);
            CleanData(obj);
        end
        
        function [x,y]=GetData(obj)
            x=obj.Data.Time;
            y=obj.Data.Force;
        end
    end
    
    methods (Access = private)
        function CleanData(obj)
            FirstName=string(obj.RawData(1).Names);
            for i=1:obj.Count-1
                SecondName=obj.RawData(i+1).Names;
                [FirstName] = intersect(FirstName,SecondName,'legacy');
            end
            MinimumNames=FirstName;
            %i have minimum same amount of common fields, lets delete the
            %orphans
            for i=1:obj.Count
                [A,B] = ismember(obj.RawData(i).Names,MinimumNames);
                
                FName=obj.RawData(i).Names(~A);
                obj.RawData(i).PulledData=rmfield(obj.RawData(i).PulledData,FName);
                
                obj.RawData(i).Names(B==0,:)=[];
                
                obj.Data=[obj.Data, obj.RawData(i).PulledData];
                T=obj.RawData(i).Cat;
                obj.Cat=[obj.Cat; T];
            end
            
            obj.RawData=[];
        end
    end
end

