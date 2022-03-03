classdef DataFrame < OperLib & GUILib
    %DATAFRAME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ImportOptions;
        Data; %universal container, Data might be table, array, structure
        Filename; %for files type
        Folder; %for folder types
        Parent;
    end
    
    properties %File / folder container
        ContainerType;
        KeyWord;
        Sufix;
        KeyName;
        SheetName;
        HeadersRow;
        TypeSettings;
        ContChildren;
    end
    
    %Interface of class
    methods (Abstract)
        Read(obj);
        ReadDb(obj);
        TabRows(obj);
        Copy(obj);
        PackUp(obj);
        GetVariables(obj);
        
        GetVarNames;
        CreateTypeComponents(obj);
        %GetVarByName
    end
    
    

    methods
        %constructor
        function obj = DataFrame(parent)
            obj@GUILib;
            obj@OperLib;
            obj.Parent=parent;
        end
        
        function ReLoadData(obj,src,~)
%             obj.Data=[];

            
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
        
        function SetTypeSet(obj,TypeSet)
            obj.TypeSet=TypeSet;
        end
        
        function ClearGUI(obj)
            obj.Init=0;
            obj.Children=[];
            obj.ContChildren=[];
            obj.GUIParents=[];
            obj.GuiParent=[];
            obj.Parent=[];
        end
        
        function SetKeyWord(obj,key)
            obj.KeyWord=key;
        end
        
        function SetSuffix(obj,suffix)
            obj.Sufix=suffix;
            ltype=char(suffix);
            
            T=OperLib.GetSuffixOptionsTable(ltype);
            obj.ContChildren(3).Data=T;
            obj.ImportOptions=T;
                    
        end
        
        function SetConType(obj,type)
            obj.ContainerType=type;
            obj.ImportOptions=obj.ContChildren{3}.Data;
        end
        
        function SetFrameOpt(obj,src,event)
            obj.ImportOptions=event.Source.Data;
        end   
        
        function CreateContainerComponents(obj)
            SetParent(obj,'container');
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,'1x'};
            g.ColumnWidth = {'1x','1x'};
            
            la=uilabel(g,'Text','File option');
            la.Layout.Row=1;
            la.Layout.Column=1;
            
            
            T=OperLib.GetSuffixOptionsTable('.xls');
            uit = uitable(g,'Data',T,'ColumnEditable',[false,true],...
                'ColumnWidth','auto','CellEditCallback',@(src,event)obj.SetFrameOpt(obj,event));
            
            if strcmp(class(obj.ImportOptions),'table')
                uit.Data=obj.ImportOptions;
            else
                obj.ImportOptions=T;
            end
            
            uit.Layout.Row=2;
            uit.Layout.Column=1;
            
            obj.ContChildren=[g;la;uit];
            SetParent(obj,'type');
        end
    end   
    
    methods (Access=public)
        

        
        function result=ReadContainer(obj,map)
            %filter by container
            switch obj.ContainerType
                case 'File'
                    T=map(map.isdir==0,:);
                    
                    %filter by suffix
                    T=T(T.suffix==char(obj.Sufix),:);
                    
                case 'Folder'
                    T=map(map.isdir==1,:);
            end
            
            %filter by keyword
            name=T.name;
            T(contains(T.file,'$'),:)=[];
            Idx=find(contains(lower(T.name),lower(obj.KeyWord)));
            
            if isempty(Idx)
                fprintf("Can't find '%s' in name of file '%s'",lower(obj.KeyWord),...
                    lower(T.name));
            elseif Idx>0
                %i got exactly one type
                filename=[char(T.folder(Idx))  '\' (char(T.file(Idx)))];
                switch T.suffix
                    case '.db'
                        result=ReadDb(obj,filename);
                    otherwise
                        opts=MakeReadOpt(obj,filename,T.suffix);
                        result=Read(obj,filename,opts);
                end
                
            elseif Idx>1
                %i got multiple types
                
            end
            
        end
        
        function opts=MakeReadOpt(obj,filename,suffix)
%             opts = detectImportOptions(filename);
%             for i=1:size(obj.ImportOptions)
                switch suffix
                    case '.txt'
                    case '.csv'
                        opts = detectImportOptions(filename,'Sheet',obj.ImportOptions.Value{1},...
                            'NumHeaderLines',obj.ImportOptions.Value{4});
                    case '.xls'
                        opts = detectImportOptions(filename,'Sheet',obj.ImportOptions.Value{1},...
                            'NumHeaderLines',obj.ImportOptions.Value{4});

                    case '.xlsx'
                        opts = detectImportOptions(filename,'Sheet',obj.ImportOptions.Value{1},...
                            'NumHeaderLines',obj.ImportOptions.Value{4});
                    case '.db'
                        
                    otherwise
                        disp('zedo');
                        opts=[];
                end
                
                
%             end
        end
        
    end
    
    %Gui for datatypes
    methods
        
    end
end

