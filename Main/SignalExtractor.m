classdef SignalExtractor < handle
    %vytvoøení objektu pro extrakci vlastostí z akustického signálu
    %použitelný rpo rùzné frekvenèní oblasti
    
    properties (SetAccess = public) 
        Signal {mustBeNumeric};
        SampFreq {mustBeNumeric};
        SampleCount {mustBeNumeric};
        features;
        Frequency {mustBeNumeric};
        FAmplitude {mustBeNumeric};
        Period;
        Time; 
        SignalPeaks;
        FreqPeaks;
        Feature;
    end
    
    properties (SetAccess = private) 
        FPeaks;
        SPeaks;
        CutIndex;
        Anotate;
        FLimits; 
        FLimitsBool=false;
    end
    
    methods (Access = public)
        %------------------------------------------------------------------
        %set the inputs
        %------------------------------------------------------------------
        function feat=GetEmptyFeature(obj)
            DomAmp=NaN;
            DomFreq=NaN;
            DomWidth=NaN;
            DomProm=NaN;
            Energy=NaN;
            Duration=NaN;
            SignalAtt=NaN;
            FFTAtt=NaN;
            obj.Feature=table(DomAmp, DomFreq, DomWidth, DomProm, Energy, Duration,SignalAtt,FFTAtt);
        end
        
        %------------------------------------------------------------------
        %Rozhodovací iniciace extraktoru
        %------------------------------------------------------------------
        function obj = SignalExtractor(varargin)
            if numel(varargin)
                obj.Anotate=false;
                while numel(varargin)>0
                    switch lower(varargin{1})
                        case 'signal'
                            obj.Signal=varargin{2};
                            obj.SampleCount=numel(obj.Signal);
                        case 'fs'
                            obj.SampFreq=varargin{2};
                        case 'flimits'
                            obj.FLimits=varargin{2};
                            obj.FLimitsBool=true;
                        otherwise
                    end
                    varargin([1:2])=[];
                end
                %SigExtract(obj,obj.Signal,obj.SampFreq);                
            else
            end
            %set all variables and count rest of variables  
        end
        %------------------------------------------------------------------
        %Execute extraction
        %------------------------------------------------------------------
        function SigExtract(obj,signal,sampfreq)
            warning('off','all');
            %set the variables
            obj.Signal=signal;
            obj.SampFreq=sampfreq;
            obj.SampleCount=length(signal);
            
            %count the time and period of signal
            obj.Period=1/obj.SampFreq;
            time=0:obj.Period:(obj.SampleCount-1)*obj.Period;
            obj.Time=time';
            
            %Analyzie signal
            AnalyzeSignal(obj,false);
            
            %count the FFT
            if numel(obj.Signal)>0
                [obj.Frequency,obj.FAmplitude]=CountFFT(obj);
                obj.FreqPeaks=ExtractPeaks(obj,false);
            else
                GetEmptyFeature(obj);
            end
            warning('on','all');
            
            %Construct feature
            ConstructFeature(obj);
        end
        %------------------------------------------------------------------
        %Plot both signal and fft with anotation
        %------------------------------------------------------------------
        function [han,ax]=PlotFeatures(obj,varargin)
            %signal
            han=figure;
            ax(1)=subplot(2,1,1);
            hold on;
            ln=AnalyzeSignal(obj,true);
            
            xlabel('Time \it t \rm [s]');
            ylabel('Amplitude \it A \rm [V]');
            
            xlim([obj.Time(1) obj.Time(end)]);
            
            ax(1).XAxis.Exponent = -3;
            
            %fft
            ax(2)=subplot(2,1,2);
            hold on;
            [peaks]=ExtractPeaks(obj,true);
            %axis([min(obj.FreqPeaks.FLocs)*0.5 max(obj.FreqPeaks.FLocs)*1.5 0 max(obj.FreqPeaks.FPeaks)*1.1]);
            text(peaks.FLocs+200,peaks.FPeaks,string(round(peaks.FLocs,0)));
            xlabel('Frequency \it f \rm [Hz]');
            ylabel('Amplitude \it A \rm [V]');
            lgd=legend('location','southoutside');
            lgd.NumColumns =4;
            ax(2).XAxis.Exponent = 3;
            %cyklus pro zpracování pøíkazù v varargin
            while ~isempty(varargin)
                switch lower(varargin{1})
                    case 'freqlim'
                        xlim(ax(2),varargin{2});
                        varargin([1 2])=[];
                    otherwise
                        varargin([1 2])=[];
                end
            end
        end
        
        %------------------------------------------------------------------
        %Extract main part of signal
        %------------------------------------------------------------------
        function ConstructFeature(obj)
            [DomAmp,fI]=max(obj.FreqPeaks.FPeaks);
            DomFreq=obj.FreqPeaks.FLocs(fI);
            DomWidth=obj.FreqPeaks.FWidth(fI);
            DomProm=obj.FreqPeaks.FProminence(fI);
            Energy=obj.SignalPeaks.SEnergy;
            Duration=obj.SignalPeaks.SDuration;
            SignalAtt=obj.SignalPeaks.AttDir;
            FFTAtt=DomProm/DomWidth;
            
            if numel(DomAmp)>0
            obj.Feature=table(DomAmp, DomFreq, DomWidth, DomProm, Energy,Duration, SignalAtt,FFTAtt,....
                'VariableNames',{'DomAmp','DomFreq','DomWidth','DomProm','Energy','Duration','SignalAtt','FFTAtt'});
            else
                GetEmptyFeature(obj)
            end
        end
    end %end of private methods
    
    methods (Access = private)
        
        %------------------------------------------------------------------
        %Count fft
        %------------------------------------------------------------------
        function [f,y]=CountFFT(obj)
            Signal=obj.Signal;
            Fs = obj.SampFreq;                % Sampling frequency
            T = 1/Fs;                  % Sampling period

            L=length(Signal);
            t = (0:L-1)*T;  
            Y = fft(Signal);

            P2 = abs(Y/L(1));
            P1 = P2(1:L/2+1);
            P1(2:end-1) = 2*P1(2:end-1);

            L2=length(P1);

            f=zeros(L2,1);

            f(:,1)=Fs*(0:(L/2))/L;
            y=P1;
            
            obj.Frequency=f;
            obj.FAmplitude=y;
        end
        %------------------------------------------------------------------
        %Find peaks in FFT
        %------------------------------------------------------------------
        function [peaks]=ExtractPeaks(obj,anotate)
            
            %[x,y]=CountFFT(obj);
            x=obj.Frequency;
            y=obj.FAmplitude;
            if numel(x)>0 && numel(y)>0
                maxY=max(y);

                minProm=max(y)*0.1;
                minFreqDistance=x(end)/2*0.01;

                [pks,locs,w,p]=findpeaks(y,x,'MinPeakProminence',minProm,'Annotate',...
                'extents','MinPeakDistance',minFreqDistance,'NPeaks',10,...
                'MinPeakHeight',maxY*0.03);
            
                if obj.FLimitsBool==true
                    idx=locs>obj.FLimits(1) & locs<obj.FLimits(2);
                    peaks=struct('FPeaks',pks(idx),'FLocs',locs(idx),...
                        'FWidth',w(idx),'FProminence',p(idx));
                else
                    peaks=struct('FPeaks',pks,'FLocs',locs,'FWidth',w,'FProminence',p);
                end

                if obj.Anotate==true
                    findpeaks(y,x,'MinPeakProminence',minProm,'Annotate',...
                    'extents','MinPeakDistance',minFreqDistance,'NPeaks',10,...
                    'MinPeakHeight',maxY*0.3);
                    lgd=legend;
                    lgd.EdgeColor='none';
                end
                obj.FPeaks=peaks;
            else
                peaks=struct('FPeaks',[],'FLocs',[],'FWidth',[],'FProminence',[]);
                obj.FPeaks=peaks;
                GetEmptyFeature(obj)
            end
        end

        %------------------------------------------------------------------
        %Analyze signal
        %------------------------------------------------------------------
        function [ln]=AnalyzeSignal(obj,anotate)
            X=obj.Time;
            Y=obj.Signal;
            
            [idxLeft,idxRight]=SignalTrsh(obj);
            obj.CutIndex=[idxLeft,idxRight];
            
            meanY=mean([Y(idxLeft) Y(idxRight)])*0.5;
            dur=X(idxRight)-X(idxLeft);
            
            CutTime=X(idxLeft:1:idxRight);
            CutSignal=Y(idxLeft:1:idxRight);

            AbsCutSignal=CutSignal;
            AbsCutSignal(AbsCutSignal<meanY)=meanY;
            
            energie=trapz(CutTime,AbsCutSignal);
            [pks,locs]=findpeaks(AbsCutSignal,CutTime,...
            'MinPeakHeight',meanY);
            p = polyfit(locs,pks,1); 
            f = polyval(p,locs); 
            
            attDir=(f(end)-f(1))/(p(end)-p(1));
            
            if anotate==true
                %ln(2)=plot(CutTime,AbsCutSignal,':');
                %plot(lk,pk,'.k');
                ln(1)=plot(X,Y,'DisplayName','Original Signal');
                H=area(CutTime,AbsCutSignal,'BaseValue',meanY,'ShowBaseLine','off','DisplayName','Area above the threshold value');
                H.EdgeColor=H.FaceColor;


                ln(2)=plot(locs,f,'k--','DisplayName','Directive of signal attenuation');
                lgd=legend;
                STR=sprintf('Duration of signal: %0.0f ms \nAttenuation directive: %0.4f Vs^{-1} \nTreshold value: %0.2E V',dur*1000,attDir,meanY);
                dim=lgd.Position;
                ln(3)=annotation('textbox',[dim(1) dim(2)-0.15 .1 .1],'String',STR,'EdgeColor','none');
            end
            
            signalF=struct('SEnergy',energie,'SDuration',dur,'AttDir',attDir);
            obj.SignalPeaks=signalF;
        end

        %------------------------------------------------------------------
        %Start and end of signal
        %------------------------------------------------------------------
        function [StartID,EndID]=SignalTrsh(obj)
            signal=obj.Signal;
            signalMax=max(signal);
            samples=length(signal);

            maxId=find(signal==signalMax,1);

            partsig{1}=flip(signal(1:maxId));
            partsig{2}=signal(maxId:end);

            noiseMean=mean(signal);
            noiseStd=std(signal);

            trsh=noiseMean+noiseStd*.9;

            %plot(partsig{1});
            %plot(partsig{2});

            for n=[1 2]
                [up,lo]=envelope(partsig{n},9600,'rms');
                partsig{n}(partsig{n}<0)=0;
                Id2=find(up<trsh,1,'first');
                if ~isempty(Id2)
                    IdMirr(n)=Id2;
                else
                    IdMirr(n)=length(partsig{n});
                end
            end
            StartID=maxId-IdMirr(1)+1;
            EndID=maxId+IdMirr(2)-1;
        end
    end %end of private funcitons
end %end of class