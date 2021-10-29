classdef MeasObj < Node
    properties (SetAccess = public)
        ID double; %number 
%         FName char;  %filename within the project folder - important for deleting
        Name char;
        
        Metadata struct;
%         Date datetime; %oficial name for measurement, copy erliest date from files
%         LastChange datetime; %when change happen
%         Data; %data containers per that measurment (ae classifer, ie data, uz data, fc data, fct data)
        BruteFolder char; %folder with measured data, from which DataC construct itrs container
        BruteFolderSet=false;
%         Row;
%         ProjectFolder char;
        ExtractionState; %status of extraction of data from brute folder
        c char;
        Key=0;
        MainTable;
        TypeTable table;
        
        Selector;
        ClonedTypes=0;
        TotalTable;
        Version;
%         TreeNode;
        
        
        SpecimenCount;    
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
        end
        
        function Populate(obj,stash)
            obj.ID=stash.ID;
            obj.Name=stash.Name;
            obj.Metadata=stash.Metadata;
            obj.BruteFolder=stash.BruteFolder;
            obj.BruteFolderSet=stash.BruteFolderSet;
            obj.SpecimenCount=stash.SpecimenCount;
            
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
    
    %Events, listeners, callbacks
    methods
%         function SetListeners(obj)
%             obj.eReload = addlistener(obj.Parent,'ReloadData',@obj.ReLoadData);
%         end
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
    methods
        function saveobj(obj)
            disp('Tento objekt se ukl�d�');
        end
        
        function delete(obj)
            
        end
        
        function save(obj)

        end
    end
    
    methods %Reading methods
        
        
        
        function MenuRead(obj,src,~)
            ReadData(obj);
        end
        
        function ReadData(obj)
            if obj.BruteFolderSet==0
                GetBruteFolder(obj);
            end
            obj.Version=obj.Version+1;
            obj.TypeTable=OperLib.FindProp(obj,'TypeSettings');
            
            AllTypes=OperLib.GetTypes;
            CurrentTypes=sort(obj.TypeTable.DataType);
            
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
                obj2=obj.TypeTable.TypesObj{i,1};
                waitbar(i/(TypeCount+2),f,char(sprintf('Loading: ''%s'' data type',class(obj2)))); 
                subresult=ReadContainer(obj2,FileMap);
                if i==1
                    result=subresult;
                else
                    result=[result, subresult];
                end
            end
            waitbar((i+1)/(TypeCount+2),f,'Storing variables');

            
            %check for key similarities
            ch=0;
            for i=1:size(result,2)
                if i==1
                    keyold=result(i).key;
                else
                    key=result(i).key;
                    if numel(key)==numel(keyold)
                        [A]=intersect(keyold,key);
                        if numel(A)==numel(key)
                            ch=1;
                            keyold=key;
                        else
                            break;
                            ch=0;
                        end
                    else
                        result(i).key=keyold;
                    end
                end
            end
            
            if ch==1
                finalkey=keyold;
            else
                %key is corupted
            end
            
            MakeSpecimens(obj,result,finalkey);
            waitbar(1,f,'Finished');
            pause(1);
            close(f);
            
        end
        
        function MakeSpecimens(obj,result,key)
            SpecGroup=OperLib.FindProp(obj,'SpecGroup');
            for i=1:numel(key)
                data=struct;
                for j=1:size(result,2)
                    Idx=find(result(j).key==key(i));
                    data(j).data=result(j).data(Idx).meas;
                    data(j).type=result(j).type;
                end
                
%                 SpecimenID=OperLib.FindProp(obj,'SpecimenID');
                spec=Specimen(SpecGroup);
                spec.MeasID=obj.ID;
                spec.Data=data;
                spec.Key=key(i);
                
                AddSpecimen(SpecGroup,spec);
                
            end
            
        end
        
        function ReadData2(obj)
            if obj.BruteFolderSet==0
                GetBruteFolder(obj);
            end
            
            try
                obj.Version=obj.Version+1;
                Types=OperLib.FindProp(obj,'TypeSettings');
                TP=DataFrame.GetTypes;

                ChTypes=sort(Types.DataType);

                Lia = find(ChTypes==TP(1));
                f1 = waitbar(0,'Please wait...','Name','Loading data');

                %�ekni jestli m� MainTable
                if sum(Lia)>0
                    %yes, this profile has main maintable
                    MainTable=Types.TypesObj{Lia,1}.TypeSettings;
                    if sum(MainTable.Key)>0
                        %yes, this profile has key column
                        obj.Key=true;                    
                    end
                else
                    %no, this profile does not has maintable
                end   
                
                %--------------------------------------------------------------
                F1Lim=size(Types,1);
                for i=1:F1Lim
                    CharDataType=lower(char(Types.Container(i)));
                    waitbar(i/F1Lim,f1,['Processing ''' CharDataType ''' ...']);
                    switch CharDataType
                        case 'file'
                            items=dir([obj.BruteFolder '*' char(Types.Sufix(i))]);
                            Names=OperLib.SeparateFileName(items);

                            if ~strcmp(Types.KeyWord(i),"")

                                Index=find(contains(lower(Names),lower(Types.KeyWord(i))));
                                if numel(Index)>1
                                    %there is more maintables, which is forbidden
                                    %-> error
                                else
                                    %this is right output
                                    %i have desired FILE, and now I can read it
                                    %according to the typetable and its datatype
                                    filename=[items(Index).folder '\' items(Index).name];
                                    %break;
                                end
                            else
                                Index=find(contains(fileName,paterrn));
                            end

                            %filename=ReadDir(obj,i);
                            obj1=Copy(Types.TypesObj{i});
                            obj1.Parent=obj;
                            OutPut=Read(obj1,filename);

                            if obj.Key && i==1
                                %obj.Data(i).('Key') = Shard(:,OperLib.GeKeyCol(obj.MainTable));
                                Name=OutPut(:,OperLib.GeKeyCol(obj.MainTable));
                                obj.Data=[obj.Data, Name];
                                %obj.Data.RowNames='Name';
                            end

                            obj.Data=[obj.Data, TabRows(obj1)];

                        case 'folder'
                            %i got all folders from brute folder
                            %is key option on? if so, then go through the list of
                            %folders by name, if not, then by loaded order
                            items=OperLib.DirFolder(obj.BruteFolder);

                            %F2File=cell2table(cell(0,size(items,1)));
                            f1pos=f1.Position;
                            f2 = waitbar(0,'Please wait...','Name','Folder reading');
                            f2.Position(2)=f1pos(2)-f2.Position(4)-40;

                            F2Lim=numel(items);
                            F2File=table;

                            for j=1:F2Lim

                                KeyNames=string({items.name}');
                                [TF]=contains(lower(KeyNames(j)),lower(obj.Data.Name));
                                if TF>0
                                    waitbar(j/F2Lim,f2,['Processing: ''' char(obj.Data.Name(j)) '''']);
                                    folder=[char(items(j).folder) '\' char(obj.Data.Name(j)) '\'];
                                    %'obj2 = copy(obj1)'
                                    obj2=Copy(Types.TypesObj{i});
                                    obj2.Parent=obj;
                                    Read(obj2,folder);
                                    F2File=[F2File; table(obj2,...
                                        'VariableNames',{char(Types.DataType(i))})];
                                end
                            end
                            close(f2);
                            obj.Data=[obj.Data, F2File];
                        otherwise
                    end
                %--------------------------------------------------------------

                end
                close(f1);
                obj.Count=size(obj.Data,1);

                InitSel(obj);

                saveobj(obj);
            catch ME
                close(f1);
                close(f2);
                msgbox(['Error while loading of data:\n' char(ME.message) '\n' ...
                    'on line:' char(num2str(ME(1).line)) '\n' ...
                    'file:' char(ME(1).file)]);
                obj.Version=obj.Version-1;
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
            event.Source.UserData.Text=obj.BruteFolder;
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
            
            la4=uilabel(g,'Text',obj.BruteFolder);
            la4.Layout.Row=3;
            la4.Layout.Column=2;
            
            but1=uibutton(g,'Text','Change folder',...
                'ButtonPushedFcn',@(src,event)ChangeBruteFolder(obj,event),'UserData',la4);
            but1.Layout.Row=3;
            but1.Layout.Column=[3 4];
          
            
        end
    end

end
