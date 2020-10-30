classdef MainTable < DataFrame
    %MainTable is a PILOT type for all other possible measurments, ts
    %doesnt has to be present, but is higly recomended for the clarity and
    %clear structure of loaded data. PILOT type means, that it will guid
    %all other types which are present id datatypetable. PILOT has the key variable,
    %by which all other types will be sorted out. This design 
    properties
       
    end
    
    methods
        function obj = MainTable(~)
            obj@DataFrame;
        end
        
        %will read data started from dataloader
        function Data=Read(obj,filename)
            T=readtable(filename,'ReadVariableNames',1,'Sheet','MainTable');
            Data=table;
            for i=1:size(obj.TypeSet{1},1)
                type=char(obj.TypeSet{1}.ColType(i));
                
                SmallTable=table(OperLib.ConvertTabeType(type,T{:,obj.TypeSet{1}.ColNumber(i)}));
                SmallTable.Properties.VariableNames=obj.TypeSet{1}.Label(i);
                
                Data=[Data, SmallTable];
                %Arr=OperLib.ConvertType(type,T{:,obj.TypeSet{1}.ColNumber(i)});
            end
            obj.Data=Data;
        end
%         
        function Tab=TabRows(obj)
            T=table;
            for i=1:size(obj.Data,1)
                Data=obj.Data(i,:);
                MT=MainTable;
                MT.Data=Data;
                T.MainTable(i)=MT;
            end
            Tab=T;
        end
        
        function Cat=GetCat(obj)
            Cat=table;
            for i=1:size(obj.Data,2)
                ClassName=lower(class(obj.Data{1,i}));
                if strcmp(ClassName,'categorical')
                    Cat=[Cat, obj.Data(:,i)];
                end
            end
        end
    end
    


    %Gui for data type selection 
    methods (Access = public)   
        %set property
        function SetVal(obj,val,idx)
            obj.TypeSet{idx}=val;
        end       
        %adrow in table
        function TypeAdRow(obj,Value,idx,Target)
            obj.TypeSet{idx}=Value;
            dim=size(Target.Data);
            if dim(1)~=Value
                if Value>dim(1)
                    Target.Data=[Target.Data; OperLib.MTBlueprint];
                    Target.Data{end,4}=Value;
                else
                    Target.Data(end,:)=[];
                end
                obj.TypeSet{Target.UserData{2}}=Target.Data;
            end
        end
        %will initalize gui for first time
        function InitializeOption(obj)
            Clear(obj);

            Target=DrawUITable(obj,OperLib.MTBlueprint,@SetVal);
            DrawSpinner(obj,[1 20],Target,@TypeAdRow);
            DrawLabel(obj,['Select composition of main table: by spinner select number of columns \n',...
                           'and choose the type of each column, column position in source file.\n',...
                           'IMPORTANT: there can be only one KeyColumn'],[300 60]);
        end
    end
    
    %Gui for plotter
    methods 
        function han=PlotType(obj,ax)

        end
    end
end

