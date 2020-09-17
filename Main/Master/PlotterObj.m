classdef PlotterObj < handle
    %This class will recalculate stored data in selctor, it will drag them
    %together and prepare them for all kinds of operations
    
    properties (SetAccess = public)
        PlotterWin;
        Ax; %selected axis for plotting
        Panel matlab.ui.container.Panel; %handle for ui Table
        Tables;
        GObj; %drawn graphical objects
        Children; %elements in panel for controling specific plot
    end
    
    properties (SetAccess = private)
        MasterF char; 
    end
    
    methods (Access = public)
        function obj=PlotterObj(ax,panel,app)
            obj.Ax=ax;
            obj.Panel=panel;            
            obj.PlotterWin=app;
            obj.MasterF=app.PEH.MasterFolder;
        end
        
        %plot single x,y
        function Plot(obj,x,y,type)
            hold(obj.Ax,'on');
            switch type
                case 'line'
                    for i=1:numel(x)
                        obj.GObj{i}=plot(obj.Ax,x{i},y{i});
                    end
                case 'scatter'
                    for i=1:numel(x)
                        obj.GObj{i}=scatter(obj.Ax,x{i},y{i});
                    end
            end
            obj.Ax.YLabel.String ='Defformation';
            obj.Ax.XLabel.String ='Force';
            
            DrawLabel(obj);
            DrawDropDownMenu(obj);
            DrawCancelButton(obj);
        end
        
        function DrawDropDownMenu(obj)
            Pos=[10,350,160,20];

            obj.Children(2)=uidropdown(obj.Panel,'Items',{'-',':','--'},...
                     'Value','-','Position',Pos,...
                     'ValueChangedFcn',@(src,event)DropDownChange(obj,event));                        
        end
        
        function DrawLabel(obj)
            Pos=[10,380,200,20];
            obj.Children(1)=uilabel(obj.Panel,'Text','LineControl','Position',Pos);
        end
        
        
        function DrawCancelButton(obj)
            PS=obj.Panel.Position;
            CloseIconF=[obj.MasterF 'GUI\Icons\cancel_button.gif'];
            
            Pos=[160, 380, 20, 20];
            
                obj.Children(3)=uibutton(obj.Panel,'push',...
                    'Text','',...
                    'Icon',CloseIconF,...
                    'Position',Pos,...
                    'ButtonPushedFcn',@(src,event)CloseClick(obj,event));
                %obj.Children{3}=btn;
        end
        
        function DropDownChange(obj,event)
            for i=1:numel(obj.GObj)
                obj.GObj{i}.LineStyle=event.Value;
            end
        end
        
        function CloseClick(obj,event)
            cla(obj.Ax);            
            delete( obj.Children(obj.Children > 0) );
        end
    end
end