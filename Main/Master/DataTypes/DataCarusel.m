classdef DataCarusel < handle
    properties (SetAccess = public)
        InTab table; %input data table
        Columns (:,1) double; %columns with unq data sets to be retrived
        RealComb table;
        RealCombCount (1,1) double;
        NumRealComb table;
        CurrComb (1,:) double;
        RawComb struct; %raw formated combinations
        ColumnNames string; %name of columns
        
        CombCount double;
        ColCount;
        ColSum;
        Comb table;
    end
    
    properties (Hidden)

        
    end
    
    properties (SetAccess = private)
        FTable table;
        FIndex (:,1);
    end
    
    methods (Access = public)
        %constructor
        function obj=DataCarusel(Data,Columns)
            arguments 
                Data table;
                Columns (1,:) double;
            end
            obj.InTab=Data;
            obj.Columns=Columns;
            obj.ColCount=numel(Columns);
            obj.ColumnNames=obj.InTab.Properties.VariableNames;
            
            %will get unique values of each selected column
            obj.RawComb=struct;
            for i=1:numel(obj.Columns)
                obj.RawComb(i).VarLabel=class(obj.InTab{1,obj.Columns(i)});
                obj.RawComb(i).ID=obj.Columns(i);
                obj.RawComb(i).ColLabel=char(obj.ColumnNames(obj.Columns(i)));
                obj.RawComb(i).UnqVal=unique(obj.InTab(:,obj.Columns(i)));
                obj.RawComb(i).UnqCount=1:1:numel(obj.RawComb(i).UnqVal);
            end
            UnqComb(obj);
            GetRealComb(obj);
        end
        
        %get the combinations with id num
        function UnqComb(obj)
            obj.CombCount=1;
            obj.ColSum=0;
            TMP=char('');
            for i=1:obj.ColCount
                obj.ColSum=obj.ColSum+numel(obj.RawComb(i).UnqVal);
                obj.CombCount=obj.CombCount*numel(obj.RawComb(i).UnqVal);
                TMP=[TMP 'obj.RawComb(' char(num2str(i)) ').UnqCount,'];
            end
            
            eval(['TMPTab=combvec(' TMP(1:end-1) ');']);
            
            for i=1:obj.ColCount
                obj.Comb=[obj.Comb, table(TMPTab(i,:)','VariableNames',obj.ColumnNames(obj.Columns(i)))];
            end
        end
        
        
        function GetRealComb(obj)
            %selMat=1:1:obj.CombCount;
            %selMat=zeros([obj.CombCount,1]);
            selMat=[];
            for c=1:obj.CombCount
                BaseTab=obj.InTab;
                
                for i=1:obj.ColCount
                    ColNum=table2array(obj.Comb(c,i));
                    UnqVal=table2array(obj.RawComb(i).UnqVal(ColNum,1));
                    BaseTab=BaseTab(BaseTab{:,obj.Columns(i)}==UnqVal,:);
                end
                
                if size(BaseTab,1)>0
                    selMat=[selMat; c];
                end
            end
            obj.NumRealComb=obj.Comb(selMat,:);
            [E,index] = sortrows(obj.NumRealComb,1);
            obj.NumRealComb=E;
            
            MDM=size(obj.NumRealComb);
            IdxArr=table2array(obj.NumRealComb);
            for i=1:MDM(2)
                for j=1:MDM(1)
                    obj.RealComb(j,i)=obj.RawComb(i).UnqVal(IdxArr(j,i),1);
                end                                
            end     
            
            for i=1:obj.ColCount
                VarNames{1,i}=obj.RawComb(i).ColLabel;
            end
            obj.RealComb.Properties.VariableNames=VarNames;
            obj.RealCombCount=size(obj.RealComb,1);
        end      
        
        function [FTable,B]=GetCombinations(obj,CRows)
            arguments
                obj;
                CRows (1,:) double;
            end
            obj.CurrComb=CRows;

            
            FTable=table;
            for ColNum=obj.CurrComb
                nFTable=obj.InTab;
                for i=1:obj.ColCount
                    nFTable=nFTable(nFTable{:,obj.Columns(i)}==obj.RealComb{ColNum,i},:);
                end
                FTable=[FTable; nFTable];
            end
            obj.FTable=FTable;               
            [A,B]=intersect(obj.InTab{:,1},obj.FTable{:,1});
            %TMpIDx=find(obj.InTab{:,1}==A);
            obj.FIndex=B;
        end        
    end
end