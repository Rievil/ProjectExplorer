classdef DAsymTab < RFile
    %DASYMTAB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RawData table;
    end
    
    methods
        function obj = DAsymTab(Filename)
            obj@RFile(Filename);
            
            obj.RawData=readtable(obj.Filename,'Sheet','Test Curve Data'); 
        end
        
        function ResamplePressData(obj,inT)
            T=table;
            TargetFreq=2;
            for i=1:2:size(inT,2)-1
                Time=inT{:,i};
                OrgFreq=1/(Time(2)-Time(1));
                if OrgFreq<TargetFreq
                    
                    [N,D] = rat(TargetFreq/OrgFreq);                                       % Rational Fraction Approximation
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

