classdef DataLoader < OperLib
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
        Data struct;
        BruteFolder char;
        MasterFolder char;
    end
    
    properties 
        Key logical;
        MainTable table;
    end
    
    methods
        %consruktor
        function obj = DataLoader(MasterFolder)
            obj@OperLib;
            obj.MasterFolder=MasterFolder;
        end
        
        %funkce pro ètení
        function ReadData(obj)
            Types=obj.TypeTable.DataType;
            TP=DataFrame.GetTypes;
            Lia = ismember(obj.TypeTable.DataType,TP(1));
            
            if Lia>0
                %yes, this profile has main maintable
                obj.MainTable=GetTypeSpec(obj.TypeTable.TypesObj{Lia});
                if sum(obj.MainTable.Key)>0
                    %yes, this profile has key column
                    obj.Key=true;                    
                end
            else
                %no, this profile does not has maintable
                
            end   
            
            for i=1:size(obj.TypeTable,1)
                filename=ReadDir(obj,i);
                Shard=Read(obj.TypeTable.TypesObj{i},filename);
                
                if i==1
                    if obj.Key
                        obj.Data(i).('Key') = Shard(:,OperLib.GeKeyCol(obj.MainTable));
                    else 
                        obj.Data(i).(char(obj.TypeTable.DataType(i))) = Shard;
                    end
                else
                    obj.Data(i).(char(obj.TypeTable.DataType(i))) = Shard;
                end
            end
        end
          
        function filename=ReadDir(obj,n)
            switch lower(char(obj.TypeTable.Container(n)))
                case 'file'
                    items=dir([obj.BruteFolder '*' char(obj.TypeTable.Sufix(n))]);
                    Names=OperLib.SeparateFileName(items);
                    
                    if ~strcmp(obj.TypeTable.KeyWord(n),"")
                                               
                        Index=find(contains(Names,obj.TypeTable.KeyWord(n)));
                        if numel(Index)>1
                            %there is more maintables, which is forbidden
                            %-> error

                        else
                            %this is right output
                            %i have desired FILE, and now I can read it
                            %according to the typetable and its datatype
                            filename=[items(Index).folder '\' items(Index).name];
                            return;
                        end
                    else
                        Index=find(contains(fileName,paterrn));
                    end
                    
                case 'folder'
                    %i got all folders from brute folder
                    %is key option on? if so, then go through the list of
                    %folders by name, if not, then by loaded order
                    items=OperLib.DirFolder(obj.BruteFolder);
                    
                    
                otherwise
            end
        end
        
        
        
        function Idx=FindPattern(obj,arr,pattern)
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

