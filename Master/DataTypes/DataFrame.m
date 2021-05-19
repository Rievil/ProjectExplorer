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
    
    %Gui for datatypes
    methods
        
    end
end

