classdef PlotterObj < handle
    %This class will recalculate stored data in selctor, it will drag them
    %together and prepare them for all kinds of operations
    
    properties (SetAccess = public)
        Ax; %selected axis for plotting
        Panel; %handle for ui Table
        Tables;
        GObj; %drawn graphical objects
        Children; %elements in panel for controling specific plot
    end
    
    methods (Access = public)
        function obj=PlotterObj(ax,panel)
            obj.Ax=ax;
            obj.Panel=panel;            
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
            
            %roi = drawcrosshair(obj.Ax);
            %addlistener(roi,'MovingROI',@(src,data)displayInfo(src,data,hAx,img));
            
            obj.Ax.YLabel.String ='Defformation';
            obj.Ax.XLabel.String ='Force';
            
            DrawDropDownMenu(obj)
            
        end
        
        function DrawDropDownMenu(obj)
            PanelPos=obj.Panel.Position;
            Pos=[PanelPos(1)+5 PanelPos(4)-60 ...
                PanelPos(3)-20 20];

            obj.Children{1}=uidropdown(obj.Panel,'Items',{'-',':','--'},...
                     'Value','-','Position',Pos,...
                     'ValueChangedFcn',@(src,event)DropDownChange(obj,event));                        
        end
        
        function DropDownChange(obj,event)
            for i=1:numel(obj.GObj)
                obj.GObj{i}.LineStyle=event.Value;
            end
        end
    end
end