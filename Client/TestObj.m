classdef TestObj < handle
    %TESTOBJ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties  
        prop;
    end
    
    methods
        function obj = TestObj(~)
            obj.prop='zelené auto';
        end

        function Save(obj)
            obj.prop='modré auto';
            save([cd '\TestMat.mat'],'obj');
        end
        
        function Load(objm)
            load([cd '\TestMat.mat'],'obj');
            objm=obj;
        end
    end
end

