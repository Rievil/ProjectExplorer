classdef ClassStatPlot < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        UIAxes               matlab.ui.control.UIAxes
        XaxisDropDownLabel   matlab.ui.control.Label
        XaxisDropDown        matlab.ui.control.DropDown
        YaxisDropDownLabel   matlab.ui.control.Label
        YaxisDropDown        matlab.ui.control.DropDown
        DrawdataButtonGroup  matlab.ui.container.ButtonGroup
        CloudsButton         matlab.ui.control.RadioButton
        MeansButton          matlab.ui.control.RadioButton
    end

    properties (Access = public)
        ClassStat; % Description
        DrawType; %draw clouds or means
        xn;
        yn;
        pHandle;
        SizeData;
    end
    
    methods (Access = public)
        
        function PlotFirst(app)
            warning('off','all');
            ClassData=app.ClassStat;
            nClases=length(ClassData.Stat.Classes);
            
            ax=app.UIAxes;
            
            hold( ax, 'on' );
            app.pHandle=[];
            

            switch app.DrawType
                case true
                    app.UIAxes.cla;
                    color=parula(nClases);
                    X=ClassData.Stat.Mean{:,app.xn};
                    [Xb,I]=sort(X);
                    Y=ClassData.Stat.Mean{:,app.yn};
                    
                    Xstd=ClassData.Stat.Std{:,app.xn};
                    Ystd=ClassData.Stat.Std{:,app.yn};
            
                    for i=1:nClases
                        Xi=Xb;
                        Yi=Y(I);
                        YSTDi=Ystd(I);
                        XSTDi=Xstd(I);
                        pHandle(i)=errorbar(ax,Xi(i),Yi(i),YSTDi(i),YSTDi(i),XSTDi(i),XSTDi(i),'o','Color','k',...
                            'MarkerSize',10,'MarkerFaceColor',[color(i,1) color(i,2) color(i,3)],'MarkerEdgeColor','k',...
                            'CapSize',10);
                    end     
                    colormap(ax,parula);
                case false
                    app.UIAxes.cla;
                    color=hsv(nClases);
                    Classes=table2array(ClassData.Classes);
                    
                    for i=1:nClases
                        Idx=find(Classes==ClassData.Stat.Classes(i));
                        X=ClassData.TrainDataSum{Idx,app.xn};
                        %[Xb,I]=sort(X);
                        Y=ClassData.TrainDataSum{Idx,app.yn};

                        %Xi=Xb;
                        %Yi=Y(I);
                        pHandle(i)=scatter(ax,X,Y,20,'MarkerFaceColor',[color(i,1) color(i,2) color(i,3)],...
                        'MarkerEdgeColor',[color(i,1) color(i,2) color(i,3)]);
                    
                    end 
                    colormap(ax,hsv);
            end
            %text(Xb+max(Xb)*0.02,Y(I)+max(Y)*0.08,str,'Units','data');
            
            xlabel(ax,strrep(ClassData.Stat.VarNames{app.xn},'_',' '));
            ylabel(ax,strrep(ClassData.Stat.VarNames{app.yn},'_',' '));
            %warning('on','all');
            c=colorbar(ax);
            c.Label.String='Clases';
            c.Box='on';
            app.pHandle=pHandle;
            ax.Title.String='Statistics of computed classes';
            %set(gca,'XScale','log');
            warning('on','all');
        end
    end
    
    methods (Access = private)
        
        function UpatePlot(app)
            warning('off','all');
            ClassData=app.ClassStat;
            nClases=length(ClassData.Stat.Classes);
            
            ax=app.UIAxes;
            color=parula(nClases);

            pHandle=app.pHandle;
            
            switch app.DrawType
                case true
                    app.UIAxes.cla;
                    color=parula(nClases);
                    X=ClassData.Stat.Mean{:,app.xn};
                    [Xb,I]=sort(X);
                    Y=ClassData.Stat.Mean{:,app.yn};
                    
                    Xstd=ClassData.Stat.Std{:,app.xn};
                    Ystd=ClassData.Stat.Std{:,app.yn};
                    
                    for i=1:nClases
                        Xi=Xb;
                        Yi=Y(I);
                        YSTDi=Ystd(I);
                        XSTDi=Xstd(I);
    
                        pHandle(i).XData=Xi(i);
                        pHandle(i).XNegativeDelta=XSTDi(i);
                        pHandle(i).XPositiveDelta=XSTDi(i);
    
                        pHandle(i).YData=Yi(i);
                        pHandle(i).YNegativeDelta=YSTDi(i);
                        pHandle(i).YPositiveDelta=YSTDi(i);
                        
                        pHandle(i).MarkerFaceColor=[color(i,1) color(i,2) color(i,3)];
                    end   
                    colormap(ax,parula);
                case false
                    app.UIAxes.cla;
                    color=hsv(nClases);
                    Classes=table2array(ClassData.Classes);
                    
                    for i=1:nClases
                        Idx=find(Classes==ClassData.Stat.Classes(i));
                        X=ClassData.TrainDataSum{Idx,app.xn};
                        %[Xb,I]=sort(X);
                        Y=ClassData.TrainDataSum{Idx,app.yn};
                        
                        pHandle(i).XData=X;
                        pHandle(i).YData=Y;
                        
                        pHandle(i).SizeData=app.SizeData;
                        pHandle(i).MarkerFaceColor=[color(i,1) color(i,2) color(i,3)];
                        pHandle(i).MarkerEdgeColor=[color(i,1) color(i,2) color(i,3)];
                        %Xi=Xb;
                        %Yi=Y(I);
%                         pHandle(i)=scatter(ax,X,Y,app.SizeData,'MarkerFaceColor',[color(i,1) color(i,2) color(i,3)],...
%                         'MarkerEdgeColor',[color(i,1) color(i,2) color(i,3)]);
                    %colormap(ax,hsv);
                    end 
            end
            
%             X=ClassData.Mean{:,app.xn};
%             [Xb,I]=sort(X);
%             Y=ClassData.Mean{:,app.yn};
%             
%             Xstd=ClassData.Std{:,app.xn};
%             Ystd=ClassData.Std{:,app.yn};
%             
%                 for i=1:nClases
%                     Xi=Xb;
%                     Yi=Y(I);
%                     YSTDi=Ystd(I);
%                     XSTDi=Xstd(I);
% 
%                     pHandle(i).XData=Xi(i);
%                     pHandle(i).XNegativeDelta=XSTDi(i);
%                     pHandle(i).XPositiveDelta=XSTDi(i);
% 
%                     pHandle(i).YData=Yi(i);
%                     pHandle(i).YNegativeDelta=YSTDi(i);
%                     pHandle(i).YPositiveDelta=YSTDi(i);
%                     
%                     pHandle(i).MarkerFaceColor=[color(i,1) color(i,2) color(i,3)];
%                 end
            %text(Xb+max(Xb)*0.02,Y(I)+max(Y)*0.08,str,'Units','data');
            
            xlabel(ax,strrep(ClassData.Stat.VarNames{app.xn},'_',' '));
            ylabel(ax,strrep(ClassData.Stat.VarNames{app.yn},'_',' '));
            warning('on','all');
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, StatClass)
            app.ClassStat=StatClass;
            app.xn=1; 
            app.yn=2;
                app.SizeData=20;           
            app.XaxisDropDown.Items=app.ClassStat.Stat.VarNames(1:end-1);
            app.XaxisDropDown.Value=app.ClassStat.Stat.VarNames{app.xn};
            app.YaxisDropDown.Items=app.ClassStat.Stat.VarNames(1:end-1);
            app.YaxisDropDown.Value=app.ClassStat.Stat.VarNames{app.yn};
            
            app.DrawType=app.DrawdataButtonGroup.SelectedObject.Value;
            
            PlotFirst(app);
            %app.VarNames=VarNames;
        end

        % Value changed function: XaxisDropDown
        function XaxisDropDownValueChanged(app, event)
            value = app.XaxisDropDown.Value;
            names=string(app.ClassStat.Stat.VarNames);
            app.xn=find(names==value);
            %UpatePlot(app);
            PlotFirst(app);
        end

        % Value changed function: YaxisDropDown
        function YaxisDropDownValueChanged(app, event)
            value = app.YaxisDropDown.Value;
            names=string(app.ClassStat.Stat.VarNames);
            app.yn=find(names==value);
            %UpatePlot(app);
            PlotFirst(app);
        end

        % Selection changed function: DrawdataButtonGroup
        function DrawdataButtonGroupSelectionChanged(app, event)
            selectedButton = app.DrawdataButtonGroup.SelectedObject;
            obj.DrawType=selectedButton.Value;      
            PlotFirst(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 654 526];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.Position = [29 97 584 405];

            % Create XaxisDropDownLabel
            app.XaxisDropDownLabel = uilabel(app.UIFigure);
            app.XaxisDropDownLabel.HorizontalAlignment = 'right';
            app.XaxisDropDownLabel.Position = [56 64 38 22];
            app.XaxisDropDownLabel.Text = 'X axis';

            % Create XaxisDropDown
            app.XaxisDropDown = uidropdown(app.UIFigure);
            app.XaxisDropDown.ValueChangedFcn = createCallbackFcn(app, @XaxisDropDownValueChanged, true);
            app.XaxisDropDown.Position = [109 64 100 22];

            % Create YaxisDropDownLabel
            app.YaxisDropDownLabel = uilabel(app.UIFigure);
            app.YaxisDropDownLabel.HorizontalAlignment = 'right';
            app.YaxisDropDownLabel.Position = [56 39 38 22];
            app.YaxisDropDownLabel.Text = 'Y axis';

            % Create YaxisDropDown
            app.YaxisDropDown = uidropdown(app.UIFigure);
            app.YaxisDropDown.ValueChangedFcn = createCallbackFcn(app, @YaxisDropDownValueChanged, true);
            app.YaxisDropDown.Position = [109 39 100 22];

            % Create DrawdataButtonGroup
            app.DrawdataButtonGroup = uibuttongroup(app.UIFigure);
            app.DrawdataButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @DrawdataButtonGroupSelectionChanged, true);
            app.DrawdataButtonGroup.Title = 'Draw data:';
            app.DrawdataButtonGroup.Position = [227 25 123 73];

            % Create CloudsButton
            app.CloudsButton = uiradiobutton(app.DrawdataButtonGroup);
            app.CloudsButton.Text = 'Clouds';
            app.CloudsButton.Position = [11 27 59 22];
            app.CloudsButton.Value = true;

            % Create MeansButton
            app.MeansButton = uiradiobutton(app.DrawdataButtonGroup);
            app.MeansButton.Text = 'Means';
            app.MeansButton.Position = [11 5 65 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ClassStatPlot(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end