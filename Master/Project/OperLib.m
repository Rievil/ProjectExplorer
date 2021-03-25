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
        
        %v�po�et 
        function [x,y]=Hypotenuse(XMax,YMax,Alpha)
        %Funkce pro v�po�et sou�adnice vrcholu pravo�hl�ho troj�heln�ka v
        %obedln�ku, pokud zn�m �hel troj�heln�ka v lev�m doln�m rohu a rozm�ry
        %obedln�ka

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
                    %alpha<45�
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
        function Out=CreateType(ClassName)
            switch lower(char(ClassName))
                case 'maintable'
                        Out=MainTable;
                case 'zedo'
                        Out=Zedo;
                case 'press'
                        Out=Press;
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
            t=["File","Folder"];
            if numel(varargin)>0
                out=t(varargin{1});
            else
                out=t;
            end
            
        end
        
        function out=GetSuffixTypes(varargin)
            t=[".xls",".xlsx",".csv",".txt",".bin","~"];
            STypes = categorical(t,{'MainTable','Press','Zedo'},'Ordinal',true);
            if numel(varargin)>0
                out=t(varargin{1});
            else
                out=t;
            end
        end
        
        function val=FindProp(obj2,name)
            val=[];
%             obj2=obj2.Parent;
            list=properties(obj2);
            while numel(list)>0
                idx=contains(list,name);
                if sum(idx)>0
                    prop=list(idx);
                    val=obj2.(prop{1});
                    break;
                end
                obj2=obj2.Parent;
                list=properties(obj2);
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
