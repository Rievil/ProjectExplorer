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
        %if 'extracted', then we already have DataC created in project
        %folder, and we dont have to check if BruteFolder is avaliable, or
        %not
%         SandBox char; 
        %this path may change between instances per users, its important 
        %for creation of new object
        Selector;
        ClonedTypes=0;
        TotalTable;
        Parent;
        Version;
        TreeNode;
        
        TypeTable table;
        SpecimenCount;
%         Key logical;
%         MainTable table;
        
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
%             obj.ID=ID;
            
            obj.Metadata=struct;
            obj.Metadata.Date=datetime(now(),'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss');    
            
            
%             obj.ProjectFolder=ProjectFolder;
            obj.eReload=addlistener(obj.Parent,'eReload',@obj.ReLoadData);
            obj.Version=0;
        end
        
        function SetName(obj)
            obj.Name=sprintf('%d - %s',obj.ID,datestr(obj.Metadata.Date,'dd.MM.yyyy'));
        end
        

        %Výbìr adresáøe s mìøeními
        function GetBruteFolder(obj)
            obj.BruteFolder=uigetdir(cd,'Pick folder with formated data as set in experiment');            
            if obj.BruteFolder==0
                obj.BruteFolder="none";
                obj.BruteFolderSet=0;
            else
                obj.BruteFolder=[obj.BruteFolder '\'];
                obj.BruteFolderSet=1;
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
            obj.Name=stash.Name;
            obj.Metadata=stash.Metadata;
            obj.BruteFolder=stash.BruteFolder;
            obj.BruteFolderSet=stash.BruteFolderSet;
            obj.SpecimenCount=stash.SpecimenCount;
            
            FillNode(obj)
        end
        
        function FillNode(obj)
            iconName=[OperLib.FindProp(obj,'MasterFolder') '\Master\Gui\Icons\Meas.gif'];
            obj.TreeNode=uitreenode(obj.Parent.TreeNode,'Text',obj.Name,...
                'Icon',iconName,...
                'NodeData',{obj,'meas'});
        end
        
        function node=AddNode(obj)
        end
        
%         FillUITab(obj,Tab);
%         FillNode(obj);
%         stash=Pack(obj);
%         node=AddNode(obj);
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
    
    %Gui methods
%     methods
%         %fill the table 
%         function FillUITable(obj,UITable,Sel)
%             %if isempty(obj.TotalTable)
%             MakeTotalTable(obj,Sel);
%             %end
%             UITable.Data=obj.TotalTable;
%             UITable.ColumnEditable(2) = true;
%             UITable.ColumnEditable(~2) = false;
%             for i=1:size(obj.TotalTable,2)
%                 UITable.ColumnName{i}=obj.TotalTable.Properties.VariableNames{i};
%             end
%         end
%     end
    
    %Save, load, delete, copy methods
    methods
        function saveobj(obj)
            disp('Tento objekt se ukládá');
        end
        
        function delete(obj)
            
        end
        
        function save(obj)

        end
    end
    
    methods %Reading methods
        function ReLoadData(obj)
            obj.Data=[];
            
%             SavedSelectors=obj.Selector;
%             SaveCount=obj.Count;
            
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
            
%             if obj.Count~=SaveCount || isempty(SavedSelectors)
%                 ResetSelectors(obj);
%             else
%                 obj.Selector=SavedSelectors;
%             end
        end
        
        %funkce pro ètení
        function ReadData(obj)
            if obj.BruteFolderSet==0
                GetBruteFolder(obj);
            end
            
            try
                obj.Version=obj.Version+1;
                Types=obj.TypeTable.DataType;
                TP=DataFrame.GetTypes;

                ChTypes=sort(obj.TypeTable.DataType);

                Lia = ismember(ChTypes,TP(1));
                f1 = waitbar(0,'Please wait...','Name','Loading data');

                %èekni jestli má MainTable
                if sum(Lia)>0
                    %yes, this profile has main maintable
                    obj.MainTable=GetTypeSpec(obj.TypeTable.TypesObj{Lia});
                    if sum(obj.MainTable.Key)>0
                        %yes, this profile has key column
                        obj.Key=true;                    
                    end
                else
                    %no, this profile does not has maintable
                end   
                %--------------------------------------------------------------
                F1Lim=size(obj.TypeTable,1);
                for i=1:F1Lim
                    CharDataType=lower(char(obj.TypeTable.Container(i)));
                    waitbar(i/F1Lim,f1,['Processing ''' CharDataType ''' ...']);
                    switch CharDataType
                        case 'file'
                            items=dir([obj.BruteFolder '*' char(obj.TypeTable.Sufix(i))]);
                            Names=OperLib.SeparateFileName(items);

                            if ~strcmp(obj.TypeTable.KeyWord(i),"")

                                Index=find(contains(lower(Names),lower(obj.TypeTable.KeyWord(i))));
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
                            obj1=Copy(obj.TypeTable.TypesObj{i});
                            obj1.Parent=obj;
                            OutPut=Read(obj1,filename);

                            if obj.Key && i==1
                                %obj.Data(i).('Key') = Shard(:,OperLib.GeKeyCol(obj.MainTable));
                                Name=OutPut(:,OperLib.GeKeyCol(obj.MainTable));
                                obj.Data=[obj.Data, Name];
                                %obj.Data.RowNames='Name';
                            end

                            obj.Data=[obj.Data, TabRows(obj1)];
    %                         obj.Data.DataTypeName{i}=char(obj.TypeTable.DataType(i));
    %                         obj.Data.Data{i}=obj.TypeTable.TypesObj{i};

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
                                    obj2=Copy(obj.TypeTable.TypesObj{i});
                                    obj2.Parent=obj;
                                    Read(obj2,folder);
                                    F2File=[F2File; table(obj2,...
                                        'VariableNames',{char(obj.TypeTable.DataType(i))})];
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
        
        %Will create overview of descriptive variables from maintable
        function [Cat]=StackCat(obj)
            Cat=table;
            if obj.Key==true
                for i=1:size(obj.Data,1)
                    Cat=[Cat; GetCat(obj.Data.MainTable(i))];
                end
            end
        end
    end
    
    %static methods
    methods (Static)
        
    end
    
    %set get methods
    methods (Access = public) 
        
        %Set datatypetable
        function SetDataTypes(obj,TypeTable)
            obj.TypeTable=TypeTable;
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
            obj.TreeNode.Text=event.Value;
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
            la.Layout.Column=[1 4];
            
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
