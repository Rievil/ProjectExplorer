classdef PlotterObj < handle
    %This class will recalculate stored data in selctor, it will drag them
    %together and prepare them for all kinds of operations
    
    properties (SetAccess = public)
        Ax; %selected axis for plotting
        UITable; %handle for ui Table
        Tables;
        GObj; %drawn graphical objects
    end
    
    methods (Access = public)
        function obj=PlotterObj(ax,tab)
            obj.Ax=ax;
            obj.UITable=tab;            
        end
        
        %plot single x,y
        function Plot(obj,x,y,type)
            hold(obj.Ax,'on');
            switch type
                case 'line'
                    for i=1:numel(x)
                        obj.GObj(i)=plot(obj.Ax,x{i},y{i});
                    end
                case 'scatter'
                    for i=1:numel(x)
                        obj.GObj(i)=scatter(obj.Ax,x{i},y{i});
                    end
            end
            
            roi = drawcrosshair(obj.Ax);
            addlistener(roi,'MovingROI',@(src,data)displayInfo(src,data,hAx,img));
            
            obj.Ax.YLabel.String ='Defformation';
            obj.Ax.XLabel.String ='Force';
        end
    end
end