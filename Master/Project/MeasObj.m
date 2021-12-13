classdef MeasObj < Node
    properties (SetAccess = public)
        ID double; %number 
%         FName char;  %filename within the project folder - important for deleting
        Name char;
        
        Metadata struct;
        MeasDate datetime;
%         Date datetime; %oficial name for measurement, copy erliest date from files
%         LastChange datetime; %when change happen
%         Data; %data containers per that measurment (ae classifer, ie data, uz data, fc data, fct data)
        BruteFolder char; %folder with measured data, from which DataC construct itrs container
        BruteFolderSet=false;
        TypeTable
        ExtractionState; %status of extraction of data from brute folder
        Key=0;
        MainTable;
        Selector;
        ClonedTypes=0;
        TotalTable;
        Version;
        ExpHandle Experiment;
        SpecimenCount;    
        UITLoad;
        LoadOptions table;
    end
    
    
    %event listeners
    properties
        eReload
    end

    events
        TotalTableChange;
    end
    
    %Main methods, consturction, destruction etc.
    methods (Access = public)
        %constructor of object
        function obj=MeasObj(Parent)
            obj@Node;
            obj.Parent=Parent;

            obj.Metadata=struct;
            obj.Metadata.Date=datetime(now(),'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss');    
            obj.ExpHandle=obj.Parent.Parent;
            obj.eReload=addlistener(obj.Parent,'eReload',@obj.ReLoadData);
            obj.Version=0;
        end
        
        function SetName(obj)
            obj.Name=sprintf('%d - %s',obj.ID,datestr(obj.Metadata.Date,'dd.MM.yyyy'));
        end
        

        %V�b�r adres��e s m��en�mi
        function GetBruteFolder(obj)
            msg='Pick folder with formated data as set in experiment';
            if numel(obj.BruteFolder)==0
                obj.BruteFolder=uigetdir(cd,msg);  
                if numel(obj.BruteFolder)>1
                    obj.BruteFolderSet=1;
                else
                    obj.BruteFolder="none";
                    obj.BruteFolderSet=0;
                end
            else
                folder=uigetdir(cd,msg);  
                if numel(folder)<2
                    
                else
                    obj.BruteFolder=[folder '\'];
                    obj.BruteFolderSet=1;
                end
                
            end
        end
        
        function MakeTotalTable(obj,Sel)
            T=table;
            T.Name=obj.Data.Name;
            
            if obj.Key==true
                CatTab=StackCat(obj);
            end
            
            if isempty(obj.Selector)
                ResetSelectors(obj)
            end
            T=[T, obj.Selector(:,Sel), CatTab];
            obj.TotalTable=T;
        end
        
        
        %prepare tab for inspection of signle specimen
        function [Tab]=Inspect(obj,Row)
            Specimen=obj.Data.Measuremnts(Row);
            RowNames=fieldnames(Specimen);
            for i=1:numel(RowNames)
                MyValues{i} = getfield(Specimen,RowNames{i});
            end           
            %Tab=table(MyValues','RowNames',RowNames','VariableNames',{'Value'});
            Tab=table(RowNames,MyValues','VariableNames',{'Parameters','Value'});
        end
        
        %get data for data core
        function [Data]=PullData(obj,Set)     
            Idx=table2array(obj.Selector(:,Set));
            Data=obj.Data(Idx,:);
        end
    end
    
    %Abstract methods
    methods 
        function FillUITab(obj,Tab)
            p=OperLib.FindProp(obj,'UITab');
            SetGuiParent(obj,p);
            InitializeOption(obj);
        end
        
        function ClearIns(obj)
        end
        
        function stash=Pack(obj)
            stash=struct;
            stash.ID=obj.ID;
            stash.Name=obj.Name;
            stash.Metadata=obj.Metadata;
            stash.BruteFolder=obj.BruteFolder;
            stash.BruteFolderSet=obj.BruteFolderSet;
            stash.SpecimenCount=obj.SpecimenCount;
            stash.LoadOptions=obj.LoadOptions;
            stash.MeasDate=obj.MeasDate;
        end
        
        function Populate(obj,stash)
            obj.ID=stash.ID;
            obj.Name=stash.Name;
            obj.Metadata=stash.Metadata;
            obj.BruteFolder=stash.BruteFolder;
            obj.BruteFolderSet=stash.BruteFolderSet;
            obj.SpecimenCount=stash.SpecimenCount;
            
            if isfield(stash,'LoadOptions')
                obj.LoadOptions=stash.LoadOptions;
            end
            
            if isfield(stash,'MeasDate')
                obj.MeasDate=stash.MeasDate;
            end
            
            FillNode(obj)
        end
        
        function FillNode(obj)
            iconName=[OperLib.FindProp(obj,'MasterFolder') '\Master\Gui\Icons\Meas.gif'];
            Name=char(sprintf('%d - %s',obj.ID,obj.Name));
            obj.TreeNode=uitreenode(obj.Parent.TreeNode,'Text',Name,...
                'Icon',iconName,...
                'NodeData',{obj,'meas'});
            
            UIFig=OperLib.FindProp(obj,'UIFig');
            cm = uicontextmenu(UIFig);
            m1 = uimenu(cm,'Text','Remove','MenuSelectedFcn',@obj.RemoveNode);%,...
            m2 = uimenu(cm,'Text','Read','MenuSelectedFcn',@obj.MenuRead);
            obj.TreeNode.ContextMenu=cm;
        end
        
        function node=AddNode(obj)
            
        end
        
        function RemoveNode(obj,src,~)
            DeleteMeas(obj.Parent,obj.ID);
            delete(obj.TreeNode);
            
            SpecGroup=OperLib.FindProp(obj,'SpecGroup');
            RemoveSpecimens(SpecGroup,'MeasID',obj.ID);
            obj.delete;
        end
        
    end

    %Selectors
    methods
        %Initiate selector
        function InitSel(obj)
            Default_set(1:obj.Count,1)=false;
            obj.Selector=table(Default_set);            
        end
        
        %Change Selector
        function SetSelector(obj,Row,Val,Set)
            obj.Selector{Row,Set}=Val;
            %saveobj(obj);
        end
        
        %add Selector rows
        function AddSelRows(obj,nSet,Name)
            Selector(1:1:obj.Count,1)=false;
            %obj.Selector=[obj.Selector, table(Selector)];
            obj.Selector = addvars(obj.Selector,Selector,'NewVariableNames',char(Name));
        end
        
        function CheckSel(obj,MSelector)
            ResetSelectors(obj);
        end
        
        function ResetSelectors(obj)
            obj.Selector=[];
            value=false([obj.Count,1]);
            if size(obj.Selector,1)>0
                InitSel(obj);
            end
            
            for i=1:size(obj.Parent.SelectorSets,2)
                obj.Selector=[obj.Selector, table(value,'VariableNames',{obj.Parent.SelectorSets(i).Description})];
            end
        end
        
        %delete sel column
        function DeleteSelCol(obj,nSet)
            obj.Selector(:,nSet)=[];
        end
    end
    

    
    %Save, load, delete, copy methods
    
    methods %Reading methods
        
        
        
        function MenuRead(obj,src,~)
            ReadData(obj);
        end
        
        function FindMainTable(obj)
        end
        
        
        function ReadData(obj)
            if obj.BruteFolderSet==0
                GetBruteFolder(obj);
            end
            obj.Version=obj.Version+1;
            obj.TypeTable=OperLib.FindProp(obj,'TypeSettings');
            
            AllTypes=OperLib.GetTypes;
            CurrentTypes=obj.TypeTable.DataType;
            
            MTIdx=find(CurrentTypes==AllTypes(1));
            
            if MTIdx>0
                %Experiemnts has a maintable
                obj.Key=sum(obj.TypeTable.TypesObj{MTIdx,1}.TypeSettings.Key);
            else
                %Experiment doesnt has a maintable
            end
            

            FileMap = OperLib.GetTypeDir(obj.BruteFolder);
            
            result=struct;
            
            TypeCount=size(obj.TypeTable,1);
            f=waitbar(0,'Loading all data');
            for i=1:TypeCount
                order=obj.LoadOptions.Name(i);
                if obj.LoadOptions.LoadRule(i)
                    obj2=obj.TypeTable.TypesObj{obj.TypeTable.DataType==order,1};
                    waitbar(i/(TypeCount+2),f,char(sprintf('Loading: ''%s'' data type',class(obj2)))); 
                    subresult=ReadContainer(obj2,FileMap);
                    
                    if numel(fieldnames(result))==0
                        result=subresult;
                    else
                        result=[result, subresult];
                    end
                    
%                     if obj2.MainKeys
%                         obj3=FindMainTable(obj.Parent);
%                         result.Key=obj3.Key;
%                     end
%                     
                    if obj.LoadOptions.AllKeysThere(i)==true
%                         MakeSpecimens(obj,result,result.key);
%                         MakeMainSpec(obj,subresult);
%                         break;
                    end
                end
            end
            
            waitbar((i+1)/(TypeCount+2),f,'Storing variables');
            
            MakeMainSpec(obj,result);
%             
%             
%             
%             %check for key similarities
%             ch=0;
%             for i=1:size(result,2)
%                 if i==1
%                     keyold=result(i).key;
%                 else
%                     key=result(i).key;
%                     if numel(key)==numel(keyold)
%                         [A]=intersect(lower(keyold),lower(key));
%                         if numel(A)==numel(key)
%                             ch=1;
%                             keyold=key;
%                         else
%                             break;
%                             ch=0;
%                         end
%                     else
%                         result(i).key=keyold;
%                     end
%                 end
%             end
%             
%             if ch==1
%                 finalkey=keyold;
%             else
%                 %key is corupted
%             end
            
%             MakeSpecimens(obj,result,finalkey);
            waitbar(1,f,'Finished');
            pause(1);
            close(f);
            
        end
        
        function MakeMainSpec(obj,result)
            SpecGroup=OperLib.FindProp(obj,'SpecGroup');
%             try
            for k=1:size(result,2)
                for i=1:size(result(k).key,1)

                    spec=Specimen(SpecGroup);
                    data=struct;
                    for j=1:size(result,2)
                        data(j).data=result(j).data(i).meas;
                        data(j).type=result(j).type;
                    end


                    spec.MeasID=obj.ID;
                    spec.Data=data;

                    if numel(char(result(k).key(i)))>0
                        spec.Key=result(k).key(i);    
                    else
                        %create new key if source doesnt have it
                        spec.Key=string(num2str(i));
                    end

                    if SpecGroup.CheckUnqKey(spec)

                        if SpecGroup.SpecExist(spec.Key)
                            UpdateSpec(SpecGroup,spec);
                        else
                            AddSpecimen(SpecGroup,spec);
                        end
                    else

                    end
                end
            end
%             catch ME
%                 fprintf('Meas n. %d\n',k);
%             end
            
        end
        
        function MakeSpecimens(obj,result,key)
            SpecGroup=OperLib.FindProp(obj,'SpecGroup');
            n=0;
            for i=1:numel(key)
                data=struct;
                spec=Specimen(SpecGroup);
                for j=1:size(result,2)
                    Idx=find(result(j).key==key(i));
                    
                    data(j).data=result(j).data(Idx).meas;
                    data(j).type=result(j).type;
                end
                
                spec.Data=data;
                spec.MeasID=obj.ID;
                spec.Key=key(i);
                
                AddSpecimen(SpecGroup,spec);
                
            end
            
        end

        function ReLoadData(obj,src,~)

            if ~exist(obj.BruteFolder, 'dir')
                GetBruteFolder(obj)  
                if obj.BruteFolderSet==1
                    ReadData(obj);
                end
                
            else
                if obj.BruteFolderSet==1
                    ReadData(obj);
                end
            end

        end

        function [Cat]=StackCat(obj)
            Cat=table;
            if obj.Key==true
                for i=1:size(obj.Data,1)
                    Cat=[Cat; GetCat(obj.Data.MainTable(i))];
                end
            end
        end
    end
    
    methods (Access = private)
        function ReadFile(obj)
            
        end
        
        function ReadFolder(obj)
            
        end
    end
    
    %static methods
    methods (Static)
        
    end
    
    %set get methods
    methods (Access = public) 
        
        %Set datatypetable
        function SetDataTypes(obj,TypeTable)
            Types=TypeTable;
        end
        
        %set brute folder
        function SetBruteFolder(obj,BruteFolder)
            obj.BruteFolder=BruteFolder;
        end
    end
    
    %Gui methods
    methods 
        function ChangeName(obj,event)
            obj.Name=event.Value;
            obj.TreeNode.Text=[char(num2str(obj.ID)) ' - ' char(event.Value)];
        end
        
        function ChangeBruteFolder(obj,event)
            GetBruteFolder(obj);
            event.Source.UserData.Value=obj.BruteFolder;
        end
        
        function UpdateLoadOption(obj)
%             T1=obj.ExpHandle.TypeSettings;
            names=string(obj.ExpHandle.TypeSettings.DataType(:));
            cnames=string(obj.LoadOptions.Name(:));
            for i=1:numel(names)
                A=contains(cnames,names(i));
                if ~sum(A)>0
%                     T=
                    obj.LoadOptions=MakeOptionTable(obj);
                    break;
                end
            end
            
        end
        
        function T=MakeOptionTable(obj)
            TT=obj.ExpHandle.TypeSettings;
            T=table;
            typescount=size(TT,1);
            count=categorical(1:1:typescount,'Ordinal',true);
            for i=1:typescount
                T=[T; table(TT.DataType(i),count(i),true,false,...
                    'VariableNames',{'Name','Order','LoadRule','AllKeysThere'})];
            end
        end
        
        function ReadOptionChange(obj,T,col)
            
            
            switch col
                case 2
                    arr=double(T{:,col});
                    arr2=double(obj.LoadOptions{:,col});
                    
                    oldIdx=double(arr)~=double(arr2);                    
                    oldPos=arr2(arr(oldIdx));
                    
                    newIdx=arr2==arr(oldIdx);
                    
                    idx=arr2==arr(newIdx);
                    
                    old=obj.LoadOptions{oldIdx,col};
                    new=T{newIdx,col};
                    
                    obj.LoadOptions{newIdx,col}=old;
                    obj.LoadOptions{oldIdx,col}=new;
                    
                    obj.LoadOptions = sortrows(obj.LoadOptions,'Order','Ascend');
                case 3
                    obj.LoadOptions(:,col)=T(:,col);
                case 4
                    obj.LoadOptions(:,col)=T(:,col);
            end
            
            disp('change');
        end
        
        function InitializeOption(obj)
            
            SetParent(obj,'project');
            Clear(obj);
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,22,22,250,50};
            g.ColumnWidth = {150,'2x',44,44};
            
            la=uilabel(g,'Text','Options of Measurement:');
            la.Layout.Row=1;
            la.Layout.Column=[1 3];
            
            
            la3=uilabel(g,'Text',sprintf('ID: %d',obj.ID),...
                'HorizontalAlignment','center',...
                'BackgroundColor',[0.7 0.7 0.7]);
            la3.Layout.Row=1;
            la3.Layout.Column=[3 4];
            
            la2=uilabel(g,'Text','Name of measurement:');
            la2.Layout.Row=2;
            la2.Layout.Column=1;
            
            text=uieditfield(g,'Value',obj.Name,...
            'ValueChangedFcn',@(src,event)ChangeName(obj,event));
            text.Layout.Row=2;
            text.Layout.Column=2;
            
            la3=uilabel(g,'Text','Raw data folder:');
            la3.Layout.Row=3;
            la3.Layout.Column=1;
            
            
            text2=uieditfield(g,'Value',obj.BruteFolder,...
            'Editable','off');
            text2.Layout.Row=3;
            text2.Layout.Column=2;
            
            
            but1=uibutton(g,'Text','Change folder',...
                'ButtonPushedFcn',@(src,event)ChangeBruteFolder(obj,event),'UserData',text2);
            but1.Layout.Row=3;
            but1.Layout.Column=[3 4];
            
            la4=uilabel(g,'Text','Select read options');
            la4.Layout.Row=4;
            la4.Layout.Column=1;
            
            if size(obj.LoadOptions,1)>0
                UpdateLoadOption(obj);
            else
%                 T=
                obj.LoadOptions=MakeOptionTable(obj);
            end
            
            uit = uitable(g,'Data',obj.LoadOptions,...
                'ColumnEditable',[false,true,true,true],...
                'DisplayDataChangedFcn',@obj.MLoadOptionChange);
            uit.Layout.Row=4;
            uit.Layout.Column=2;
            
            if ~isempty(obj.MeasDate)
                time=obj.MeasDate;
            else
                time=datetime(now(),'ConvertFrom','datenum');
            end
            
            la5=uilabel(g,'Text','Select when was measuremnt conducted');
            la5.Layout.Row=5;
            la5.Layout.Column=2;
            
            dpck=uidatepicker(g,'DisplayFormat','dd-MM-yyyy',...
                'Value',time,...
                'ValueChangedFcn',@obj.MMeasDate);
            dpck.Layout.Row=5;
            dpck.Layout.Column=1;
        end
    end
    
    methods %callbacks
        function MLoadOptionChange(obj,src,evnt)
            ReadOptionChange(obj,src.Data,evnt.InteractionColumn)
            src.Data=obj.LoadOptions;
        end
        
        function MMeasDate(obj,src,~)
            obj.MeasDate=src.Value;
        end
    end

end
