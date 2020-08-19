classdef UICreator < handle
    properties (SetAccess = public)
        Panel; %panel retrived from project explorer
        Project ProjectObj; %project which is been drawed
        Meas MeasObj; %handle to specific meas object
    end
    
    methods (Access = public) %control and filling of panel
        %class constructor
        function obj=UICreator(Panel,Project)
            obj.Panel=Panel;
            obj.Project=Project;
            ClearPanel(obj);
            CreateComponents(obj);
        end
        
        %clear panel
        function ClearPanel(obj)
            Ch=obj.Panel.Children;
            while numel(Ch)>0
                Ch.delete;
            end
        end
    end
    
    %callbacks of created functions
    methods (Access = public)
    end
    
    %creates ui control handles on panel
    methods (Access = private)
        function CreateComponents(obj)
            ef1 = uieditfield(obj.Panel,'text','Position',[0 0 140 22],'Value','First Name');
        end
    end
end