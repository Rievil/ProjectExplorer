classdef MeasObj < handle
    properties (SetAccess = public)
        FName char;  %filename within the project folder - important for deleting
        ID double; %number
        Date datetime; %oficial name for measurement
        LastChange datetime;
        Data; %data containers per that measurment (ae classifer, ie data, uz data, fc data, fct data)
        %BruteFolder char; %folder with measured data, from which DataC construct itrs container
        ProjectFolder char;
        ExtractionState; %status of extraction of data from brute folder
        
        %if 'extracted', then we already have DataC created in project
        %folder, and we dont have to check if BruteFolder is avaliable, or
        %not
        SandBox char; 
        %this path may change between instances per users, its important 
        %for creation of new object
        Selector;
        DataTypesTable;
    end
    
    properties (Dependent)
        Name char;
    end
    
    methods (Access = public)
        %constructor of object
        function obj=MeasObj(ID,ProjectFolder,SandBox)
            obj.ID=ID;
            obj.ProjectFolder=ProjectFolder;
            %obj.BruteFolder=uigetdir(cd,'Select folder with your measurmenets');
            obj.Date=datetime(now(),'ConvertFrom','datenum','Format','dd.MM.yyyy hh:mm:ss');    
            obj.SandBox=SandBox; 
        end
        
        %fill the table 
        function FillUITable(obj,UITable,Sel)
            T=table;
            Names=string({obj.Data.Measuremnts.Name});
            T.Name=Names';
            
            CatTab=obj.Data.CatColumns;
            
            T=[T, obj.Selector(:,Sel), CatTab];
            UITable.Data=T;
            %UITable.Selection=Selection;
            UITable.ColumnEditable(2) = true;
            UITable.ColumnEditable(~2) = false;
            for i=1:size(T,2)
                UITable.ColumnName{i}=T.Properties.VariableNames{i};
            end
        end
        
        %Initiate selector
        function InitSel(obj)
            Selection(1:obj.Data.Count,1)=false;
            obj.Selector=table(Selection);            
        end
        
        %Change Selector
        function SetSelector(obj,Row,Val,Set)
            obj.Selector{Row,Set}=Val;
            %saveobj(obj);
        end
        
        %add Selector rows
        function AddSelRows(obj,nSet,Name)
            Selector(1:1:obj.Data.Count,1)=false;
            %obj.Selector=[obj.Selector, table(Selector)];
            obj.Selector = addvars(obj.Selector,Selector,'NewVariableNames',char(Name));
        end
        
        %delete sel column
        function DeleteSelCol(obj,nSet)
            obj.Selector(:,nSet)=[];
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
        function [Data,Cat]=PullData(obj,Set)     
            Idx=table2array(obj.Selector(:,Set));
            Data=obj.Data.Measuremnts(Idx);
            Cat=obj.Data.CatColumns(Idx,:);
        end
        
        %will set options for data loading
        function SetDataTypesTable(obj,TypeTable)
            obj.DataTypesTable=TypeTable;
        end
        
        
    end
    
    
    
    %save load delete operations
    methods
        function Name=get.Name(obj)
            BruteFolders=split(obj.Data.BruteFolder,'\');
            Name=char(BruteFolders(end-1));
        end        
    end   
    
    
end
