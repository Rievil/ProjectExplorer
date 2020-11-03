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
            Num=1;
            T=table(ColNames(1),Key,Label,Num,'VariableNames',{'ColType','Key','Label','ColNumber'});
        end
        
        %Get All types that are present in datatype library
        function CTypes=GetTypes
            STRTypes=["MainTable","Press","Zedo"];
            CTypes = categorical(STRTypes,{'MainTable','Press','Zedo'},'Ordinal',true);
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

