classdef Press < DataFrame
   
    properties
       Name char;
       ColNumbers=0;
    end
    
    methods %main methods
        function obj = Press(parent)
            obj@DataFrame(parent);
            
            obj.ContainerType=OperLib.GetContainerTypes(1);
            obj.KeyWord="";
            obj.Sufix=OperLib.GetSuffixTypes(1);
        end
        

        function Tab=TabRows(obj)
            T=table;
            for i=1:size(obj.Data,1)
                PR=Copy(obj);
                PR.Data=obj.Data{i,1}.Data;
                T.Press(i)=PR;
            end
            Tab=T;
        end
        
                
        function [T]=GetVarNames(obj)
            
        end
        
        function obj2=Copy(obj)
            obj2=Press;
            obj2.Name=obj.Name;
            obj2.ColNumbers=obj.ColNumbers;
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
            T=table;
            for i=1:size(obj.Data,2)
                T{1,i}={obj.Data(:,i)};
                T.Properties.VariableNames{i}=obj.Data.Properties.VariableNames{i};
            end
            Data=T;
        end
        
    end
    
    methods %reading methods
                %will read data started from dataloader
        function Out=Read(obj,filename)
            obj.ColNumbers=3;
            obj.Filename=filename;
            opts=detectImportOptions(filename,'NumHeaderLines',2,...
                'Sheet','Test Curve Data');
            
            %K:\ZEDO_DATA_Export\200408_Melichar_THIS
            INData=readtable(filename,opts);    
            %INData=ResamplePressData(obj,INData);
            
            DCount=size(INData,2);
            VarNames={'Time','Force','Deff'};
            T=table;
            n=0;
            try
                for i=1:obj.ColNumbers:DCount
                    Arr2=INData(:,i:i+obj.ColNumbers-1);
                    Arr=zeros([size(Arr2,1), obj.ColNumbers]);
                    for j=1:size(Arr,2)
                        TMP2=[];
                        TMP2=Arr2{:,j};
                        if class(TMP2)=="double"
                            Arr(:,j)=TMP2;
                        else
                            Arr(:,j)=0;
                        end
                    end
                    
                    Arr(isnan(Arr(:,1)),:)=[];
                    PR=Press;
                    for j=1:obj.ColNumbers
                        PR.Data=[PR.Data, table(Arr(:,j),'VariableNames',VarNames(j))];
                    end
                    n=n+1;
                    T.Press(n)=PR;
                end
                obj.Data=T;
                Out=T;
            catch ME
                error(['Error with file: ''' filename, ...
                    ''' with specimen: ''' char(num2str(n)) '''\n', ...
                    'on column: ''' char(num2str(i)) '''']);
            end
        end
        
        function T=GetTension(obj,MT)
            TenTMP=3/2*(MT.Data.VzdPodpor*0.001)/((MT.Data.B*0.001)*(MT.Data.T*0.001)^2);
            Strength=obj.Data.Force.*TenTMP*1e-6;
            T=obj.Data;
            
            if sum(contains(obj.Data.Properties.VariableNames,'Strength'))>0
                obj.Data.Strength=Strength;
            else
                obj.Data=[obj.Data, table(Strength,'VariableNames',{'Strength'})];
            end
        end
    end
    %private methods for operating the variables
    methods (Access = private) 
        function [T]=ResamplePressData(obj,inT)
            T=table;
            TargetFreq=2;
            for i=1:2:size(inT,2)-1
                Time=inT{:,i};
                OrgFreq=1/(Time(2)-Time(1));
                if OrgFreq<TargetFreq
                    
                    [N,D] = rat(TargetFreq/OrgFreq);                                       % Rational Fraction Approximation
                    Check = [TargetFreq/OrgFreq, N/D] ;


                    tmpTime=resample(inT{:,i},N,D);
                    tmpArr=resample(inT{:,i+1},N,D);
                    
                    T{:,i}=tmpTime;
                    T{:,i+1}=tmpArr;
                else
                    T{:,i}=inT{:,i};
                    T{:,i+1}=inT{:,i+1};
                end
            end
        end
    end
    
    %Gui for data type selection 
    methods (Access = public)   
        
        function CreateTypeComponents(obj)
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,250,50};
            g.ColumnWidth = {'1x','2x',44,44};
            
            la=uilabel(g,'Text','Selection of data variables:');
            la.Layout.Row=1;
            la.Layout.Column=[1 4];
                        
            uit = uitable(g,'Data',OperLib.PRBlueprint,'ColumnEditable',true,...
            'ColumnWidth','auto','CellEditCallback',@(src,event)obj.SetVal(obj,event),...
            'UserData',0);
            uit.Layout.Row=2;
            uit.Layout.Column=[1 4];
        
            cbx = uicheckbox(g,'Text','Order from main table?');
            cbx.Layout.Row=3;
            cbx.Layout.Column=[1 4];
            
            MF=OperLib.FindProp(obj.Parent,'MasterFolder');
            
            IconFolder=[MF 'Master\GUI\Icons\'];
            IconFilePlus=[IconFolder 'plus_sign.gif'];
            IconFileMinus=[IconFolder 'cancel_sign.gif'];
            
            but1=uibutton(g,'Text','',...
                'ButtonPushedFcn',@(src,event)obj.TypeAdVar(obj,event));
            but1.Layout.Row=1;
            but1.Layout.Column=3;
            but1.Icon=IconFilePlus;
            
            but2=uibutton(g,'Text','',...
                'ButtonPushedFcn',@(src,event)obj.TypeRemoveVar(obj,event));
            but2.Layout.Row=1;
            but2.Layout.Column=4;
            but2.Icon=IconFileMinus;
            
            obj.Children={g;la;uit;cbx;but1;but2};
        end
        
        
        %set property
        function SetVal(obj,source,event)
%             obj.TypeSet{idx}=val;
            obj.TypeSettings=event.source.Data;
        end
        
        %adrow in table
        function TypeAdVar(obj,source,event)
            T=source.Children{3,1}.Data;
            RowCount=size(T,1);
            CurrRow=source.Children{3,1}.UserData;
            if RowCount>0
                T2=OperLib.PRBlueprint;
                T2.ColOrder=RowCount+1;
                if CurrRow>0 && CurrRow<RowCount
                    A=T(1:CurrRow,:);
                    B=T(CurrRow+1:end,:);
                    source.Children{3,1}.Data=[A; T2; B];
                else
                    source.Children{3,1}.Data=[source.Children{3,1}.Data; T2]; 
                end
            end
            source.Children{3,1}.UserData=0;
            obj.TypeSettings=source.Children{3,1}.Data;
        end
    end
    
    %Gui for plotter
    methods 
        function han=PlotType(obj,ax)
            yyaxis(ax,'left');
            hold(ax,'on');
            plot(ax,obj.Data{:,1},obj.Data{:,2});
            xlabel(ax,'Time \it t \rm [s]');
            ylabel(ax,'Force \it F \rm [N]');
        end
        
        function Out=GetParams(obj,Name)
            Out=struct;
            idx=round(find(obj.Data.Force==max(obj.Data.Force),1)*1.1,0);
            if idx>numel(obj.Data.Force)
                idx=numel(obj.Data.Force);
            end
            
            for i=1:size(obj.Data,2)
                Out.(obj.Data.Properties.VariableNames{i})=table2array(obj.Data(1:idx,i));
            end
            Out.EndTime=obj.Data.Time(idx);
            
        end
        
        function Out=GetVariables(obj)
            
        end
    end
end

