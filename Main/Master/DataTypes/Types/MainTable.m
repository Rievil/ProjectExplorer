classdef MainTable < DataFrame
    %MAINTABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name char;

    end
    
    methods
        function obj = MainTable(Name)
            obj@DataFrame;
            obj.Name=Name;
            

        end
        
        %will read data started from dataloader
        function Read(obj,varargin)
            
        end
        
        %will draw options for current data type
        function DrawTypeOption(obj,parent)
            DrawDropDownMenu(obj,parent,{'-',':','ss'});
            DrawDropDownMenu(obj,parent,{'Ahoj','Nee','Dobrı'});
        end
        
    end
end

