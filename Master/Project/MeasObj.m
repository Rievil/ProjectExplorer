classdef MeasObj < handle
    properties (SetAccess = public)
        Name char;
        FName char;  %filename within the project folder - important for deleting
        ID double; %number
        Date datetime; %oficial name for measurement, copy erliest date from files
        LastChange datetime; %when change happen
        Count;
        Data; %data containers per that measurment (ae classifer, ie data, uz data, fc data, fct data)
        %BruteFolder char; %folder with measured data, from which DataC construct itrs container
        Row;
        ProjectFolder char;
        ExtractionState; %status of extraction of data from brute folder
        BruteFolder char;
        %if 'extracted', then we already have DataC created in project
        %folder, and we dont have to check if BruteFolder is avaliable, or
        %not
        SandBox char; 
        %this path may change between instances per users, its important 
        %for creation of new object
        Selector;
        ClonedTypes=0;
        TotalTable;
        Parent;
        Version; 
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
        function obj=MeasObj(ID,ProjectFolder,SandBox,Row,Parent)
            
            obj.ID=ID;
            obj.Row=Row;
            obj.ProjectFolder=ProjectFolder;
            %obj.BruteFolder=uigetdir(cd,'Select folder with your measurmenets');
            obj.Date=datetime(now(),'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss');    
            obj.SandBox=SandBox;
            obj.Parent=Parent;
            obj.Version=0;
%             SetListeners(obj);
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

    %Get set methods
    methods
        function Name=get.Name(obj)
            BruteFolders=split(obj.BruteFolder,'\');
            Name=char(BruteFolders(end-1));
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
    
    %Gui methods
    methods
        %fill the table 
        function FillUITable(obj,UITable,Sel)
            %if isempty(obj.TotalTable)
            MakeTotalTable(obj,Sel);
            %end
            UITable.Data=obj.TotalTable;
            UITable.ColumnEditable(2) = true;
            UITable.ColumnEditable(~2) = false;
            for i=1:size(obj.TotalTable,2)
                UITable.ColumnName{i}=obj.TotalTable.Properties.VariableNames{i};
            end
        end
    end
    
    %Save, load, delete, copy methods
    methods
        function delete(obj)
            
        end
        
        function save(obj)

        end
    end
end
