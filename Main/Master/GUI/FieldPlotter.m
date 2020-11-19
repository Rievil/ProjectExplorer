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
        CurrLine;
        GUI;
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
        
        function PutData(obj,Data)
            obj.Data=Data;
            obj.IsTotalTable=1;
        end
        
        function Data=GetData(obj)
            Data=obj.CopyD;
        end
        function Plot(obj,Type,Interpreter)
            obj.Interpreter=Interpreter;
            obj.Type=lower(Type);
            obj.Result
            switch lower(Type)
                case 'basic'
                    obj.Y2Axis=1;
                    GeneralPlot(obj,@PlotBasic);
                case 'events'
                    obj.Y2Axis=0;
                    GeneralPlot(obj,@PlotEvents);
                    %PlotEvents(obj);
                case 'velocity'
                    obj.Y2Axis=0;
                    GeneralPlot(obj,@PlotVelocity);
                case 'tensile_shear'
                    obj.Y2Axis=0;
                    PlotShearTensile(obj);
                case 'selective'
                    obj.GUI=true;
                    obj.Y2Axis=1;
                    GeneralPlot(obj,@PlotSelective);
                    obj.GUI=false;
                case 'events2'
                    obj.Y2Axis=0;
                    GeneralPlot(obj,@PlotEvents2);
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
                for a=1
                    n=n+1;
                    x(n,:,a)=obj.Result(i).Axes(a).XLim;
                    y(n,:,a)=obj.Result(i).Axes(a).YLim;
                    z(n,:,a)=obj.Result(i).Axes(a).ZLim;
                    if obj.Y2Axis==1
                        tmp=obj.Result(i).Axes.YLim;
                        y2(n,:,2)=obj.Result(i).Axes.YAxis(1).Limits;  
                    end
                end
            end
            

            for i=1:size(obj.Result,2)
                
                for a=1
                    obj.Result(i).Axes(a).XLim=[min(x(:,1,a)) max(x(:,2,a))];
                    obj.Result(i).Axes(a).YLim=[min(y(:,1,a)) max(y(:,2,a))];
                    obj.Result(i).Axes(a).ZLim=[min(z(:,1,a)) max(z(:,2,a))];
                    if obj.Y2Axis==1
                        obj.Result(i).Axes.YAxis(1).Limits=[min(y2(:,1,2)) max(y2(:,2,2))];
                    end
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
            Count=round(Num/4,0)+1;
            LT={'-','--','-.',':'};
            obj.Figure.Colormap=parula(Num);
            obj.Colors=obj.Figure.Colormap;
            marker={'none','none','none','none';...
                'o','o','o','o';...
                'd','d','d','d';...
                '+','+','+','+';...
                '^','^','^','^';...
                'h','h','h','h';...
                '*','*','*','*';...
                's','s','s','s';...
                '|','|','|','|';...
                'p','p','p','p'};
            
            for i=1:Count
                obj.Lines=[obj.Lines, LT];
                obj.Thick=[obj.Thick, linspace(1+(i-1)*0.5,1+(i-1)*0.5,4)];
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
            
            [FT,NewIdx]=sortrows(FT,[9,10,13]);
            obj.Data=obj.Data(NewIdx,:);
            
            Carousel=DataCarusel(FT,[9,11]);
            
            
            
            for j=1:Carousel.RealCombCount
                [FTable,Idx]=GetCombinations(Carousel,j);
                Idx=sort(Idx)';
                
                
                
                obj.Count=0;
                FigNum=FigNum+1;
                
                obj.Figure=uifigure(j);
                obj.Axes=uiaxes(obj.Figure);
                hold(obj.Axes,'on');
                if obj.GUI==true
                    CreateButtons(obj,obj.Figure);
                end
                SetSyle(obj,numel(Idx));
                obj.Result(j).FigHan=obj.Figure;
                
                for i=Idx
                    obj.Count=obj.Count+1;
                    
                    Name=obj.Data.Name(i);
                    DataCopy=struct;
                    DataCopy(1).Type=Copy(obj.Data.Zedo(i));
                    DataCopy(2).Type=Copy(obj.Data.Press(i));
                    DataCopy(3).Type=Copy(obj.Data.MainTable(i));
                    obj.CopyD=DataCopy;
                    GetTension(DataCopy(2).Type,DataCopy(3).Type);
                    
                    %________________________________
                    AnFun(obj,DataCopy);
                    %________________________________
                end

                legend('location','northwest');
                SetAxes(obj,obj.Axes);
                obj.Result(j).Axes=obj.Axes;
                obj.Result(j).SaveFilename=[obj.GraphFolder obj.Interpreter '_' char(num2str(j)) '_MFZ_Cumulative.png'];
            end
        end
        
        function PlotBasic(obj,DataBag)
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
            
            x1=EqDeff;
            y1=CHits;
            
            plot(obj.Axes(1),x1,y1,'Marker','none','HandleVisibility','off',...
                        'LineStyle',obj.Lines{obj.Count},'LineWidth',obj.Thick(obj.Count));
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
            
            Name=[char(M.Mixture) ' - ' char(M.Enviroment) C ' - ' char(num2str(M.Age)) ' - ' char(num2str(M.IDNum))];
            clear x2 y2;
            x2=P.Deff;
            intx2=linspace(min(x2)*1.01,max(x2)*0.99,20);
            
            y2=P.Strength;
            %[x2, index] = unique(x2); 
            %yint2=interp1(x2,y2(index),intx2);
            pl=plot(obj.Axes(2),x2,y2,'DisplayName',Name,...
                'LineWidth',obj.Thick(obj.Count),'Marker',obj.Marker{obj.Count},'LineStyle',obj.Lines{obj.Count},'MarkerSize',10);
            
            ylabel(obj.Axes(2),'Bending strength \it f_{m} \rm [N/mm^{2}]');
            set(gcf,'Position',[20 20 650 450]);
        end
        

        function PlotEvents(obj,DataBag)
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
                b=scatter3(E.XDelta+50,ZStrength,Energy,E{:,13},E{:,13}*10,'DisplayName',Name);

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
                x=E.XDelta+50;
                y=ZStrength;
                z=Energy;
                s=E{:,13};
                c=E{:,13}*10;
                
                
                
                                
                b=scatter3(x,y,z,s,'DisplayName',Name,'MarkerFaceColor','r','MarkerEdgeColor','w');
                %b.MarkerFaceColor=b.MarkerEdgeColor;
                


                set(gca, 'Projection','perspective');
                view(-21,37);
                senZ=obj.Axes(1).ZLim;
                zlim(obj.Axes(1),senZ);
                
                for i=1:numel(x)
                    if z(i)>max(z)*0.7
                        plot3([x(i) x(i)],[y(i) y(i)],[senZ(1) z(i)],'HandleVisibility','off','Color','r',...
                            'LineStyle','-');
                    end
                end
                
                legend;
                xlabel(obj.Axes(1),'Delta x [mm]');
                ylabel(obj.Axes(1),'Tensile strength \it f_{ct} \rm [MPa]');
                zlabel(obj.Axes(1),'Hit energy \it E_{AE} \rm [V\cdotHz^{-2}]');
                xlim(obj.Axes(1),[60 320]);
                
                lgd=legend('location','northwest');
                lgd.NumColumns =2;
                obj.Axes(1).ZAxis.Scale='log';
                SetAxes(obj,obj.Axes(1));
                set(gcf,'Position',[200 200 1100 600]);
            else
                obj.Count=obj.Count-1;
            end

        end
        function PlotVelocity(obj,DataBag)
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
                    Z=Z(Z.Energy_V_2_Hz_>5e-10,:);
                    clear AvgFreq;
                    
                    Dur=Z.Duration_ns_;
                    HCount=Z.HCount_N_;
                    AvgFreq=Dur./HCount;

                    RiseTime=Z.Risetime_ns_;
                    MaxAmplitude=Z.Max_Amplitude_V_;

                    RAVal=(RiseTime*1e-8)./MaxAmplitude;

                    colormap(jet(100));
                    Size=abs(Z{:,13}.*10e+4);
                    Name=[char(M.Mixture) ' - ' char(M.Enviroment) ' - ' char(num2str(M.Age)) ' - ' char(num2str(M.IDNum))];
                    scatter(RAVal,AvgFreq,Size,'filled','DisplayName',Name);
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
        
        function PlotSelective(obj,DataBag)
            
            Z=DataBag(1).Type.Data.Records(1).ConDetector;
            M=GetParams(DataBag(3).Type);
            P=GetParams(DataBag(2).Type);
            
            Z=Z(Z.NHitDet==1 & Z{:,6}<P.EndTime,:);
            Z = sortrows(Z,Z.Properties.VariableNames(6));
            %---------------------------------
            EqDeff=interp1(P.Time,P.Deff,Z{:,6});

            yyaxis(obj.Axes, 'left');
            CHits=cumsum(Z{:,19});
            %CHits=Z{:,19};
            
            x1=EqDeff;
            y1=CHits;
            
            plot(obj.Axes,x1,y1,'Marker','none','HandleVisibility','off',...
                        'LineStyle',obj.Lines{obj.Count},'LineWidth',obj.Thick(obj.Count));
%             plot(obj.Axes(1),EqDeff,CHits,'HandleVisibility','off',...
%                 'Marker','.','LineWidth',obj.Thick(obj.Count),'LineStyle',...
%                 'none','Color',obj.Colors(obj.Count,:),'MarkerSize',2);
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
            intx2=linspace(min(x2)*1.01,max(x2)*0.99,100);
            
            y2=P.Strength;
            [x2, index] = unique(x2); 
            yint2=interp1(x2,y2(index),intx2);
            pl=plot(obj.Axes,intx2,yint2,'DisplayName',Name,...
                'LineWidth',obj.Thick(obj.Count),'Marker',obj.Marker{obj.Count},'LineStyle',obj.Lines{obj.Count},'MarkerSize',10,...
                'ButtonDownFcn',@obj.ShowTitle,'UserData',{Name,obj.Axes,obj,true});
            
            ylabel(obj.Axes,'Bending strength \it f_{m} \rm [N/mm^{2}]');
            set(gcf,'Position',[20 20 650 450]);
        end
    end
    
    %Callbacks
    methods (Static)
        function ShowTitle(obj,event)
            obj=event.Source.UserData{3};
            if ~isempty(obj.CurrLine)
                obj.CurrLine.Color=obj.Color;  
            end
            gcf=event.Source.UserData{2};
            title(gcf,['Selected specimen '''':' event.Source.UserData{1} '''']);
            obj.CurrLine=event.Source;
            obj.CurrLine.Color='k';
        end
    end
    
    %GUI plots
    methods
        function CreateButtons(obj,fig)
            uibutton(fig,'Position',[20, 60, 100, 25],...
                'Text','Mark/UnMark');
%            uibutton(fig,'Position',[20, 60, 100, 25],...
%                 'Text','Mark/UnMark',...
%                'ButtonPushedFcn', @(btn,event) plotButtonPushed(btn,ax));
        end
    end
    methods %gui
        function IniciateControls(obj)
            obj.Panel=obj.Parent.Panel;
            data=table
            obj.UITable = uitable(obj.Panel,'Data',t);
        end
    end
end

