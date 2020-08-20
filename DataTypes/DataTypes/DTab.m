classdef DTab < RFile
    %Dtab is basic file, which should always be present in some form in the
    %brute folder
    %it contain the names of all specimens which were measured during the
    %seisssion + small values, such as dimensions, wheight, or dimensions +
    %important categorical values, which are used for description of 
    properties
        Data table;
        Categorical table;
    end
    
    methods
        function obj = DTab(File)
            obj@RFile(File);
            
            d = System.IO.File.GetCreationTime(Filename);
            obj.CreationDate = datetime(d.Year, d.Month, d.Day, d.Hour, d.Minute, d.Second,'Format','dd.MM.yyyy');
            obj.Data=readtable(Filename);
            GetCategoricalArr(obj)
        end
        
        %get categorical vars from table
        function GetCategoricalArr(obj)
            T=obj.Data;
            VarNames=T.Properties.VariableNames;           
            n=0;
            Names(1:numel(VarNames))=string;
            CatTable=table;
            for i=1:numel(VarNames)
                text=lower(string(VarNames{i}));
                Index=find(contains(text,'cat'));
                if ~isempty(Index)
                    n=n+1;
                    TMP(:,1)=categorical(string(table2array(T(:,i))));
                    CatTable{:,n}=TMP;
                    Names(n)=['Cat' char(num2str(n))];
                end
            end
            
            if n>0
                Names(n+1:1:end)=[];  
                CatTable.Properties.VariableNames=Names;
                obj.Categorical=CatTable;                
            end
        end
    end
end

