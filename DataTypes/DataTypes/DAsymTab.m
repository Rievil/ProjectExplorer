classdef DAsymTab < RFile
    %DASYMTAB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RawData table;
        ColSize (1,1) uint32;
    end
    
    methods
        function obj = DAsymTab(Filename,ColSize)
            obj@RFile(Filename);
            obj.ColSize=ColSize;
            
            obj.RawData=readtable(obj.Filename,'Sheet','Test Curve Data'); 
            SplitData(obj);
        end
        
        function SplitData(obj)
            n=0;
            for i=1:obj.ColSize:size(obj.RawData,2)-obj.ColSize+1
                TMP=obj.RawData{:,i:i+obj.ColSize-1};
                for j=1:obj.ColSize
                    TMP2=TMP(:,j);
                    TMP3(:,j)=TMP2(~isnan(TMP2));
                end
                n=n+1;
                obj.Data{n}=TMP3;
                clear TMP TMP2 TMP3;
            end
        end
        
        function ResamplePressData(obj,inT)
            T=table;
            TargetFreq=2;
            for i=1:2:size(inT,2)-1
                Time=inT{:,i};
                OrgFreq=1/(Time(2)-Time(1));
                if OrgFreq<TargetFreq
                    
                    [N,D] = rat(TargetFreq/OrgFreq); % Rational Fraction Approximation
                    Check = [TargetFreq/OrgFreq, N/D] ;

                    tmpTime=resample(inT{:,i},N,D);
                    tmpArr=resample(inT{:,i+1},N,D);
                    
                    T{:,i}=tmpTime;
                    T{:,i+1}=tmpArr;
                else
                    T{:,i}=inT{:,i};
                    T{:,i+1}=inT{:,i+1};
                end
            end
        end
    end
end

