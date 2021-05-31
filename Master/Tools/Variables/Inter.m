classdef Inter < VarOperator
    %INTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MainX;
        SupX;
        SupY;
        Type;
        PointReq;
        SelType;
    end
    
    properties (Dependent)
        MainY;
    end
    
    methods
        function obj = Inter(~)
            obj@VarConcept;
            obj.Type={'spline','linear','nearest','next','previous','pchip','cubic','makima'};
            obj.PointReq=[2,2,2,2,4,3,2,4];
        end

        function SelectType(obj,id)
            TypeCount=numel(obj.Type);
            if id>0 && id <=TypeCount
                obj.SelType=obj.Type{id};
            end
        end
        
        function SetMainX(obj,var)
            [var2, index] = unique(var); 
            obj.MainX=var(index);
        end
        
        function SetSupX(obj,var)
            [var2, index] = unique(var); 
            obj.SupX=var(index);
        end
        
        function SetSupY(obj,var)
            [var2, index] = unique(var); 
            obj.SupY=var(index);
        end
        
        function arr=get.MainY(obj)            
            arr = interp1(obj.SupX,obj.SupY,obj.MainX,char(obj.SelType));
        end
        

    end
    
    methods %abstract
        function DrawGui(obj)
        end
        
        
        function RunTool(obj)
        end
        
        function stash=Pack(obj)
        end
        
        function Populate(obj)
        end
    end
end

