classdef MainTable < DataFrame
    %MainTable is a PILOT type for all other possible measurments, ts
    %doesnt has to be present, but is higly recomended for the clarity and
    %clear structure of loaded data. PILOT type means, that it will guid
    %all other types which are present id datatypetable. PILOT has the key variable,
    %by which all other types will be sorted out. This design 
    properties
       SpecimensCount;
       KeyNames;
       UITable;
%        TypeSettings;
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
            obj2.TypeSettings=obj.TypeSettings;
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
        
        function result=ReadDb(obj)
        end
        %will read data started from dataloader
        function result=Read(obj,filename,opts)
%             obj.Filename=filename;
            result=struct;
            
            T=readtable(filename,opts);
            Data=table;
            TypeSettings=obj.TypeSettings;
            ColNum=size(TypeSettings,1);
            
            Desc=strings(ColNum,1);
            Desc(TypeSettings.IsDescriptive,1)="Descriptive";
            
            for i=1:ColNum
                type=char(obj.TypeSettings.ColType(i));
                
                SmallTable=table(OperLib.ConvertTabeType(type,T{:,obj.TypeSettings.ColNumber(i)}));
                SmallTable.Properties.VariableNames=obj.TypeSettings.Label(i);
                
                Data=[Data, SmallTable];
                if TypeSettings.IsDescriptive(i)==1
                    
                end
            end
            Data.Properties.VariableDescriptions=Desc;
            
            for i=1:size(Data,1)
                result.data(i).meas=Data(i,:);
            end
            
            KeyRow=obj.TypeSettings(obj.TypeSettings.Key>0,:);

%             result.data=Data;
            result.key=Data{:,KeyRow.ColNumber};
            result.count=size(Data,1);
            result.type=class(obj);
        end
        
        function Cat=GetCat(obj)
            Cat=table;
            for i=1:size(obj.Data,2)
                ClassName=lower(class(obj.Data{1,i}));
                Desc=obj.TypeSettings{1, 1}.IsDescriptive;
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
%             obj.TypeSettings{1}=event.Source.Data;
            obj.TypeSettings=event.Source.Data;
%             source.Children{3,1}.UserData=0;
        end       
        
        %adrow in table
        function TypeAdVar(obj)
            T=obj.UITable.Data;
            RowCount=size(T,1);
            CurrRow=obj.UITable.UserData;
            if RowCount>0
                T2=OperLib.MTBlueprint;
                T2.ColNumber=RowCount+1;
                if CurrRow>0 && CurrRow<RowCount
                    A=T(1:CurrRow,:);
                    B=T(CurrRow+1:end,:);
                    obj.UITable.Data=[A; T2; B];
                else
                    obj.UITable.Data=[obj.UITable.Data; T2]; 
                end
            end
            obj.UITable.UserData=0;
            obj.TypeSettings=obj.UITable.Data;
        end
        
        function TypeRemoveVar(obj)
            CurrRow=obj.UITable.UserData;
            if size(obj.UITable.Data,1)>1
                if CurrRow>0
                    obj.UITable.Data(CurrRow,:)=[];
                else
                    obj.UITable.Data(end,:)=[];
                end
                obj.UITable.UserData=0;
            end
            
        end
        
        function SetTabPos(obj,source,event)
            Row=event.Indices(1);
            event.Source.UserData=Row;
        end
        
        
        function EstimateColumns(obj,filename)
%             FileMap = OperLib.GetTypeDir(folder);
            tst=obj.UITable.Data;
            opts=MakeReadOpt(obj,filename,obj.Sufix);
            ColNames=categorical(["string","datetime","double","category"],{'string','datetime','double','category'},'ordinal',true);
            %ColNames=categorical(["string","datetime","double","category"],{'string','datetime','double','category'},'ordinal',true);
            fT=table;
            for i=1:numel(opts.VariableNames)
                 T=OperLib.MTBlueprint;
                 
                 switch char(opts.VariableTypes{i})
                     case 'char'
                         T.ColType=ColNames(1);
                     case 'double'
                         T.ColType=ColNames(3);
                     otherwise
                         T.ColType=ColNames(1);
                 end
                 
                 T.Key=false;
                 T.Label=string(opts.VariableNames{i});
                 T.ColNumber=i;
                 fT=[fT; T];
            end
            
            obj.TypeSettings=fT;
            obj.UITable.Data=fT;

                
                
            
        end
        
        function CreateTypeComponents(obj)
            g=uigridlayout(obj.GuiParent,'DeleteFcn',@obj.MCleanObj);
            g.RowHeight = {25,250,50,25};
            g.ColumnWidth = {'1x','2x',44,44};
            
            la=uilabel(g,'Text','Columns selection:');
            la.Layout.Row=1;
            la.Layout.Column=[1 4];
            
            
            if strcmp(class(obj.TypeSettings),'table')
                T=obj.TypeSettings;
            else
                T=OperLib.MTBlueprint;
            end
            
            uit = uitable(g,'Data',T,'ColumnEditable',true,...
                'ColumnWidth','auto','CellEditCallback',@(src,event)obj.SetVal(obj,event),...
                'CellSelectionCallback',@(src,event)obj.SetTabPos(obj,event),'UserData',0);
            obj.UITable=uit;
            

            
            uit.Layout.Row = 2;
            uit.Layout.Column = [1 4];
            
            MF=OperLib.FindProp(obj.Parent,'MasterFolder');
            
            IconFolder=[MF 'Master\GUI\Icons\'];
            IconFilePlus=[IconFolder 'plus_sign.gif'];
            IconFileMinus=[IconFolder 'cancel_sign.gif'];
            
            but1=uibutton(g,'Text','',...
                'ButtonPushedFcn',@obj.MTypeAdVar);
            
            but1.Layout.Row=1;
            but1.Layout.Column=3;
            but1.Icon=IconFilePlus;
            
            but2=uibutton(g,'Text','',...
                'ButtonPushedFcn',@obj.MTypeRemoveVar);
            but2.Layout.Row=1;
            but2.Layout.Column=4;
            but2.Icon=IconFileMinus;
            
            txt=sprintf(['Select composition of main table: by spinner select number of columns \n',...
                           'and choose the type of each column, column position in source file.\n',...
                           'IMPORTANT: there can be only one KeyColumn']);
                       
            la2=uilabel(g,'Text',txt);
            
           la2.Layout.Row=3;
           la2.Layout.Column=[1 4];
           obj.Children=[g;la;uit;but1;but2;la2];
           
           txt=sprintf('Load example for columns estimation:');
           la3=uilabel(g,'Text',txt);
           la3.Layout.Row=4;
           la.Layout.Column=[1 2];
           
           but3=uibutton(g,'Text','Load sample','ButtonPushedFcn',@obj.MLoadSample);
           but3.Layout.Row=4;
           but3.Layout.Column=[3 4];
        end
    end

    
    methods 
        function han=PlotType(obj,ax)

        end
        
        function Out=GetParams(obj,Name)
            Out=obj.Data;
        end
        
        function Out=GetVariables(obj)
            
        end
    end
    
    methods %callbacks
        function MLoadSample(obj,src,~)
            sbox=OperLib.FindProp(obj,'SandBoxFolder');
            suff=obj.Sufix;
            [file,path] = uigetfile(['*',char(suff)],'Select container',sbox);
            if ~isnumeric(file)
                if exist([path,file])
                    EstimateColumns(obj,[path,file]);
                end
            else
                
            end
        end
        
        function MTypeRemoveVar(obj,~,~)
            TypeRemoveVar(obj);
        end
        
        function MTypeAdVar(obj,~,~)
            TypeAdVar(obj);
        end
        
        function MCleanObj(obj,~,~)
            disp('MainTable closed');
            obj.UITable=[];
        end
    end
end