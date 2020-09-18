classdef MainTable < DataFrame
    %MAINTABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name char;
        val;
    end
    
    methods
        function obj = MainTable(Name,Parent)
            obj@DataFrame(Parent);
            obj.Name=Name;
            

        end
        
        %will read data started from dataloader
        function Read(obj,varargin)
            
        end
        
        %set property
        function SetVal(obj,val)
            obj.val=val;
        end
    end
    
    %Gui Methods
    methods (Access = public)
        %will draw options for current data type
        function DrawTypeOption(obj)
            if obj.Init
                InitializeOption(obj);
                CheckOptions(obj);
            else
                InitializeOption(obj);
            end
        end

        %will initalize gui for first time
        function InitializeOption(obj)
            GuiInit(obj);
            DrawDropDownMenu(obj,{'-',':','ss'},@SetVal);
            obj.val='-';
            %DrawDropDownMenu(obj,{'Ahoj','Nee','Dobrı'},'second');
        end

        %will update gui according to row in tabletype selector
        function CheckOptions(obj)
            for i = 1:numel(obj.Children)
                obj.Children{i}.Value=obj.val;
            end
        end
    end
end

