classdef PlotPreview < Item
    %PLOTPREVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UITab;
        UIPlotTypeOptions;
        PlotTypeName;
        PlotType;
        UIAXPanel;
        Init=false;
        Value=0;
        ProjectType=[];
    end
    
    events
        PlotChange;
    end
        
    methods
        function obj = PlotPreview(parent)
            obj.Parent=parent;
        end
        
        function SetPlotType(obj)
            switch lower(obj.PlotTypeName)
                case 'single plot'
                    obj2=PlotSimple(obj);
                    
                case 'subplot'
                    
                case 'zoom plot'
                    
                otherwise
            end
            obj2.UIAxPanel=obj.UIAXPanel;
            obj2.UIPanel=obj.UIPlotTypeOptions;
%             obj2.SetGui(obj.UIPlotTypeOptions);
            obj2.DrawGui;
            
            obj.PlotType=obj2;
        end
        
    end
    
     methods %abstract
        function DrawGui(obj)
            ClearGUI(obj);
            g=uigridlayout(obj.Fig(1));
            g.RowHeight = {75,25,25,'1x'};
            g.ColumnWidth = {'1x',350};
            
            panel=uipanel(g,'Title','Plot type selection');
            panel.Layout.Row=[1 3];
            panel.Layout.Column=2;
            
            axpanel=uipanel(g,'Title','Axis preview');
            axpanel.Layout.Row=[1 4];
            axpanel.Layout.Column=1;
            
            obj.UIAXPanel=axpanel;
            
            g2=uigridlayout(panel);
            g2.RowHeight = {25,'1x',25,25};
            g2.ColumnWidth = {25,'1x','1x',25};
            
            la1=uilabel(g2,'Text','Select plot type:');
            la1.Layout.Row=1;
            la1.Layout.Column=[1 2];
            
            if ~obj.Init==true
                val=1;
            else
                val=obj.Value;
            end
            
            dd = uidropdown(g2,'Items',{'Single plot','Subplot','Zoom plot'},...
                     'Value',val,'ItemsData',[1 2 3],'ValueChangedFcn',@obj.MChangePlotType);
            dd.Layout.Row=1;
            dd.Layout.Column=[3 4];
            
            bg = uibuttongroup(g2,'SelectionChangedFcn',@obj.MProjectionSelected);
            bg.Layout.Row=[2 4];
            bg.Layout.Column=[1 2];
            
            r1 = uiradiobutton(bg,'Text','2D Projection','Position',[10 38 91 15]);
            r2 = uiradiobutton(bg,'Text','3D Projection','Position',[10 10 91 15]);
            
            if ~isempty(obj.ProjectType)
                switch obj.ProjectType
                    case '2D Projection'
                        bg.SelectedObject=r1;
                    case '3D Projection'
                        bg.SelectedObject=r2;
                end
            else
                obj.ProjectType='2D Projection';
            end

            plottypepanel=uipanel(g,'Title','Plot type options');
            plottypepanel.Layout.Row=4;
            plottypepanel.Layout.Column=2;

            obj.UIPlotTypeOptions=plottypepanel;
            
            if ~isempty(obj.PlotTypeName)
                obj.PlotType.UIPanel=obj.UIPlotTypeOptions;
                obj.PlotType.UIAxPanel=obj.UIAXPanel;
                DrawGui(obj.PlotType);
            end
        end
        
        function stash=Pack(obj) 
            stash=struct;
            stash.Name=obj.Name;
            stash.Specific=CoPack(obj);
        end
        
        function Populate(obj,stash) 
            obj.Name=stash.Name;
            CoPopulate(obj,stash.Specific);
        end
     end
    
     methods %callbacks
         function MChangePlotType(obj,src,evnt)
            fig = OperLib.FindProp(obj,'UIFig');
            selection = uiconfirm(fig,['Changing the plot type will erase',...
                'all options for figure, do you want to continue?'],'Change plot type',...
                        'Icon','warning');
            switch selection
                case 'OK'
                    obj.Value=src.Value;
                    obj.PlotTypeName=lower(src.Items{evnt.Value});
                    obj.SetPlotType;
                    obj.notify('PlotChange');
                    obj.Init=true;
                otherwise
                    src.Value=evnt.PreviousValue;
                    obj.PlotTypeName=lower(src.Items{evnt.Value});
            end
            
         end
         
         function MProjectionSelected(obj,src,~)
             obj.ProjectType=src.SelectedObject.Text;
             switch obj.ProjectType
                 case '2D Projection' %2D
                     obj.PlotType.View=[0 90];
                 case '3D Projection' %3D
                     obj.PlotType.View=[15 35];
             end
             obj.PlotType.setView;
         end
         
     end
end

