classdef PlotAppControl
    %PLOTAPPCONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Panel; %panel which is beeing used for user control
        PlotDesigner;
        Parent; %app itself
        Data; %dataloader data
        DataCarousel;
        Mode=1; %if 0 then manual if 1 then automatic
    end
    
    methods
        function obj = PlotAppControl(Panel,Parent)
            obj.Panel=Panel;
            obj.Parent=Parent;
            
            obj.PlotDesigner=PlotDesigner;
            
            IniciateGui(obj);
        end
        
        function FillGui(obj,Project)
            FillGui(obj.PlotDeisgner,Project);
        end

        function IniciateGui(obj)
            %will draw all nessesary gui for plotter
            VP=obj.Panel.Position(4)+223;
            
            bg = uibuttongroup(obj.Panel,'Position',[10, VP, 115, 80],...
                'SelectionChangedFcn',@ChangeMode,'UserData',obj);
            function ChangeMode(obj,event)
                objParent=obj.UserData;
                if strcmp(event.NewValue.Text,'Automatic')
                    objParent.Mode=1;
                else
                    objParent.Mode=0;
                end
            end
            % Create three radio buttons in the button group.
            r1 = uiradiobutton(bg,'Position',[10 45 95 25],'Text','Automatic');
            r2 = uiradiobutton(bg,'Position',[10 10 95 25],'Text','Manual');
            
            Label_1 = uilabel(obj.Panel,'Position',[10,VP-20,200,25],'Text','Variable selection');
            VarTable=uitable(obj.Panel,'Position',[10,VP-225,400,200]);
            
        end
        
        
    end
    
    methods %Callbacks
        
    end
end

