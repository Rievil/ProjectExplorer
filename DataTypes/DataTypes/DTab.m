classdef DTab < RFile
    %Dtab is basic file, which should always be present in some form in the
    %brute folder
    %it contain the names of all specimens which were measured during the
    %seisssion + small values, such as dimensions, wheight, or dimensions +
    %important categorical values, which are used for description of 
    properties
        RawData table;
        Categorical table;
        NameKey (:,1) string;
    end
    properties 
        VarNames cell;
    end
    
    methods
        function obj = DTab(Filename)
            obj@RFile(Filename);
            
            
            obj.RawData=readtable(Filename,'PreserveVariableNames',true);
            GetCategoricalArr(obj);
            ScanColumns(obj);
        end
        
        %scan cols for different types of data
        function ScanColumns(obj)
            obj.VarNames=obj.RawData.Properties.VariableNames;           
            for i=1:numel(obj.VarNames)
                text=string(obj.VarNames{i});
                switch lower(text)
                    case 'name'
                        obj.NameKey=obj.RawData{:,i};
                    case 'velocity'
                        
                    case 'aelength'
                        
                    otherwise
                end
            end
        end
        
        %get categorical vars from table
        function GetCategoricalArr(obj)
            obj.VarNames=obj.RawData.Properties.VariableNames;   
            n=0;
            Names(1:numel(obj.VarNames))=string;
            obj.Categorical=table;
            for i=1:numel(obj.VarNames)
                text=lower(string(obj.VarNames{i}));
                Index=find(contains(text,'cat'));
                if ~isempty(Index)
                    n=n+1;
                    TMP(:,1)=categorical(string(table2array(obj.RawData(:,i))));
                    obj.Categorical{:,n}=TMP;
                    Names(n)=['Cat' char(num2str(n))];
                end
            end
            
            if n>0
                Names(n+1:1:end)=[];  
                obj.Categorical.Properties.VariableNames=Names;            
            end
        end
    end
end

