classdef MainTable < DataFrame
    %MainTable is a PILOT type for all other possible measurments, ts
    %doesnt has to be present, but is higly recomended for the clarity and
    %clear structure of loaded data. PILOT type means, that it will guid
    %all other types which are present id datatypetable. PILOT has the key variable,
    %by which all other types will be sorted out. This design 
    properties
       SpecimensCount;
       KeyNames;
    end
    
    methods %main methods
        function obj = MainTable(parent)
            obj@DataFrame(parent);
            
            obj.ContainerType=OperLib.GetContainerTypes(1);
            obj.KeyWord="";
            obj.Sufix=OperLib.GetSuffixTypes(1);
        end
        

        function Tab=TabRows(obj)
            T=table;
            for i=1:size(obj.Data,1)
                Data=obj.Data(i,:);
                MT=Copy(obj);
                MT.Data=Data;
                MT.KeyNames=[];
                MT.KeyNames=Data.Name;
                MT.SpecimensCount=1;
                T.MainTable(i)=MT;
            end
            Tab=T;
        end
        
        function [T]=GetVarNames(obj)
            
        end
        
        function obj2=Copy(obj)
            obj2=MainTable;
            obj2.SpecimensCount=obj.SpecimensCount;
            obj2.KeyNames=obj.KeyNames;
            obj2.Data=obj.Data;
            obj2.Filename=obj.Filename;
            obj2.Folder=obj.Folder;
            obj2.GuiParent=obj.GuiParent;
            obj2.Count=obj.Count;
            obj2.Children=obj.Children;
            obj2.TypeSet=obj.TypeSet;
            obj2.Init=obj.Init;
            obj2.Pos=obj.Pos;
        end
        
        function Data=PackUp(obj)
            TMP=obj.Data;
            P=TMP.Properties;
            idx=[];
            TMP2=table;
            for col=1:size(TMP,2)
                
                ClName=class(TMP{1,col});
                if strcmp(ClName,'categorical')
                    Var=string(TMP{1,col});
                    Name=TMP.Properties.VariableNames(col);
                    idx=[idx; col];
                    TMP2=[TMP2, table(Var,'VariableNames',Name)];
                end
            end
            TMP(:,idx)=[];
            TMP=[TMP, TMP2];
            Data=TMP;
        end
    end
    
    %reading methods
    methods 
                %will read data started from dataloader
        function Data=Read(obj,filename)
            obj.Filename=filename;
            T=readtable(filename,'ReadVariableNames',1,'Sheet','MainTable');
            Data=table;
            TypeSet=obj.TypeSet{1,1};
            SpecNum=size(obj.TypeSet{1},1);
            Desc=strings([SpecNum 1]);
            Desc(TypeSet.IsDescriptive,1)="Descriptive";
            
            for i=1:SpecNum
                type=char(obj.TypeSet{1}.ColType(i));
                
                SmallTable=table(OperLib.ConvertTabeType(type,T{:,obj.TypeSet{1}.ColNumber(i)}));
                SmallTable.Properties.VariableNames=obj.TypeSet{1}.Label(i);
                
                Data=[Data, SmallTable];
                if TypeSet.IsDescriptive(i)==1
                    
                end
                %Arr=OperLib.ConvertType(type,T{:,obj.TypeSet{1}.ColNumber(i)});
                
            end
            Data.Properties.VariableDescriptions=Desc;
            
            
            KeyRow=obj.TypeSet{1,1}(obj.TypeSet{1,1}.Key>0,:);
            obj.SpecimensCount=size(Data,1);
            obj.KeyNames=Data{:,KeyRow.ColNumber};
            
            obj.Data=Data;
        end
        
        function Cat=GetCat(obj)
            Cat=table;
            for i=1:size(obj.Data,2)
                ClassName=lower(class(obj.Data{1,i}));
                Desc=obj.TypeSet{1, 1}.IsDescriptive;
                if Desc(i,1)==true
                    Cat=[Cat, obj.Data(:,i)];
                end
            end
        end
        
    end

    %Gui for data type selection 
    methods (Access = public)   
        %set property
        function SetVal(obj,src,event)
            obj.TypeSet{1}=event.Source.Data;
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
            SetParent(obj,'type');
%             Clear(obj);
            HideComponents(obj);
            
            if numel(obj.Children)>0
                ShowComponents(obj)
            else
                CreateTypeComponents(obj);
            end
            
%             
%             Target=DrawUITable(obj,OperLib.MTBlueprint,@SetVal,200);
%             DrawSpinner(obj,[1 20],Target,@TypeAdRow);
%             DrawLabel(obj,['Select composition of main table: by spinner select number of columns \n',...
%                            'and choose the type of each column, column position in source file.\n',...
%                            'IMPORTANT: there can be only one KeyColumn'],[300 60]);
        end
        
        function CreateTypeComponents(obj)
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,300,22,22};
            g.ColumnWidth = {'1x','2x'};
            
            la=uilabel(g,'Text','Columns selection:');
            la.Layout.Row=1;
            la.Layout.Column=[1 2];
            
            
            uit = uitable(g,'Data',OperLib.MTBlueprint,'ColumnEditable',true,...
                'ColumnWidth','auto','CellEditCallback',@(src,event)obj.SetVal(obj,event));
            uit.Layout.Row = 2;
            uit.Layout.Column = [1 2];
            
            
            
            obj.Children={g;la;uit};
        end
    end
    
    %Gui for plotter
    methods 
        function han=PlotType(obj,ax)

        end
        
        function Out=GetParams(obj,Name)
            Out=obj.Data;
        end
        
        function Out=GetVariables(obj)
            
        end
    end
end

