classdef Adress < handle
    %ADRESS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name (1,1) string;
        OrigName (1,1) string;
        FinalType (1,1) string;
        Type (1,:) string;
        Path (1,:) string;
        Num (1,:) double;
        Size (1,2) double;
        Parent;
        CurrArr;
        ArrType;
        Label (1,1) string;
    end
    
    methods
        function obj = Adress(parent,t)
            obj.Parent=parent;
            setAdress(obj,t);
        end
        
        function data=GetSampleData(obj)
            disp('test');
        end

        function setAdress(obj,t)
            obj.OrigName=t.Name;
            obj.Type=t.Type;
            obj.Path=t.Path;
            obj.Size=t.Size;
            obj.Num=t.Num;
            obj.CurrArr=t.CurrArr;
            obj.ArrType=t.ArrType;
        end
        
        function t=GetRow(obj)
            
            if isempty(obj.Label)
                obj.Label=string(sprintf('Adress n'));
            end
            t=table(string(obj.Label),string(obj.ArrType),obj.OrigName,obj.Type(end),obj.Size,...
                            'VariableNames',{'Label','Source','Name','Type','Size'});
        end

        function arr=GetVar(obj,data)
        
            A=data(obj.CurrArr).data;
            for i=1:numel(obj.Path)
                typeIN=class(A);
                switch typeIN
                    case 'struct'
                        A=A(obj.Num(i)).(obj.Path{i});
                    case 'table'
                        if obj.Num(i)==0
                            A=A.(obj.Path{i});
                        else
                            A=A.(obj.Path{i});

                        end
                    otherwise
                end
            end
            arr=A;
        end
    end
    
end


