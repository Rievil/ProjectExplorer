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
        function T=MTBlueprint
            ColNames=categorical(["StrName","DateTime","Number","Category"],{'StrName','DateTime','Number','Category'},'ordinal',true);
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
    end    
end

