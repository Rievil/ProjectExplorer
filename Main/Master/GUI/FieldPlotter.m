classdef FieldPlotter < handle
    %FIELDPLOTTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data;
        GraphFolder char;
        Interpreter char;
        Result struct;
        PlotTypes;
        Type;
        IsTotalTable logical;
        CopyD;
        Parent;
        IsAssociated=0;
        UITable;
        Panel;
        Project;
        VertMarker;
    end
    
    properties %plot styles, colors, lines, markers
        Figure;
        TabGroup;
        Count;
        Lines;
        Thick;
        Marker;
        Colors;
        Axes;
        D3Plot logical;
        Y2Axis logical;
        CurrLine;
        GUI;
        CurrentGOID;
        View;
        Is3D=0;
        FigSize;
        
    end
    
    methods
        function obj = FieldPlotter(~)
            obj.IsTotalTable=0;
            %obj.GraphFolder=GraphFolder;
            obj.PlotTypes={'basic','events','velocity','tensile_shear',...
                'selective','events2'};
        end
        
        function AssociateApp(obj,app)
            obj.IsAssociated=1;
            obj.Parent=app;
        end
        
        function types=GetTypes(obj)
            types=obj.PlotTypes;
        end
        
        function PutData(obj,node)
            obj.Project=node;
            obj.Data=obj.Project.TotalTable;
            obj.IsTotalTable=1;
        end
        
        function Data=GetData(obj)
            Data=obj.CopyD;
        end
        function Plot(obj,Type,Interpreter)
            obj.Interpreter=Interpreter;
            obj.Type=lower(Type);
            obj.Result
            obj.CurrLine=[];
            switch lower(Type)
                case 'basic'
                    obj.Is3D=0;
                    obj.Y2Axis=1;
                    GeneralPlot(obj,@PlotBasic);
                    SaveFigures(obj);
                case 'events'
                    obj.Is3D=1;
                    obj.Y2Axis=0;
                    GeneralPlot(obj,@PlotEvents);
                    SaveFigures(obj);
                    %PlotEvents(obj);
                case 'velocity'
                    obj.Is3D=0;
                    obj.Y2Axis=0;
                    GeneralPlot(obj,@PlotVelocity);
                    SaveFigures(obj);
                case 'tensile_shear'
                    obj.Is3D=0;
                    obj.Y2Axis=0;
                    obj.View=[];
                    GeneralPlot(obj,@PlotShearTensile);
                    SaveFigures(obj);
                case 'selective'
                    obj.Is3D=0;
                    obj.GUI=true;
                    obj.Y2Axis=1;
                    GeneralPlot(obj,@PlotSelective);
                    obj.GUI=false;
                case 'events2'
                    obj.Is3D=1;
                    obj.Y2Axis=0;
                    GeneralPlot(obj,@PlotEvents2);
                    SaveFigures(obj);
            end
            
        end
        function SaveFigures(obj)
            GetLimits(obj);
            SaveFiles(obj);
        end
        
        function SaveFig(obj,UIAxes,Filename)
            %h = figure;
            copyUIAxes(UIAxes);
            h=gcf;
            ax=gca;
            
            if obj.Is3D==1
                set(ax,'view',obj.View);
            end
            
            set(h,'Position',[200 200 550 450]);
            saveas(h,Filename,'png');
            delete(h)
        end
        
        function GetLimits(obj)
            x=[];
            y=[];
            z=[];
            n=0;
            for i=1:size(obj.Result,2)

                    n=n+1;
                    x(n,:)=obj.Result(i).Axes.XLim;
                    y(n,:)=obj.Result(i).Axes.YLim;
                    z(n,:)=obj.Result(i).Axes.ZLim;
                    if obj.Y2Axis==1
                        tmp=obj.Result(i).Axes.YLim;
                        y2(n,:)=obj.Result(i).Axes.YAxis.Limits;  
                    end
            end
            

            for i=1:size(obj.Result,2)

                    obj.Result(i).Axes.XLim=[min(x(:,1)) max(x(:,2))];
                    obj.Result(i).Axes.YLim=[min(y(:,1)) max(y(:,2))];
                    obj.Result(i).Axes.ZLim=[min(z(:,1)) max(z(:,2))];
                    if obj.Y2Axis==1
                        obj.Result(i).Axes.YAxis(1).Limits=[min(y2(:,1)) max(y2(:,2))];
                    end
            end
        end
        function SaveFiles(obj)
            for i=1:size(obj.Result,2)
                SaveFig(obj,obj.Result(i).Axes,obj.Result(i).SaveFilename);
                %saveas(obj.Result(i).FigHan,obj.Result(i).SaveFilename);
            end
        end
    end
    
    methods %settings for plots, fonts, sizes, colros etc.
        function SetAxes(obj,ax)
            set(ax,'FontName','Palatino linotype','FontSize',12,'LineWidth',1.2);
        end
        
        function SetSyle(obj,Num)
            Count=round(Num/4,0)+1;
            LT={'-','--','-.',':'};
            obj.Figure.Colormap=lines(Num);
            obj.Colors=obj.Figure.Colormap;
            obj.View=[-21,37];
            
            marker={'none','none','none','none';... 
                'none','none','none','none';...
                'o','o','o','o';...
                'd','d','d','d';...
                's','s','s','s';...
                '^','^','^','^';...
                'v','v','v','v';...
                '|','|','|','|';...
                'h','h','h','h';...
                '+','+','+','+';...
                '*','*','*','*';...            
                'p','p','p','p'};
            obj.VertMarker=marker;
            
            for i=1:Count
                obj.Lines=[obj.Lines, LT];
                obj.Thick=[obj.Thick, linspace(1+(i-1)*0.9,1+(i-1)*0.9,4)];
                obj.Marker=[obj.Marker, marker(i,:)];
            end

        end
    end
    methods %Plotting methods
        function FT=GetFilter(obj)
            FT=table;
            for i=1:size(obj.Data,1)
                FT=[FT; obj.Data.MainTable(i).Data];
            end
        end
        
        function GeneralPlot(obj,AnFun)

            FigNum=0;
            
            FT=GetFilter(obj);
            
            [FT,NewIdx]=sortrows(FT,[9,13,10],'descend');
            obj.Data=obj.Data(NewIdx,:);
            
            Carousel=DataCarusel(FT,[9]);
            
            %set(gcf,);
            BaseSize=[200 200 750 550];
            obj.Figure=uifigure('Position',BaseSize);
            obj.TabGroup = uitabgroup(obj.Figure,'Position',[25 100 BaseSize(3)-50 BaseSize(4)-125]);
            if obj.GUI==true
                CreateButtons(obj,obj.Figure);
            end
            
            for j=1:Carousel.RealCombCount
                [FTable,Idx]=GetCombinations(Carousel,j);
                Idx=sort(Idx)';
                
                
                
                obj.Count=0;
                FigNum=FigNum+1;
                obj.Result(j).Tab=uitab(obj.TabGroup,...
                    'Title',['Plot ' char(num2str(j))]);
                TBSZ=obj.Result(j).Tab.Position;
                obj.Axes=uiaxes(obj.Result(j).Tab,...
                    'Position',[TBSZ(1), TBSZ(2)+10, TBSZ(3)-20, TBSZ(4)-80]);
                
                hold(obj.Axes,'on');

                SetSyle(obj,numel(Idx));
                obj.Result(j).FigHan=obj.Figure;
                han=[];
                for i=Idx
                    obj.Count=obj.Count+1;
                    
                    Name=obj.Data.Name(i);
                    DataCopy=struct;
                    
                    DataCopy.IDMeas=obj.Data.IDMeas(i);
                    DataCopy.IDSpec=obj.Data.IDSpec(i);
                    DataCopy.Name=obj.Data.Name(i);
                    
                    DataCopy.Data(1).Type=Copy(obj.Data.Zedo(i));
                    DataCopy.Data(2).Type=Copy(obj.Data.Press(i));
                    DataCopy.Data(3).Type=Copy(obj.Data.MainTable(i));
                    
                    obj.CopyD=DataCopy;
                    GetTension(DataCopy.Data(2).Type,DataCopy.Data(3).Type);
                    
                    %________________________________
                    h=AnFun(obj,DataCopy);
                    han=[han, h];
                    %________________________________
                end

                legend(obj.Axes,han,'location','northwest');
                SetAxes(obj,obj.Axes);
                obj.Result(j).Axes=obj.Axes;
                type=char(AnFun);
                obj.Result(j).SaveFilename=[obj.GraphFolder type '_' obj.Interpreter '_' char(num2str(j)) '_MFZ_Cumulative'];
                
            end
        end
        
        function han=PlotBasic(obj,DataCopy)
            Z=DataCopy.Data(1).Type.Data.Records(1).ConDetector;
            M=GetParams(DataCopy.Data(3).Type);
            P=GetParams(DataCopy.Data(2).Type);
            
            Z=Z(Z.NHitDet==1 & Z{:,6}<P.EndTime,:);
            Z = sortrows(Z,Z.Properties.VariableNames(6));
            %---------------------------------
            EqDeff=interp1(P.Time,P.Deff,Z{:,6});

            yyaxis(obj.Axes, 'left');
            CHits=cumsum(Z{:,19});
            %CHits=Z{:,19};
            
            x1=EqDeff;
            y1=CHits;
            
            plot(obj.Axes,x1,y1,'Marker','none','HandleVisibility','on',...
                        'LineStyle',obj.Lines{obj.Count},'LineWidth',obj.Thick(obj.Count));
%             plot(obj.Axes(1),EqDeff,CHits,'HandleVisibility','off',...
%                 'Marker','.','LineWidth',obj.Thick(obj.Count),'LineStyle',...
%                 'none','Color',obj.Colors(obj.Count,:),'MarkerSize',2);
            xlabel(obj.Axes,'Deflection \it \delta \rm [mm]');
            ylabel(obj.Axes,'Cumulative hits [-]');

            if obj.Axes.YLim(2)<max(CHits)*1.02
                ylim(obj.Axes,[0 max(CHits)*1.02]);
            end

            yyaxis(obj.Axes, 'right');
            if ismissing(M.Cycles)
                C='';
            else
                C=char(num2str(M.Cycles));
            end
            
            Name=[char(M.Mixture) ' - ' char(M.Enviroment) C ' - ' char(num2str(M.Age)) ' - ' char(num2str(M.IDNum))];
            clear x2 y2;
            x2=P.Deff;
            intx2=linspace(min(x2)*1.01,max(x2)*0.99,20);
            
            y2=P.Strength;
            %[x2, index] = unique(x2); 
            %yint2=interp1(x2,y2(index),intx2);
            han=plot(obj.Axes,x2,y2,'DisplayName',Name,...
                'LineWidth',obj.Thick(obj.Count),'Marker',obj.Marker{obj.Count},'LineStyle',obj.Lines{obj.Count},'MarkerSize',10);
            
            ylabel(obj.Axes,'Bending strength \it f_{m} \rm [N/mm^{2}]');
            %yyaxis(obj.Axes, 'left');
            %set(gcf,'Position',[20 20 650 450]);
        end
        

        function han=PlotEvents(obj,DataCopy)
            Z=DataCopy.Data(1).Type;
            M=GetParams(DataCopy.Data(3).Type);
            P=GetParams(DataCopy.Data(2).Type);
            
            GetXDeltas(Z,M.Length,M.Velocity,1);
            if Z.HasEvents==true
                box(obj.Axes,'on');
                grid(obj.Axes,'on');
                senX=[50,50+M.Length];
                senY=[0,0];
                %senZ=[0,0];

                %Z=Z(Z{:,2}=="65.1A" & Z.NHitDet==1 & Z{:,6}<P.EndTime,:);
                E=Z.Data.Events;
                E=E(E{:,9}<P.EndTime,:);


                ZedoTime=E{:,7};

                ZStrength=zeros([size(E,1),1]);
                ZStrength(:,1)= interp1(P.Time,P.Strength,ZedoTime);

                ZDefformation=zeros([size(E,1),1]);
                ZDefformation(:,1)=interp1(P.Time,P.Deff,ZedoTime);

                Name=[char(M.Mixture) ' - ' char(M.Enviroment) char(num2str(M.Cycles)) ' - ' char(num2str(M.Age))];
                %Energy=log((Z{:,11}*10^13).^2);

                Energy=E{:,13};
                han=scatter3(obj.Axes,E.XDelta+50,ZStrength,Energy,E{:,13},'DisplayName',Name,...
                    'Marker',obj.VertMarker{obj.Count+1,1});

                han.MarkerFaceColor=han.MarkerEdgeColor;



                senZ=obj.Axes.ZLim;
                zlim(obj.Axes,senZ);

            %                 scatter3(senX(1),senY(1),senZ(1),'Marker','d','MarkerFaceColor','k','MarkerEdgeColor','k','DisplayName','Sensor A');
            %                 scatter3(senX(2),senY(2),senZ(1),'Marker','^','MarkerFaceColor','k','MarkerEdgeColor','k','DisplayName','Sensor B');
            %                 plot3([senX(1) senX(1)],[senY(1) senY(1)],senZ,'-k','HandleVisibility','off');
            %                 plot3([senX(2) senX(2)],[senY(2) senY(2)],senZ,'-k','HandleVisibility','off');
            %                 
            %                 
                %sf = fit([x, y],z,'poly33');
                %plot(sf,[x,y],z);
                %legend;
                xlabel(obj.Axes,'Delta x [mm]');
                ylabel(obj.Axes,'Tensile strength \it f_{ct} \rm [MPa]');
                zlabel(obj.Axes,'Hit energy \it E_{AE} \rm [V\cdotHz^{-2}]');
                xlim(obj.Axes,[60 320]);
                obj.Axes.View=obj.View;
                %lgd=legend('location','northwest');
                %lgd.NumColumns =2;
                obj.Axes.ZAxis.Scale='log';
                SetAxes(obj,obj.Axes);
                %set(gcf,'Position',[200 200 1100 600]);
            else
                obj.Count=obj.Count-1;
                han=[];
            end

        end
        
        function han=PlotEvents2(obj,DataCopy)
            Z=DataCopy.Data(1).Type;
            M=GetParams(DataCopy.Data(3).Type);
            P=GetParams(DataCopy.Data(2).Type);
            
            GetXDeltas(Z,M.Length,M.Velocity,1);
            if Z.HasEvents==true
                box(obj.Axes,'on');
                grid(obj.Axes,'on');
                senX=[50,50+M.Length];
                senY=[0,0];
                %senZ=[0,0];

                %Z=Z(Z{:,2}=="65.1A" & Z.NHitDet==1 & Z{:,6}<P.EndTime,:);
                E=Z.Data.Events;
                E=E(E{:,9}<P.EndTime,:);


                ZedoTime=E{:,7};

                ZStrength=zeros([size(E,1),1]);
                ZStrength(:,1)= interp1(P.Time,P.Strength,ZedoTime);

                ZDefformation=zeros([size(E,1),1]);
                ZDefformation(:,1)=interp1(P.Time,P.Deff,ZedoTime);

                Name=[char(M.Mixture) ' - ' char(M.Enviroment) char(num2str(M.Cycles)) ' - ' char(num2str(M.Age))];

                Energy=E{:,13};
                x=E.XDelta+50;
                y=ZStrength;
                z=Energy;
                
                s=log(E{:,11}*10e+15).^2;
                
                c=E{:,13}*10;
                
                han=scatter3(obj.Axes,x,y,z,s,'filled','DisplayName',Name,...
                    'Marker',obj.VertMarker{obj.Count+2,1},'MarkerEdgeColor','k',...
                    'MarkerFaceColor',[obj.Colors(obj.Count,:)]);

                %set(obj.Axes, 'Projection','perspective');
                
                obj.Axes.View=obj.View;
                senZ=obj.Axes.ZLim;
                zlim(obj.Axes,senZ);
                
                for i=1:numel(x) 
                    if s(i)>max(s)*0.20
                        plot3(obj.Axes,[x(i) x(i)],[y(i) y(i)],[0 z(i)],...
                            'HandleVisibility','on','Color',[0.7,0.7,0.7],...
                            'LineStyle','-');
                    end
                end
                
                %legend(obj.Axes);
                xlabel(obj.Axes,'Delta x [mm]');
                ylabel(obj.Axes,'Tensile strength \it f_{ct} \rm [MPa]');
                zlabel(obj.Axes,'Hit energy \it E_{AE} \rm [V\cdotHz^{-2}]');
                xlim(obj.Axes,[140 240]);
                
                %lgd.NumColumns =2;
                %obj.Axes.ZAxis.Scale='log';
                SetAxes(obj,obj.Axes);
                obj.FigSize=obj.Axes.Parent.Position;
            else
                obj.Count=obj.Count-1;
                han=[];
            end

        end
        function han=PlotVelocity(obj,DataCopy)
            M=GetParams(DataCopy.Data(3).Type);
            Fig=obj.Figure;
            CurrAxes=Fig.CurrentAxes;
            
            y=M.Velocity;
            x=M.Cycles;
            err=std(M.Length./M{:,3:6}.*1000);
            
            
            if numel(CurrAxes.Children)>0
                x=[CurrAxes.Children.XData, x]';
                y=[CurrAxes.Children.YData, y]';
                err=[CurrAxes.Children.YNegativeDelta, err]';
                cla(obj.Axes(1));
            end
            Name=[char(M.Mixture) ' - ' char(M.Enviroment) ' - ' char(num2str(M.Age))];
            han=errorbar(obj.Axes(1),x,y,err,'-o','DisplayName',Name);

           xlabel(obj.Axes(1),'Number of cycles');
           ylabel(obj.Axes(1),'Velocity of elastic wave \it v_{UZ} \rm [m\cdots^{-1}]');

            legend;
        end
        
        function han=PlotShearTensile(obj,DataCopy)
            Z=DataCopy.Data(1).Type.Data.Records(1).ConDetector;
            M=GetParams(DataCopy.Data(3).Type);
            P=GetParams(DataCopy.Data(2).Type);
            %GetXDeltas(Z,M.Length,M.Velocity,1);
            
            han=[];
            if size(Z,1)>0


                Z=Z(Z.Energy_V_2_Hz_>5e-10,:);
                Dur=Z.Duration_ns_;
                HCount=Z.HCount_N_;
                AvgFreq=Dur./HCount;

                RiseTime=Z.Risetime_ns_;
                MaxAmplitude=Z.Max_Amplitude_V_;

                RAVal=(RiseTime*1e-8)./MaxAmplitude;

                %colormap(jet(100));

                Size=abs(Z{:,13}.*10e+4);

                %Name=[char(M.Mixture) ' - ' char(M.Enviroment) ' - ' char(num2str(M.Age)) ' - ' char(num2str(M.IDNum))];
                Name=[char(M.Mixture) ' - ' char(M.Enviroment) char(num2str(M.Cycles)) ' - ' char(num2str(M.Age))];

                han=scatter(obj.Axes,RAVal,AvgFreq,Size,'filled','DisplayName',Name,...
                    'MarkerEdgeColor','k');
                if obj.Count<2
                    Alpha=63;
                    YMax=70000;%obj.Axes(1).YLim(2);
                    XMax=12;%obj.Axes(1).XLim(2);
                    [XCoor,YCoor]=OperLib.Hypotenuse(XMax,YMax,Alpha);

                    XLine=linspace(0,XCoor,1000);
                    YLine=linspace(0,YCoor,1000);
                    B=0;

                    plot(obj.Axes,XLine,YLine+B,'-k','HandleVisibility','on');
                    %xlim(obj.Axes,[0 XCoor*1.05]);
                    red=[0.70 0.80];
                    STR={'\leftarrow Tensile crack','Shear crack \rightarrow'};
                    text(obj.Axes,XCoor*red(1),YCoor*red(2),STR{1},'HorizontalAlignment','right','FontSize',12,...
                        'FontName','Palatino linotype','FontWeight','bold');
                    
                    text(obj.Axes,XCoor*red(2),YCoor*red(2),STR{2},'HorizontalAlignment','left',...
                        'FontSize',12,...
                        'FontName','Palatino linotype','FontWeight','bold');
                    obj.Axes.XAxis.Scale='log';
                end

                xlabel(obj.Axes,'RA values [ms/V]');
                ylabel(obj.Axes,'Average frequency [Hz]');
            else
                obj.Count=obj.Count-1;
                han=[];
            end
        end
        
        function han=PlotSelective(obj,DataCopy)
            
            Z=DataCopy.Data(1).Type.Data.Records(1).ConDetector;
            M=GetParams(DataCopy.Data(3).Type);
            P=GetParams(DataCopy.Data(2).Type);
            
            Z=Z(Z.NHitDet==1 & Z{:,6}<P.EndTime,:);
            Z = sortrows(Z,Z.Properties.VariableNames(6));
            %---------------------------------
            EqDeff=interp1(P.Time,P.Deff,Z{:,6});

            yyaxis(obj.Axes, 'left');
            CHits=cumsum(Z{:,19});
            
            x1=EqDeff;
            y1=CHits;
            
            plot(obj.Axes,x1,y1,'Marker','none','HandleVisibility','off',...
                        'LineStyle',obj.Lines{obj.Count},'LineWidth',obj.Thick(obj.Count));

            xlabel(obj.Axes,'Deformation \it \Deltah \rm [mm]');
            ylabel(obj.Axes,'Cumulative hits [-]');

            if obj.Axes(1).YLim(2)<max(CHits)*1.02
                ylim(obj.Axes,[0 max(CHits)*1.02]);
            end

            yyaxis(obj.Axes, 'right');
            if ismissing(M.Cycles)
                C='';
            else
                C=char(num2str(M.Cycles));
            end
            
            Name=[char(M.Mixture) ' - ' char(M.Enviroment) C ' - ' char(num2str(M.Age)) ' - ' char(num2str(M.IDNum))];
            clear x2 y2;
            x2=P.Deff;
            intx2=linspace(min(x2)*1.01,max(x2)*0.99,30);
            
            y2=P.Strength;
            [x2, index] = unique(x2); 
            yint2=interp1(x2,y2(index),intx2);
            han=plot(obj.Axes,intx2,yint2,'DisplayName',Name,...
                'LineWidth',obj.Thick(obj.Count),'Marker',obj.Marker{obj.Count},'LineStyle',obj.Lines{obj.Count},'MarkerSize',10,...
                'ButtonDownFcn',@(src,event) ShowTitle(obj,event),...
                'UserData',{DataCopy.IDMeas,DataCopy.IDSpec,true});
            
            ylabel(obj.Axes,'Bending strength \it f_{m} \rm [N/mm^{2}]');
            title(obj.Axes,'');
        end
    end

    %GUI plots
    methods
        function ShowTitle(obj,event)
            line=event.Source;
            
            obj.CurrentGOID=event.Source.UserData{1};
            
            if ~isempty(obj.CurrLine)
                if obj.CurrLine.UserData{3}==1
                    obj.CurrLine.Color=[0.8500,    0.3250,   0.0980];  
                else
                    obj.CurrLine.Color=[0.8,0.8,0.8];  
                end
            end
            obj.CurrLine=line;
            gcf=obj.CurrLine.Parent;
            
            if obj.CurrLine.UserData{3}==1
                obj.CurrLine.Color='k';
                title(gcf,['Selected specimen '''':' line.DisplayName ''' State: ON']);
            else
                obj.CurrLine.Color=[0.5,0.5,0.5];
                title(gcf,['Selected specimen '''':' line.DisplayName ''' State: OFF']);
            end
        end
        
        function CreateButtons(obj,Parent)
            uibutton(Parent,'Position',[20, 60, 100, 25],...
                'Text','Mark/UnMark',...
                'ButtonPushedFcn', @(src,event) SignSpecimen(obj,event));
        end
        
        function SignSpecimen(obj,event)
            IDMeas=obj.CurrLine.UserData{1};
            IDSpec=obj.CurrLine.UserData{2};
            Name=obj.CurrLine.DisplayName;
            
            SignSpecimen(obj.Project,IDMeas,IDSpec);
            value=obj.CurrLine.UserData{3};
            obj.CurrLine.UserData{3}=~value;
            if obj.CurrLine.UserData{3}==1
                obj.CurrLine.Color=[0.8500,    0.3250,   0.0980];
            else
                obj.CurrLine.Color=[0.8,0.8,0.8];
            end
        end
        
        function IniciateControls(obj)
            obj.Panel=obj.Parent.Panel;
            data=table
            obj.UITable = uitable(obj.Panel,'Data',t);
        end
    end
end

