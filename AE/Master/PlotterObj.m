classdef PlotterObj < handle
    %This class will recalculate stored data in selctor, it will drag them
    %together and prepare them for all kinds of operations
    
    properties (SetAccess = public)
        Ax; %selected axis for plotting
        UITable; %handle for ui Table
        Tables;
    end
    
    methods (Access = public)
        function obj=PlotterObj(ax,tab)
            obj.Ax=ax;
            obj.UITable=tab;            
        end
        
        function Plot(obj,x,y)
            plot(obj.Ax,x,y);
            %obj.Ax.YLabel.String ='Defformation';
            %obj.Ax.XLabel.String ='Force';
        end
    end
end