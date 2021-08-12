classdef OperLib < handle
    %OPERLIB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
    end
    
    methods (Abstract)
    end
    
    methods
        %constructor
        function obj = OperLib(~)
        end
        
        
    end
    
    %Static methods for basic frames and variables
    methods (Static)
        
        
        
        function alpha=GetAlpha
            alpha='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        end
        
        function [HeaderLine]=GetHeadersLine(filename,StrCell)
            fid=fopen(filename);% to open the file (a test for success is strongly recommended)
            Data = strings([10,1]); %: Pre-allocate the output
            for i=1:10 % = from 1 to 10
                Data(i,1)=fgets(fid ); %to read one line, store it in Data cell.
                if contains(Data(i,1),StrCell)% || contains(Data(i,1),{'??'})
                    HeaderLine=i-1;
                    fclose(fid);% to close the file
                    break;
                end
            end
        end
        
        %výpoèet 
        function [x,y]=Hypotenuse(XMax,YMax,Alpha)
        %Funkce pro výpoèet souøadnice vrcholu pravoúhlého trojúhelníka v
        %obedlníku, pokud znám úhel trojúhelníka v levém dolním rohu a rozmìry
        %obedlníka

        OrigAlpha=atan(YMax/XMax); %In radians
        NinDegree=deg2rad(90);
        DiffUp=NinDegree-OrigAlpha;
        Alpha=deg2rad(Alpha);

            if Alpha==deg2rad(45)
                x=XMax;
                y=YMax;
            else


                if Alpha>deg2rad(45)

                    RatioDegree=1-Alpha/NinDegree;

                    y=YMax;
                    x=RatioDegree*XMax;
                else
                    %alpha<45°
                    FortyFiveDegree=deg2rad(45);
                    RatioDegree=Alpha/FortyFiveDegree;
                    x=XMax;
                    y=RatioDegree*YMax;
                end
            end


        end
        
        %Get number of column which contains key
        function ColNum=GeKeyCol(Table)
            ColNum=Table.ColNumber(Table.Key>0);
        end
        
        %Get Dir only for folders
        function all_dir=DirFolder(path)
            if path(end)~='\'
                path=[path '\'];
            end
            
            all_files = dir(path);
            all_dir = all_files([all_files(:).isdir]);
            all_dir(1:2)=[];
        end
        
        %sort data in maintable
        function Arr=ConvertTabeType(Type,InArr)            
            switch lower(Type)
                case "string"
                    Arr=string(InArr);
                case "datetime"
                    
                case "double"
                    if isa(InArr,'double')
                        Arr=InArr;
                    else
                        Arr=string2double(InArr);
                    end
                case "category"
                    Arr=categorical(InArr,'Ordinal',true);
                otherwise
            end       
        end
        
        %convert type
        function Arr=ConvertType(InArr,OutType)
        end
        
        %blueprint for maintable
        function T=MTBlueprint
            ColNames=categorical(["string","datetime","double","category"],{'string','datetime','double','category'},'ordinal',true);
            Key=false;
            Label="Name of column";
            IsDescriptive=false;
            Num=1;
            T=table(ColNames(1),Key,Label,IsDescriptive,Num,'VariableNames',{'ColType','Key','Label','IsDescriptive','ColNumber'});
        end
        
        function T=PRBlueprint
            ColNames=categorical(["seconds","datetime","double"],{'seconds','datetime','double'},'ordinal',true);
            Label="Name of column";
            Unit="N or s or MPA";
            IsDescriptive=false;
            Num=1;
            T=table(Num,Label,Unit,ColNames(1),'VariableNames',{'ColOrder','VariableName','Unit','Type'});
        end
        
        
        
        %Map directory for types in reading process
        function FileMap=GetTypeDir(folder)
            map = dir(fullfile(folder)); 
            map([1 2])=[];
            
            name=string({map(:).name})';
            
            folder=string({map(:).folder})';
            date=datetime({map(:).date},'Format','dd.MM.yyyy hh:mm:ss','Locale','system')';
            dirlog=logical(cell2mat({map(:).isdir}))';
            
            suffix=strings(numel(name),1);
            suffix(~dirlog,1)=name(~dirlog,1);
            filename=strings(numel(name),1);
            
            for i=1:numel(suffix)
                suff=split(suffix(i,1),'.');
                suffix(i,1)=['.' char(suff(end))];
                filename(i,1)=replace(name(i,1),['.' char(suff(end))],'');
            end
            row=linspace(1,i,i)';
            
            colnames={'row','name','file','suffix','folder','date','isdir'};
            FileMap=table(row,filename,name,suffix,folder,date,dirlog,'VariableNames',colnames);
        end
        
        function result=GetResultStruct
%             result=struct('data',{},'key',{},'count',[],'type','');
%             
%             result.data=Data;
%             result.key=Data{:,KeyRow.ColNumber};
%             result.count=size(Data,1);
%             result.type=class(obj);
            
        end
        
        
        %Get All types that are present in datatype library
        function out=GetTypes(varargin)
            STRTypes=["MainTable","Press","Zedo"];
            CTypes = categorical(STRTypes,{'MainTable','Press','Zedo'},'Ordinal',true);
            if numel(varargin)>0
                switch class(varargin{1})
                    case 'char'
                        for i=1:numel(STRTypes)
                            if strcmp(STRTypes(i),string(varargin{1}))
                                out=CTypes(i);
                                break;
                            end
                        end
                end
            else
                out=CTypes;                
            end
            
        end  
        
        %Create appropriate type
        function Out=CreateType(ClassName,parent)
            switch lower(char(ClassName))
                case 'maintable'
                        Out=MainTable(parent);
                case 'zedo'
                        Out=Zedo(parent);
                case 'press'
                        Out=Press(parent);
                otherwise
            end
        end
        
        %Will separate name from dir function
        function StrArr=SeparateFileName(Files)
            arguments 
                Files struct;
            end
            
            Dim=size(Files);
            StrArr=strings(Dim(1),1);
            for i=1:size(Files,1)
                TMP=strsplit(Files(i).name,'.');
                TMP(end)=[];
                TMP2=join(TMP);
                StrArr(i)=TMP2;
            end
        end
        
        function out=GetContainerTypes(varargin)
            t=categorical(["File","Folder"],{'File','Folder'},'Ordinal',true);
            if numel(varargin)>0
                out=t(varargin{1});
            else
                out=t;
            end
            
        end
        
        function out=GetSuffixTypes(varargin)
            t=[".xls",".xlsx",".csv",".txt",".bin","~"];
            STypes = categorical(t,{'.xls','.xlsx','.csv','.txt','.bin','~'},'Ordinal',true);
            if numel(varargin)>0
                out=STypes(varargin{1});
            else
                out=STypes;
            end
        end
        
        function T=GetSuffixOptionsTable(type)
            switch lower(type)
                case '.xls'
                    Name=["SheetName","DecimalDelimiter","ColumnDelimiter",...
                        "HeaderLines"]';
                    DecimalDelimiter=categorical([".",","],'Ordinal',1);
                    Value={"Sheet1",DecimalDelimiter(1),";",0}';
                    T=table(Name,Value);
                case '.xlsx'
                    Name=["SheetName","DecimalDelimiter","ColumnDelimiter",...
                        "HeaderLines"]';
                    DecimalDelimiter=categorical([".",","],'Ordinal',1);
                    Value={"Sheet1",DecimalDelimiter(1),";",0}';
                    T=table(Name,Value);
                case '.csv'
                    Name=["SheetName","DecimalDelimiter","ColumnDelimiter",...
                        "HeaderLines"]';
                    DecimalDelimiter=categorical([".",","],'Ordinal',1);
                    Value={"Sheet1",DecimalDelimiter(1),";",0}';
                    T=table(Name,Value);
                case '.txt'
                    Name=["DecimalDelimiter","ColumnDelimiter",...
                        "HeaderLines"]';
                    DecimalDelimiter=categorical([".",","],'Ordinal',1);
                    Value={DecimalDelimiter(1),";",0}';
                    T=table(Name,Value);
                case '.bin'
                    DecimalDelimiter=categorical([".",","],'Ordinal',1);
                    enctypes=["uint","uint8","uint16","uint32","uint64",...
                                    "uchar","ushort","ulong","ubitn","int","int8",...
                                    "int16", "int32","int64","schar","short",...
                                    "long","bitn","single","double","float",...
                                    "float32","float64","real*4","real*8","char*1",...
                                    "char"];
                    Enc=categorical(enctypes,'Ordinal',1);
                    Name=["DecimalDelimiter","Encryption"]';
                    Value={DecimalDelimiter(1),Enc(1)}';
                    T=table(Name,Value);
                case '~'
                    Name=["No prop"]';
                    Value=categorical("");
                    T=table(Name,Value);
                otherwise
            end
        end
        
        function val=FindProp(obj2,name)
            val=[];
%             obj2=obj2.Parent;
            name=string(name);
            list=string(properties(obj2));
            while numel(list)>0
                
                
                
                idx=find(list==name);
                
                if sum(idx)>0
                    prop=list(idx);
                    val=obj2.(prop{1});
                    break;
                end
                obj2=obj2.Parent;
                list=string(properties(obj2));
            end
            
        end
        
    end 
    
    %Methods for node operations from 
    methods 
        function AddNode(obj,node)
            
        end
        
        function DelNode(obj,node)
            
        end
        
        
        function stash=PackNode(obj)
            
        end
        
        
        function FillNode(obj,stash)
            
        end
    end
    
    %Methods for db comm
    methods
        function Connect(obj)
            Conn=ConnGetDBConn(obj);
            Connect(Conn);
        end
        
        function Disconnect(obj)
            Conn=ConnGetDBConn(obj);
            Disconnect(Conn);
        end
        
        function DBWrite(obj,TableName,data)
            conn=ConnGetDBConn(obj);
%             Connect(conn);
            
            sqlwrite(conn.Conn,TableName,data);
            
%             Disconnect(conn);
        end
        
        function fetchdata=DBFetch(obj,querry)
            conn=ConnGetDBConn(obj);
            
%             Connect(conn);
            
            fetchdata = select(conn.Conn,querry);
            
%             Disconnect(conn);
        end

    end
    
    methods (Access=private)
        function Conn=ConnGetDBConn(obj)
            Conn=OperLib.FindProp(obj,'DbConn');
        end
    end
end

