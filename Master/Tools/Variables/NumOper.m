classdef NumOper < handle
    %NUMOPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = NumOper(~)
        end
        
        function out=ConvertToNum(obj,arr)
            out=arr;
            n=0;
            while ~strcmp(class(out),'double') && n<11
                n=n+1;
                switch class(out)
                    case 'seconds'
                        out=datenum(out);
                    case 'datetime'
                        out=seconds(out);
                    case 'duration'
                        out=seconds(out);
                    case 'time'
                        out=datenum(out);
                    case 'char'
                        out=double(out);
                    case 'cell'
                        out=cell2mat(out);
                    case 'string'
                        out=double(out);
                    otherwise
                end
            end
            
            if n>10
                out=arr;
            end
        end


    end
end

