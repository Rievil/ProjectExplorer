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
        %Data table;
    end
    
    properties 
        Key logical;
        MainTable table;
    end
    
    methods
        %consruktor
        function obj = DataLoader(ID,ProjectFolder,SandBox)
            obj@OperLib;
            obj@MeasObj(ID,ProjectFolder,SandBox);
            
            GetBruteFolder(obj);
            

        end
        
        %Výbìr adresáøe s mìøeními
        function GetBruteFolder(obj)
            obj.BruteFolder=uigetdir(cd,'Vyber slozku s mìøenými vzorky');
            if obj.BruteFolder==0
                obj.BruteFolder="none";
            else
                obj.BruteFolder=[obj.BruteFolder '\'];
            end
            %obj.BruteFolder=BruteFolder;
        end
        
        %funkce pro ètení
        function ReadData(obj)
            Types=obj.TypeTable.DataType;
            TP=DataFrame.GetTypes;
            
            ChTypes=sort(obj.TypeTable.DataType);
            
            Lia = ismember(ChTypes,TP(1));
            
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
            for i=1:size(obj.TypeTable,1)
                switch lower(char(obj.TypeTable.Container(i)))
                    case 'file'
                        items=dir([obj.BruteFolder '*' char(obj.TypeTable.Sufix(i))]);
                        Names=OperLib.SeparateFileName(items);

                        if ~strcmp(obj.TypeTable.KeyWord(i),"")

                            Index=find(contains(Names,obj.TypeTable.KeyWord(i)));
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
                        OutPut=Read(obj.TypeTable.TypesObj{i},filename);

                        if obj.Key && i==1
                            %obj.Data(i).('Key') = Shard(:,OperLib.GeKeyCol(obj.MainTable));
                            Name=OutPut(:,OperLib.GeKeyCol(obj.MainTable));
                            obj.Data=[obj.Data, Name];
                            %obj.Data.RowNames='Name';
                        end
                        obj.Data=[obj.Data, TabRows(obj.TypeTable.TypesObj{i})];
%                         obj.Data.DataTypeName{i}=char(obj.TypeTable.DataType(i));
%                         obj.Data.Data{i}=obj.TypeTable.TypesObj{i};
                        
                    case 'folder'
                        %i got all folders from brute folder
                        %is key option on? if so, then go through the list of
                        %folders by name, if not, then by loaded order
                        items=OperLib.DirFolder(obj.BruteFolder);
                        F2File=table;
                        %F2File=cell2table(cell(0,size(items,1)));
                        for j=1:numel(items)
                            folder=[char(items(j).folder) '\' char(items(j).name) '\'];
                            Read(obj.TypeTable.TypesObj{i},folder);
                            F2File=[F2File; table(obj.TypeTable.TypesObj{i},...
                                'VariableNames',{char(obj.TypeTable.DataType(i))})];
                        end
                        obj.Data=[obj.Data, F2File];
                    otherwise
                end
            %--------------------------------------------------------------
            end
            obj.Count=size(obj.Data,1);
            
            InitSel(obj);
            saveobj(obj);
        end
        
        %function for final saving of data
        function [DataFrame]=StoreData(obj,ID,ProjectFolder,Sandbox)
            
        end
       
        function Idx=FindPattern(obj,arr,pattern)
            
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
    
    %Methods for loading
    methods (Access = private)
    end
end

