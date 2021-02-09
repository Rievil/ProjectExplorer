classdef OperLib < handle
    %OPERLIB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)

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
            
%             if strcmp(class(InArr),'cell')
%                 tmp=cell2mat(InArr);
%                 clear InArr;
%                 InArr=tmp;
%             end
%             
            switch lower(Type)
                case "string"
                    Arr=string(InArr);
                case "datetime"
                    
                case "double"
                    if isa(InArr,'double')
                        Arr=InArr;
                    else
%                         InArr=string(InArr);
                        Arr=str2double(InArr);
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
        
        %blueprint for variable selection
        function T=VarSelTable
            TypeName=categorical(["string","datetime","double"],{'string','datetime','double'},'ordinal',true);
            VarName="Vairable name";
            Unit="V";
            Description="Default text";
            T=table(VarName,TypeName(1),Unit,Description,'VariableNames',{'VarName','Type','Unit','Description'});
        end
        
        %Get All types that are present in datatype library
        function CTypes=GetTypes
            STRTypes=["MainTable","Press","Zedo"];
            CTypes = categorical(STRTypes,{'MainTable','Press','Zedo'},'Ordinal',true);
        end  
        
        %Get All types that are present in datatype library
        function S=AutoParagraph(String,ChLen)
            String=char(String);
            TotalChLen=numel(String);
            rows=round(TotalChLen/ChLen,0);
            if rows >1
                idx=find(char(String)==' ');
                old=0;
                n=0;
                for i=idx
                    n=n+1;
                    if i-old>ChLen
                        String=[String(1:i),'\n',String(i+1:end)];
                        idx(n+1:end)=idx(n+1:end)+2;
                        old=i;
                    end
                end
            end
            S=String;
            
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
    end    
end

