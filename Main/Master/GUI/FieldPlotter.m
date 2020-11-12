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
    end
    
    properties %plot styles, colors, lines, markers
        Figure;
        Count;
        Lines;
        Thick;
        Marker;
        Colors;
        Axes;
        D3Plot logical;
        Y2Axis logical;
    end
    
    methods
        function obj = FieldPlotter(Data,GraphFolder)
            obj.Data=Data;
            obj.GraphFolder=GraphFolder;
            
            obj.PlotTypes={'basic','events','velocity'};
        end
        function Plot(obj,Type,Interpreter)
            obj.Interpreter=Interpreter;
            obj.Type=lower(Type);
            switch lower(Type)
                case 'basic'
                    obj.Y2Axis=1;
                    GeneralPlot(obj,@PlotBasic2);
                case 'events'
                    obj.Y2Axis=0;
                    GeneralPlot(obj,@PlotEvents2);
                    %PlotEvents(obj);
                case 'velocity'
                    obj.Y2Axis=0;
                    GeneralPlot(obj,@PlotVelocity2);
                case 'tensile_shear'
                    obj.Y2Axis=0;
                    PlotShearTensile(obj);
            end
            SaveFigures(obj);
        end
        function SaveFigures(obj)
            GetLimits(obj);
            %SaveFiles(obj);
        end
        function GetLimits(obj)
            x=[];
            y=[];
            z=[];
            n=0;
            for i=1:size(obj.Result,2)
                for a=1:size(obj.Result(i).Axes,2)
                    n=n+1;
                    x(n,:,a)=obj.Result(i).Axes(a).XLim;
                    y(n,:,a)=obj.Result(i).Axes(a).YLim;
                    z(n,:,a)=obj.Result(i).Axes(a).ZLim;
                end
            end
            

            for i=1:size(obj.Result,2)
                for a=1:size(obj.Result(i).Axes)
                    obj.Result(i).Axes(a).XLim=[min(x(:,1,a)) max(x(:,2,a))];
                    obj.Result(i).Axes(a).YLim=[min(y(:,1,a)) max(y(:,2,a))];
                    obj.Result(i).Axes(a).ZLim=[min(z(:,1,a)) max(z(:,2,a))];
                end
            end
        end
        function SaveFiles(obj)
            for i=1:size(obj.Result,2)
                saveas(obj.Result(i).FigHan,obj.Result(i).SaveFilename);
            end
        end
    end
    
    methods %settings for plots, fonts, sizes, colros etc.
        function SetAxes(obj,ax)
            set(ax,'FontName','Palatino linotype','FontSize',12,'LineWidth',1.2);
        end
        
        function SetSyle(obj,Num)
            obj.Lines={'-','--',':','-.',...
                        '-','--',':','-.',...
                        '-','--',':','-.'};
            obj.Colors=colormap (parula(Num));
            obj.Thick=[1, 1, 1, 1, ...
                        2, 2, 2, 2,...
                        3, 3, 3, 3];
            obj.Marker={'o','o','o','o',...
                        'd','d','d','d',...
                        '+','+','+','+'};
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
            
            [FT,NewIdx]=sortrows(FT,[9,13,10]);
            obj.Data=obj.Data(NewIdx,:);
            
            Carousel=DataCarusel(FT,9);
            
            
            
            for j=1:Carousel.RealCombCount
                [FTable,Idx]=GetCombinations(Carousel,j);
                Idx=sort(Idx)';
                
                SetSyle(obj,numel(Idx));
                
                obj.Count=0;
                FigNum=FigNum+1;
                
                obj.Figure=figure(j);
                obj.Result(j).FigHan=obj.Figure;
                
                for i=Idx
                    obj.Count=obj.Count+1;
                    

                    ax(1)=gca;
                    hold(ax(1),'on');

                    if obj.Y2Axis==true
                        yyaxis right;
                        ax(2)=gca;
                        hold(ax(2),'on');
                    end

                    Name=obj.Data.Name(i);
                    DataCopy=struct;
                    DataCopy(1).Type=Copy(obj.Data.Zedo(i));
                    DataCopy(2).Type=Copy(obj.Data.Press(i));
                    DataCopy(3).Type=Copy(obj.Data.MainTable(i));
                    
                    GetTension(DataCopy(2).Type,DataCopy(3).Type);
                    obj.Axes=ax;
                    %________________________________
                    AnFun(obj,DataCopy);
                    %________________________________
                end
                legend('location','northwest');
                SetAxes(obj,ax);
                %set(gcf,'Position',[20 20 820 450]);
                
                obj.Result(j).Axes=ax;
                obj.Result(j).SaveFilename=[obj.GraphFolder obj.Interpreter '_' char(num2str(j)) '_MFZ_Cumulative.png'];
            end
        end
        
        function PlotBasic2(obj,DataBag)
            Z=DataBag(1).Type.Data.Records(1).ConDetector;
            M=GetParams(DataBag(3).Type);
            P=GetParams(DataBag(2).Type);
            
            Z=Z(Z.NHitDet==1 & Z{:,6}<P.EndTime,:);
            Z = sortrows(Z,Z.Properties.VariableNames(6));
            %---------------------------------
            EqDeff=interp1(P.Time,P.Deff,Z{:,6});

            yyaxis left;
            CHits=cumsum(Z{:,19});
            %CHits=Z{:,19};
                    plot(obj.Axes(1),EqDeff,CHits,'HandleVisibility','off',...
                        'LineStyle',obj.Lines{obj.Count},'LineWidth',obj.Thick(obj.Count),'Marker','none');
%             plot(obj.Axes(1),EqDeff,CHits,'HandleVisibility','off',...
%                 'Marker','.','LineWidth',obj.Thick(obj.Count),'LineStyle',...
%                 'none','Color',obj.Colors(obj.Count,:),'MarkerSize',2);
            xlabel(obj.Axes(1),'Deformation \it \Deltah \rm [mm]');
            ylabel(obj.Axes(1),'Cumulative hits [-]');

            if obj.Axes(1).YLim(2)<max(CHits)*1.02
                ylim(obj.Axes(1),[0 max(CHits)*1.02]);
            end

            yyaxis right;
            if ismissing(M.Cycles)
                C='';
            else
                C=char(num2str(M.Cycles));
            end
            Name=[char(M.Mixture) ' - ' char(M.Enviroment) C ' - ' char(num2str(M.Age))];
            plot(obj.Axes(2),P.Deff,P.Strength,'DisplayName',Name,...
                'LineWidth',obj.Thick(obj.Count),'Marker','none');
            ylabel(obj.Axes(2),'Bending strength \it f_{m} \rm [N/mm^{2}]');
            set(gcf,'Position',[20 20 650 450]);
        end
        
        
        function PlotEvents2(obj,DataBag)
            Z=DataBag(1).Type;
            M=GetParams(DataBag(3).Type);
            P=GetParams(DataBag(2).Type);
            
            GetXDeltas(Z,M.Length,M.Velocity,1);
            if Z.HasEvents==true
                box(obj.Axes(1),'on');
                grid(obj.Axes(1),'on');
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
                b=scatter3(E.XDelta+50,ZStrength,Energy,E{:,13},'DisplayName',Name);

                b.MarkerFaceColor=b.MarkerEdgeColor;



                senZ=obj.Axes(1).ZLim;
                zlim(obj.Axes(1),senZ);

            %                 scatter3(senX(1),senY(1),senZ(1),'Marker','d','MarkerFaceColor','k','MarkerEdgeColor','k','DisplayName','Sensor A');
            %                 scatter3(senX(2),senY(2),senZ(1),'Marker','^','MarkerFaceColor','k','MarkerEdgeColor','k','DisplayName','Sensor B');
            %                 plot3([senX(1) senX(1)],[senY(1) senY(1)],senZ,'-k','HandleVisibility','off');
            %                 plot3([senX(2) senX(2)],[senY(2) senY(2)],senZ,'-k','HandleVisibility','off');
            %                 
            %                 
                %sf = fit([x, y],z,'poly33');
                %plot(sf,[x,y],z);
                legend;
                xlabel(obj.Axes(1),'Delta x [mm]');
                ylabel(obj.Axes(1),'Tensile strength \it f_{ct} \rm [MPa]');
                zlabel(obj.Axes(1),'Hit energy \it E_{AE} \rm [V\cdotHz^{-2}]');
                xlim(obj.Axes(1),[60 320]);
                view(-21,37);
                lgd=legend('location','northwest');
                lgd.NumColumns =2;
                obj.Axes(1).ZAxis.Scale='log';
                SetAxes(obj,obj.Axes(1));
                set(gcf,'Position',[200 200 1100 600]);
            else
                obj.Count=obj.Count-1;
            end

        end
        
        function PlotVelocity2(obj,DataBag)
            M=GetParams(DataBag(3).Type);
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
            errorbar(obj.Axes(1),x,y,err,'-o','DisplayName',Name);

           xlabel(obj.Axes(1),'Number of cycles');
           ylabel(obj.Axes(1),'Velocity of elastic wave \it v_{UZ} \rm [m\cdots^{-1}]');

            legend;
        end
        
        function PlotShearTensile(obj)
            FigNum=0;
            FT=GetFilter(obj);
            Carousel=DataCarusel(FT,[9]);
            
            for j=1:Carousel.RealCombCount
                FigNum=FigNum+1;
                obj.Result(FigNum).FigHan=figure(j);
                [FTable,Idx]=GetCombinations(Carousel,j);
                
                ax(1)=gca;
                hold(ax(1),'on');
                box(ax(1),'on');
                grid(ax(1),'on');
                
                for k=1:numel(Idx)
                    i=Idx(k);
                    Name=obj.Data.Name(i);
                    Zo=obj.Data.Zedo(i);
                    Po=obj.Data.Press(i);
                    Mo=obj.Data.MainTable(i);

                    %Z=GetParams(Zo,Name);
                    P=GetParams(Po,Name);
                    M=GetParams(Mo,Name);
                    Z=Zo.Data.Records(1).ConDetector;
                    Z=Z(Z.Energy_V_2_Hz_>2e-10,:);
                    clear AvgFreq;
                    
                    Dur=Z.Duration_ns_;
                    HCount=Z.HCount_N_;
                    AvgFreq=Dur./HCount;

                    RiseTime=Z.Risetime_ns_;
                    MaxAmplitude=Z.Max_Amplitude_V_;

                    RAVal=(RiseTime*1e-8)./MaxAmplitude;

                    colormap(jet(100));
                    Size=abs(Z{:,6}.*1e+12);
                    Name=[char(M.Mixture) ' - ' char(M.Enviroment) ' - ' char(num2str(M.Age)) ' - ' char(num2str(M.IDNum))];
                    scatter(RAVal,AvgFreq,10,'filled','DisplayName',Name);
                    col=colorbar;
                    col.Label.String='AE Classes [-]';
                end
                
                legend;
                Alpha=63;


                YMax=ax(1).YLim(2);
                XMax=ax(1).XLim(2);

                [XCoor,YCoor]=OperLib.Hypotenuse(XMax,YMax,Alpha);

                XLine=[0 XCoor];
                YLine=[0 YCoor];
                B=0;

                plot(XLine,YLine+B,'-k','HandleVisibility','off');

                xlabel('RA values [ms/V]');
                ylabel('Average frequency [Hz]');

                red=[0.75 0.8];
                STR={'\leftarrow Tensile crack','Shear crack \rightarrow'};
                text(XCoor*red(1),YCoor*red(2),STR{1},'HorizontalAlignment','right','Rotation',Alpha-90,'FontSize',10);
                text(XCoor*red(2),YCoor*red(1),STR{2},'Rotation',Alpha-90,'FontSize',10);
                SetAxes(obj,ax);
                set(gcf,'Position',[20 20 650 450]);
                obj.Result(FigNum).Axes=ax;
                obj.Result(FigNum).SaveFilename=[obj.GraphFolder obj.Interpreter '_' char(num2str(j)) '_MFZ_ShearTensile.png'];
            end      
        end
    end
end

