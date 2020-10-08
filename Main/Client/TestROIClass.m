classdef TestROIClass < handle
    properties (SetAccess = public)
        fig;
        data;
        ax;
        h;
        point;
        step (1,1) double;
        idx;
        xleft;
        xright;
        xlold;
        xrold;
        trig logical;
    end
    
    methods (Access = public)
        function obj=TestROIClass(data)
            obj.fig=figure('WindowScrollWheelFcn',@(src,data) WheelFcn(obj,src,data));
            obj.idx=1;
            obj.step=1;
            obj.data=data;

            x=obj.data(:,1); y=obj.data(:,2);
            obj.ax=gca;
            hold(obj.ax,'on');
            plot(obj.ax,x,y);
            obj.point=plot(obj.ax,0,0,'ro');
            
            
            trig=0;
            obj.h = drawcrosshair('parent',obj.ax,'LineWidth',1,'Color','y');

            addlistener(obj.h,'MovingROI',@(src,data)displayInfo(obj,src,data,obj.ax));
        end
        
        function displayInfo(obj,src,data,ax)
            
            obj.idx=find(obj.data(:,1)>data.CurrentPosition(1,1),1,'first')-1;
            obj.point.XData=obj.data(obj.idx,1);
            obj.point.YData=obj.data(obj.idx,2);
            
            src.Label = num2str(obj.data(obj.idx,1));
            
        end
        
        function WheelFcn(obj,src,event)
            obj.step=obj.step+event.VerticalScrollCount(1);

            if obj.step<1
                obj.step=1;
            end

            if obj.step>100
                obj.step=100;
            end

            percent=obj.step/101;
            
            obj.xleft=round(obj.idx-obj.idx*(1-percent),0);
            obj.xright=round(obj.idx+(numel(obj.data(:,1))-obj.idx)*(1-percent),0);
            

            
            
            mid=round((obj.xright+obj.xleft)/2,0);
            

            
            
            obj.ax.XLim=[obj.data(obj.xleft,1), obj.data(obj.xright,1)];
            
        end
    end
end