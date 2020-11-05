classdef FieldPlotter < handle
    %FIELDPLOTTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Data;
        GraphFolder char;
        Interpreter char;
        Result struct;
        PlotTypes;
    end
    
    methods
        function obj = FieldPlotter(Data,GraphFolder)
            obj.Data=Data;
            obj.GraphFolder=GraphFolder;
            
            obj.PlotTypes={'basic','events','velocity'};
        end
        
        function Plot(obj,Type,Interpreter)
            obj.Interpreter=Interpreter;
            switch lower(Type)
                case 'basic'
                    PlotBasic(obj);
                case 'events'
                    PlotEvents(obj);
                case 'velocity'
                    PlotVelocity(obj);
                case 'tensile_shear'
                    PlotShearTensile(obj);
            end
            SaveFigures(obj);
        end
        
        
        
        function SaveFigures(obj)
            GetLimits(obj);
            SaveFiles(obj);
        end
        
        function [x,y,z]=GetLimits(obj)
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
            set(ax,'FontName','Arial','FontSize',12,'LineWidth',1.2);
        end
    end
    methods %Plotting methods
        function FT=GetFilter(obj)
            FT=table;
            for i=1:size(obj.Data,1)
                FT=[FT; obj.Data.MainTable(i).Data];
            end
        end
        
        function PlotBasic(obj)
            
            FigNum=0;
            FT=GetFilter(obj);
            Carousel=DataCarusel(FT,[9 10 12]);
            
            for j=1:Carousel.RealCombCount
                
                FigNum=FigNum+1;
                obj.Result(FigNum).FigHan=figure(j);
                
                [FTable,Idx]=GetCombinations(Carousel,j);
                yyaxis right;
                ax(2)=gca;

                yyaxis left;
                ax(1)=gca;

                hold(ax(1),'on');
                hold(ax(2),'on');
                for k=1:numel(Idx)
                    i=Idx(k);
                    Name=obj.Data.Name(i);
                    Zo=obj.Data.Zedo(i);
                    Po=obj.Data.Press(i);
                    Mo=obj.Data.MainTable(i);

                    Z=GetParams(Zo,Name);
                    P=GetParams(Po,Name);
                    M=GetParams(Mo,Name);


                    GetXDeltas(Zo,M.Length,M.Velocity,1);


                    %Z=Z(Z{:,2}=="65.1A" & Z.NHitDet==1 & Z{:,6}<P.EndTime,:);
                    Z=Z(Z.NHitDet==1 & Z{:,6}<P.EndTime,:);
                    Z = sortrows(Z,Z.Properties.VariableNames(6));
                    %---------------------------------


                    yyaxis left;
                    CHits=cumsum(Z{:,19});
                    plot(ax(1),Z{:,6},CHits,'HandleVisibility','off');
                    xlabel(ax(1),'Time \it T \rm [s]');
                    ylabel(ax(1),'Cumulative hits [-]');

                    if ax(1).YLim(2)<max(CHits)*1.02
                        ylim(ax(1),[0 max(CHits)*1.02]);
                    end
                    
                    yyaxis right;
                    Name=[char(M.Mixture) ' - ' char(M.Enviroment) ' - ' char(num2str(M.Age))];
                    plot(ax(2),P.Time,P.Force,'DisplayName',Name);
                    ylabel(ax(2),'Force \it F \rm [N]');
                    if ax(2).YLim(2)<max(P.Force)*1.02
                        ylim(ax(2),[0 max(P.Force)*1.02]);
                    end

                end
                legend('location','northwest');
                SetAxes(obj,ax);
                set(gcf,'Position',[20 20 820 450]);
                %saveas(j,[obj.GraphFolder obj.Interpreter '_' char(num2str(j)) '_MFZ_Cumulative.png']);
                obj.Result(FigNum).Axes=ax;
                obj.Result(FigNum).SaveFilename=[obj.GraphFolder obj.Interpreter '_' char(num2str(j)) '_MFZ_Cumulative.png'];
            end
        end
        
        function PlotEvents(obj)
            
            FigNum=0;
            FT=GetFilter(obj);
            Carousel=DataCarusel(FT,[9 10 11]);
            
            for j=1:Carousel.RealCombCount
                
                FigNum=FigNum+1;
                obj.Result(FigNum).FigHan=figure(j);
                
                [FTable,Idx]=GetCombinations(Carousel,j);
                ax(1)=gca;
                hold(ax(1),'on');
                box(ax(1),'on');
                grid(ax(1),'on');
                x=[];
                y=[];
                z=[];
                s=[];
                
                
                for k=1:numel(Idx)
                    i=Idx(k);
                    Name=obj.Data.Name(i);
                    Zo=obj.Data.Zedo(i);
                    Po=obj.Data.Press(i);
                    Mo=obj.Data.MainTable(i);

                    %Z=GetParams(Zo,Name);
                    P=GetParams(Po,Name);
                    M=GetParams(Mo,Name);


                    GetXDeltas(Zo,M.Length,M.Velocity,1);
                    senX=[50,50+M.Length];
                    senY=[0,0];
                    %senZ=[0,0];

                    %Z=Z(Z{:,2}=="65.1A" & Z.NHitDet==1 & Z{:,6}<P.EndTime,:);
                    Z=Zo.Data.Events;
                    Z=Z(Z{:,9}<P.EndTime,:);
                    Fint=zeros([size(Z,1),1]);
                    for i=1:size(Z,1)
                        Fint(i,1)= interp1(P.Time,P.Force,Z{i,9});
                    end
                    Name=[char(M.Mixture) ' - ' char(M.Enviroment) ' - ' char(num2str(M.Age)) ' - ' char(num2str(M.IDNum))];
                    %Energy=log((Z{:,11}*10^13).^2);
                    Energy=Z{:,11};
                    b=scatter3(Z.XDelta+50,Fint,Energy,Z{:,13},'DisplayName',Name);
                    b.MarkerFaceColor=b.MarkerEdgeColor;
                    
                    
                    %Z = sortrows(Z,Z.Properties.VariableNames(6));
                    %---------------------------------
                    

                end
                
                senZ=ax(1).ZLim;
                zlim(ax(1),senZ);
                scatter3(senX(1),senY(1),senZ(1),'Marker','d','MarkerFaceColor','k','MarkerEdgeColor','k','DisplayName','Sensor A');
                scatter3(senX(2),senY(2),senZ(1),'Marker','^','MarkerFaceColor','k','MarkerEdgeColor','k','DisplayName','Sensor B');
                plot3([senX(1) senX(1)],[senY(1) senY(1)],senZ,'-k','HandleVisibility','off');
                plot3([senX(2) senX(2)],[senY(2) senY(2)],senZ,'-k','HandleVisibility','off');
                
                
                %sf = fit([x, y],z,'poly33');
                %plot(sf,[x,y],z);
                legend;
                xlabel(ax(1),'Delta x [mm]');
                ylabel(ax(1),'Force \it F \rm [N]');
                zlabel(ax(1),'Hit energy \it E_{AE} \rm [V\cdotHz^{-2}]');
                xlim(ax(1),[0 380]);
                view(-21,37);
                lgd=legend('location','northwest');
                lgd.NumColumns =2;
                ax(1).ZAxis.Scale='log';
                SetAxes(obj,ax);
                set(gcf,'Position',[20 20 1100 600]);
                
                obj.Result(FigNum).Axes=ax;
                obj.Result(FigNum).SaveFilename=[obj.GraphFolder obj.Interpreter '_' char(num2str(j)) '_MFZ_Events.png'];
                %SaveFilename=[obj.GraphFolder obj.Interpreter '_' char(num2str(j)) '_MFZ_Events.png'];
                %saveas(j,[obj.GraphFolder obj.Interpreter '_' char(num2str(j)) '_MFZ_Events.png']);
            end
        end
        function PlotVelocity(obj)
            
            FT=GetFilter(obj);
            Carousel=DataCarusel(FT,[9 10]);
            
            for j=1:Carousel.RealCombCount
                figure(j);
                
                [FTable,Idx]=GetCombinations(Carousel,j);
                [s,isort]=sort(FTable.IDNum);
                
                Idx=Idx(isort);
                
                ax(1)=gca;
                hold(ax(1),'on');
                %box(ax(1),'on');
                %grid(ax(1),'on');

                xall=[];
                yall=[];
                eall=[];
                for k=1:numel(Idx)
                    i=Idx(k);
                    Name=obj.Data.Name(i);

                    Mo=obj.Data.MainTable(i);
                    M=GetParams(Mo,Name);


                    Name=[char(M.Mixture) ' - ' char(M.Enviroment) ' - ' char(num2str(M.Age))];
                    
                    y=M.Length./M{:,3:6}.*1000;
                    x=linspace(M.IDNum,M.IDNum,numel(y));
                    

                    xall=[xall;x'];
                    yall=[yall;y'];
                    %eall=[eall;dev];
                    
                    %Z = sortrows(Z,Z.Properties.VariableNames(6));
                    %---------------------------------
                    

                end
                [xall,I]=sort(xall);
                yall=yall(I);
                %eall=eall(I);
                sf=fit(xall,yall,'poly4');
                ypol=sf(xall);
                plot(xall,yall,'.','DisplayName','Data');
                plot(xall,ypol,'-','DisplayName',Name);
                %errorbar(xall,yall,eall,'DisplayName',Name);

                p21 = predint(sf,xall,0.60,'observation','on');
                plot(xall,p21,'k--','DisplayName','Prediction intervals'), 
                
                legend;
                xlabel(ax(1),'IDNum x [-]');
                ylabel(ax(1),'Velocity \it V_{uz} \rm [m\cdots^{-1}]');
                set(ax,'FontName','Arial','FontSize',12,'LineWidth',1.2)
                set(gcf,'Position',[20 20 650 400]);
                saveas(j,[obj.GraphFolder obj.Interpreter '_' char(num2str(j)) '_M_Velocity.png']);
            end
        end
        
        function PlotShearTensile(obj)
            FigNum=0;
            FT=GetFilter(obj);
            Carousel=DataCarusel(FT,[9 10]);
            
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

