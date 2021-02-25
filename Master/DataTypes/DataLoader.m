classdef DataLoader < OperLib & MeasObj
    %Each type has its own structure, which is tends to be most effective,
    %data Loader will use each type as a blueprint of "how to load and
    %preprocess data", but the output of type is matlab primitive (array,
    %structure, table or so), each block of data will then be stored in
    %structure inside a data loader, for each operation, where first column
    %is for PILOT KEY variable, and if loader finds any data, which is in
    %right column for each type, and ricgh row for each KEY, then the
    %dataloader structure will be most effective; if I then load any data,
    %i will just use the datatypetable, and to each specified type will
    %load data stored in dataloader structure; by this way i can easily
    %adjust the code, update, and the data is still intacted
    
    properties
        TypeTable table;
        SpecimenCount;
    end
    
    properties 
        Key logical;
        MainTable table;
        BruteFolderSet=false;
    end
    
    methods
        %consruktor
        function obj = DataLoader(ID,ProjectFolder,SandBox,Row,Parent)
            obj@OperLib;
            obj@MeasObj(ID,ProjectFolder,SandBox,Row,Parent);
            
            GetBruteFolder(obj);
        end
        
        %Výbìr adresáøe s mìøeními
        function GetBruteFolder(obj)
            obj.BruteFolder=uigetdir(cd,'Vyber slozku s mìøenými vzorky');
            if obj.BruteFolder==0
                obj.BruteFolder="none";
                obj.BruteFolderSet=0;
            else
                obj.BruteFolder=[obj.BruteFolder '\'];
                obj.BruteFolderSet=1;
            end
        end
        
        function ReLoadData(obj)
            obj.Data=[];
            
            SavedSelectors=obj.Selector;
            SaveCount=obj.Count;
            
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
            
            if obj.Count~=SaveCount || isempty(SavedSelectors)
                ResetSelectors(obj);
            else
                obj.Selector=SavedSelectors;
            end
        end
        
        %funkce pro ètení
        function ReadData(obj)
            
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
        function Test(obj,ax,Sel)
            idx=obj.Selector{:,Sel};
            CData=obj.Data(idx,:);
            for i=1:size(CData,1)
                PlotType(CData.Press(i),ax);
                PlotType(CData.Zedo(i),ax);
            end
        end
    end
    
    %Delete,copy, load methods
    methods
        function delete(obj)
            
        end
    end
end

