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
    
    %Data helpers
    methods (Access = public)
        function T=MTBlueprint(obj)
            ColNames=categorical(["Name","DateTime","Number","Category"],'ordinal',true);
            Key=false;
            Label="Name of column";
            Num=1;
            T=table(ColNames(1),Key,Label,Num,'VariableNames',{'ColType','Key','Label','ColNumber'});
        end
        
    end
    

end

