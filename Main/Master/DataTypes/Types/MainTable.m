classdef MainTable < DataFrame
    %MAINTABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
       Name char;
       
    end
    
    properties (Access = private)
    end
    
    methods
        function obj = MainTable(~)
            obj@DataFrame;
        end
        
        %will read data started from dataloader
        function Read(obj,varargin)
            
        end
    end

    %Gui for data type selection 
    methods (Access = public)   
        %set property
        function SetVal(obj,val,idx)
            obj.TypeSet{idx}=val;
        end       
        %adrow in table
        function TypeAdRow(obj,Value,idx,Target)
            obj.TypeSet{idx}=Value;
            dim=size(Target.Data);
            if dim(1)~=Value
                if Value>dim(1)
                    Target.Data=[Target.Data; MTBlueprint(obj)];
                    Target.Data{end,4}=Value;
                else
                    Target.Data(end,:)=[];
                end
                obj.TypeSet{Target.UserData{2}}=Target.Data;
            end
        end
        %will initalize gui for first time
        function InitializeOption(obj)
            
            Clear(obj);

            Target=DrawUITable(obj,MTBlueprint(obj),@SetVal);
            DrawSpinner(obj,[1 20],Target,@TypeAdRow);
            DrawLabel(obj,['Select composition of main table: by spinner select number of columns \n',...
                           'and choose the type of each column, column position in source file.\n',...
                           'IMPORTANT: there can be only one KeyColumn'],[300 60]);
        end
    end
end

