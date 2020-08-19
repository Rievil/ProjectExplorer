classdef AEClassifier < AE
    %Public var
    properties (SetAccess = public)
        Measuremnts;  %Main project structure
        Options; %Default settings
        ClassData;  %Classification variables
        MeaPrefixFolder; %má smysl pøi nahrání dat z jiné sesny
        BruteFolder;
        BasicFolder;
        CL char; %zástupce pro command line
    end
    
%------------------------------------------------------------------
%Jednotlivé metody
%------------------------------------------------------------------

    methods (Access = public) %práce s daty a základní uživatelské funkce
        %vytvoøení objektu a vybrání mìøené složky
        function obj = AEClassifier(OpenType) 
            if nargin==0
                OpenType=1;
            end
                
            switch OpenType
                case 1
                    obj.Options=SetOption(obj,1);
                case 2
                    %we can approach all data and do first sweep for
                    %measruemnets
                    obj.Options=SetOption(obj,2);
            end
        end
        %------------------------------------------------------------------
        %První data sweep v brute folderu
        %------------------------------------------------------------------
        function DataSweep(obj)
            switch obj.Options.OpenType
                case 1
                    [BruteFolder]=GetBruteFolder(obj);
                    if BruteFolder~="none"
                        %BruteFolder=uigetdir(cd,'Vyber slozku s mìøenými vzorky');
                        obj.BruteFolder=[BruteFolder '\'];
                        %GetBasicTest(obj,obj.BruteFolder);
                        obj.Measuremnts=GetBasicTest(obj,obj.BruteFolder);                 
                        obj.Measuremnts.Count=length(obj.Measuremnts);                
                    else
                        InfoMessage(obj,'Info: The path was not set');                    
                    end
                case 2
                    obj.Measuremnts=GetBasicTest(obj,obj.BruteFolder);
            end
        end
        %------------------------------------------------------------------
        %Ukládání struktury - pro manuální ovládání
        %------------------------------------------------------------------
        function SaveWork(obj)
            obj.BasicFolder = strrep(which('AEClassifier'),'AEClassifier.m','');
            Work=obj;
            save ([obj.BasicFolder 'Work.mat'],'Work');
        end
        %------------------------------------------------------------------
        %Ukládání struktury . pro manuální ovládání
        %------------------------------------------------------------------
        function [LObj]=LoadWork(obj)
            obj.BasicFolder = strrep(which('AEClassifier'),'AEClassifier.m','');
            SavedWork=load([obj.BasicFolder 'Work.mat'],'Work');
            [LObj]=SavedWork.Work;
        end
        %------------------------------------------------------------------
        %Nastav promìnné v nastavení objektu
        %------------------------------------------------------------------
        function [T]=SetOption(~,OpenType)
            T=struct;
            T.AnalyzeAllHits=false;
            T.NumberOfInspectionPoints=10;
            T.Overlap=3;
            T.XLabel={'Time'};
            T.YLabel={'Force'};
            T.ZLabel={'Deformation'};
            T.HitDetector=0;
            T.Signals=true;
            T.Samples=1;
            
            switch OpenType
                case 1 % manual ussage of AEClassifier
                    T.OpenType=1;
                    T.OpenTypeLabel='Manual ussage of AEClassifier';
                case 2 % UsageByProjectExplorer
                    T.OpenType=2;
                    T.OpenTypeLabel='Project explorer usage of AEClassifier';
                otherwise 
                    T.OpenType=1;
            end
            
        end
        
        %------------------------------------------------------------------
        %Zmìna adresáøe pøi nahrání uloených dat
        %------------------------------------------------------------------
        function NewMeaPath(obj)
            %D:\ZEDO_DATA_Export\200318_Melichar
            [BruteFolder]=GetBruteFolder(obj);
            obj.BruteFolder=[BruteFolder '\'];
        end %konec set a get methods
        
        %------------------------------------------------------------------
        %Vyber oblasti grafu, které mají být prozkoumány
        %------------------------------------------------------------------
        function PrepareAnalysis(obj,varargin)
            %pokud je v option AnalyzeAllHits='false' pak dej možnost
            %vybrat konkrétní místa na grafech
            %dle prikazu provedu zadane
            %zjistim jake je nastaveni v parametrech a poté provedu konkrétní úkon
            
            %pøeètu pøíkaz a vytvoøím poøadí pro spuštìní nahrání dat
            while length(varargin)>0
                Parameter=lower(varargin{1});
                switch Parameter
                    case 'samples'
                        logSample=true;
                        logFullTime=false;
                        %obj.Options.SamplesToProcess=Parameter;                      
                        if (isnumeric(varargin{2}))
                            obj.Options.Samples=varargin{2};            
                        else
                            if (lower(varargin{2})=='all')                                
                                obj.Options.Samples=1:obj.Measuremnts.Count;
                            end
                        end
                        varargin(1:2)=[];
                    case 'fulltime'
                        %pokud chci celý èas, pak nemùžu zároveò dìlat
                        %jednotlivì
                        logFullTime=true;
                        logSample=false;
                        varargin(1)=[];
                    case 'overlap'
                        if (isnumeric(varargin{2}))
                            obj.Options.Overlap=varargin{2};                            
                        end
                        varargin(1:2)=[];
                    case 'pointsofinterest'
                        if (isnumeric(varargin{2}))
                            obj.Options.NumberOfInspectionPoints=varargin{2};
                        end
                        varargin(1:2)=[];
                    case 'signals'
                        if (string2boolean(varargin{2})==true)
                            obj.Options.Signals=true;
                        else
                            obj.Options.Signals=false;
                        end
                        varargin(1:2)=[];
                    case 'hitdetector'
                        if (isnumeric(varargin{2}))
                            obj.Options.HitDetector=varargin{2};
                        end
                        varargin(1:2)=[];
                    otherwise
                end
%                 if length(varargin)>1
%                     varargin(1:2)=[];
%                 else
%                     varargin(1:end)=[];
%                 end
            end
            
            %mohu spustit výbìr
            if (logFullTime==true && logSample==true)
                %chyba, mžu mít pouze jeden
                error(['Error occured: cant both analyse selective and in full time of AE measuremnet!';
                    'Use parameter "samples",[1 2 5] | "all" or "fulltime"']);
            else
                if (logFullTime==true)
                    PrepareFullTime(obj);
                else
                    if (logSample==true)
                        PrepareSelectiveSamples(obj);
                    end
                end
            end
            
        end
        
        %------------------------------------------------------------------
        %VyberFeaturyUJednohoSamplu
        %------------------------------------------------------------------
        function ExtractFeatures(obj)
            f = waitbar(0,'Please wait...','Name','Feature extraction');
            E=SignalExtractor;
            samples=obj.Options.Samples;

            try
            
                nSampleLoop=0;
            for sample=[samples]
                nSampleLoop=nSampleLoop+1;
                waitbar(nSampleLoop/length(samples),f,['Processing ' num2str(nSampleLoop) '/' num2str(length(samples)) ' samples']);
                IDSelection=obj.Measuremnts(sample).IDSelection;
                TMain=[];
                DetectorKey=[];
                    for i=1:size(IDSelection,1) %listování mezi kartami
                        for HD=1:length(obj.Options.HitDetector)%listování mezi hit detectory
                        
                        if obj.Measuremnts(sample).ZKey.Records(i).Detector(HD).HaveSignals==true
                            TMPHits=struct2table(obj.Measuremnts(sample).ZKey.Records(i).Detector(HD).Signals);
                        end
                        
                        TMPDetector=obj.Measuremnts(sample).ZKey.Records(i).Detector(HD).Data;

                        clear Feature;

                        TMPGroup=[];
                        Group=[];
                        Col=[];
                        TMPIDs=[];
                        TMPCol=[];
                        HitDetector=[];
                        HDTMP=[];
                        %listování mezi vybranými momenty na pracovní køivce
                        %spojím všechny isnpekèní body dohromady a vytáhnu pouze
                        %unikátní id, èímž zamezím opakovené inspekci stejného hitu
                        nSelGroups=size(IDSelection(i).Moment,2);
                        nColors=parula(nSelGroups+1);

                        for j=1:nSelGroups %listování po momentech na krivce
                            ID=IDSelection(i).Moment(j).ID{HD};
                            tCol(1:length(ID),1)=nColors(j,1);
                            tCol(1:length(ID),2)=nColors(j,2);
                            tCol(1:length(ID),3)=nColors(j,3);

                            TMPGroup(1:length(ID),1)=j;
                            Group=[Group; TMPGroup];
                            TMPCol=[TMPCol; tCol];
                            TMPIDs=[TMPIDs; ID];
                        end
                        [IDs,iCol]=unique(TMPIDs);

                        Col=TMPCol(iCol,:);
                        obj.ClassData.TrainData(sample).Colors=Col;
                        obj.ClassData.TrainData(sample).Groups=Group(iCol,:);
                        

                        %

                        
                        F=table;
                        if obj.Options.Signals==true
                            CardHDId=TMPHits.ID;
                            [C,ia,ib]=intersect(CardHDId,IDs);
                            FilesToProcess=TMPHits(ia,:);
                            for n=1:size(FilesToProcess,1)

                                t=[];
                                
                                folder=[obj.BruteFolder char(FilesToProcess.folder(n)) '\'];
                                name=char(FilesToProcess.name(n));
                                [hit]=ReadHit(obj,folder,name);
                                %volání objektu pro extakci featur z akustického
                                %signálu
                                
                                SigExtract(E,hit.Signal,hit.SampleFreq)
                                F=[F; E.Feature];
                            end
                        else
                            %pokud nemám signály, tak abych dodržel poèet
                            %sloupcù u všech featur, ak musím vložit nuly
                            if obj.Options.Signals==true
                                %v tomto pøípadì neoèekávanì nejsou signály
                                %tam kde mìli být, protože u ostatních
                                %mìøení jsem je našel, a mám je hledat, ale
                                %tady nebyli, tím pádem musím vožit do F
                                %prázdné sloupce
                                GetEmptyFeature(E)
                                F=[F; E.Feature];
                            end
                        end
                        
                        [C,ia,ib]=intersect(TMPDetector{:,2},IDs);
                        TMPDetector=TMPDetector(ia,:);
                        
                        Feature=F;
                        ColToConnect=[4 8 9 10 11 12 13 14 15 16 17 18 19 20 22];
                        %zde je prostor pro poèítané sloupce
                        %<---------------------------
                        
                        
                        %TMPTable=TMPDetector{IDs,:};
                        if size(Feature,1)==0
                            Feature=[Feature, TMPDetector(:,ColToConnect)];
                        else
                            Feature=[Feature, TMPDetector(1:size(Feature,1),ColToConnect)];
                        end
                        %
                        
                        DetectorKey=[DetectorKey; HitDetector];
                        TMain=[TMain; Feature];
                    end %procházení pøes hitdetectory
                end %procházení pøes jedn
                
                obj.ClassData.TrainData(sample).Features=TMain;
                obj.ClassData.TrainData(sample).DetectorKey=DetectorKey;
                %DrawExtractedFeatures(obj,sample);

            end %procházení vzorky
                    waitbar(nSampleLoop/length(samples),f,'Feature Extraction complete!');
                    
                    pause(2);
                    close(f);
            
                catch
                    waitbar(0,f,sprintf(['An error occured! \n In specimen: ' obj.Measuremnts(sample).Name '(' num2str(sample) ');' ...
                        ' card = ' num2str(i) '; row = ' num2str(n) '']));
            end
                

        end
        %------------------------------------------------------------------
        %VyberFeaturyUJednohoSamplu
        %------------------------------------------------------------------
        function ShowFeatures(obj)
            f=figure;
            axX=1;
            axY=2;
            axZ=3;
            
            ax(1)=axes('Position',[0.1 0.1 0.88 0.88]);
            ax(2)=axes('Position',[0.18 0.65 0.4 0.3]);
            
            ClassData=obj.ClassData;
            nClassGroups=length(ClassData.TrainData);
            
            nColors=colormap(parula(nClassGroups+1));
            
            for i=obj.Options.Samples
                T=ClassData.TrainData(i).Features;
                Names=T.Properties.VariableNames;
                
                axes(ax(1));
                hold on;
                grid on;
                box on;
                Prime=T.Energy_V_2_Hz_;
                
                maxP=max(Prime);
                minP=min(Prime);
                
                scatter3(T{:,axX},T{:,axY},T{:,axZ},Prime/maxP*120+10,'MarkerEdgeColor',...
                nColors(i,:),'MarkerFaceColor',nColors(i,:),...
                'DisplayName',obj.Measuremnts(i).Name);
            
                lgd(1)=legend;
                view(-49,38);
                
                xlabel(Names{1});
                ylabel(Names{2});
                zlabel(Names{3});
            
                axes(ax(2));
                hold on;
                grid on;
                X=obj.Measuremnts(i).Time;
                Y=obj.Measuremnts(i).Force;
                plot(X,Y,'Color',nColors(i,:),'DisplayName',obj.Measuremnts(i).Name);
                
                xlabel('Time [s]');
                ylabel('Force [N]');
                lgd(2)=legend('location','northeastoutside');
                if nClassGroups>9
                    LgdColMult=round(nClassGroups/10,0);
                    lgd(1).NumColumns=LgdColMult;
                    lgd(2).NumColumns=LgdColMult;
                end
                
                if i==1
                    lgd(1).Title.String='AE Hits';
                    lgd(2).Title.String='Tensile test';
                end
            end
            set(f,'Position',[200 200 900 600 ]);
            
            
            
        end
        %------------------------------------------------------------------
        %Poskládej featury pro všechny posuzované vzorky
        %------------------------------------------------------------------
        function FoldTrainData(obj)
            FeaturesSum=[];
            SampleNames=[];
            for i=obj.Options.Samples
                clear Tmp;
                FeaturesSum=[FeaturesSum; obj.ClassData.TrainData(i).Features];
                Tmp(1:size(obj.ClassData.TrainData(i).Features,1),1)=string(obj.Measuremnts(i).Name);
                SampleNames=[SampleNames; Tmp];
            end
            obj.ClassData.TrainDataSum=FeaturesSum;
            obj.ClassData.SampleNames=SampleNames;
        end
        %------------------------------------------------------------------
        %Vytvoø klassy
        %------------------------------------------------------------------
        function Learn(obj,NetSize)
            FoldTrainData(obj);
            
            obj.ClassData.Guess=[];
            
            x=table2array(obj.ClassData.TrainDataSum)';
            %x = LearningData;

            %size(x);
            
            net = selforgmap(NetSize);
            %view(net);
            net = configure(net,x);
            [net,tr] = train(net,x);
            obj.ClassData.Net=net;
            obj.ClassData.Trained=tr;
            nntraintool
            %nntraintool('close')

            f=figure;
            plotsomhits(net,x);
            
            %nntraintool
            y = net(x);
            Class=string(vec2ind(y))';
            Classes = str2double(Class);
            UnqClasses=unique(Classes);
            SortedClass=sort(UnqClasses);
            UnqClasses=SortedClass;
            %classes are saved as number, string can get confused when
            %finding
            
            ClassT = table(Classes,'VariableNames',{'Classes'});
            
            obj.ClassData.Classes=Classes;
            obj.ClassData.UnqClases=UnqClasses;
            obj.ClassData.nClases=length(obj.ClassData.UnqClases);
            obj.ClassData.ClassLearnerData=[obj.ClassData.TrainDataSum, ClassT];
            
            trainClassifier(obj);
            
            ClassStatistics(obj);
        end
        %------------------------------------------------------------------
        %Natrénuj na cvièných datech fine tree
        %------------------------------------------------------------------
        function trainClassifier(obj)
            % [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
            % returns a trained classifier and its accuracy. This code recreates the
            % classification model trained in Classification Learner app. Use the
            % generated code to automate training the same model with new data, or to
            % learn how to programmatically train models.
            %
            %  Input:
            %      trainingData: a table containing the same predictor and response
            %       columns as imported into the app.
            %
            %  Output:
            %      trainedClassifier: a struct containing the trained classifier. The
            %       struct contains various fields with information about the trained
            %       classifier.
            %
            %      trainedClassifier.predictFcn: a function to make predictions on new
            %       data.
            %
            %      validationAccuracy: a double containing the accuracy in percent. In
            %       the app, the History list displays this overall accuracy score for
            %       each model.
            %
            % Use the code to train the model with new data. To retrain your
            % classifier, call the function from the command line with your original
            % data or new data as the input argument trainingData.
            %
            % For example, to retrain a classifier trained with the original data set
            % T, enter:
            %   [trainedClassifier, validationAccuracy] = trainClassifier(T)
            %
            % To make predictions with the returned 'trainedClassifier' on new data T2,
            % use
            %   yfit = trainedClassifier.predictFcn(T2)
            %
            % T2 must be a table containing at least the same predictor columns as used
            % during training. For details, enter:
            %   trainedClassifier.HowToPredict

            % Auto-generated by MATLAB on 11-May-2020 11:55:44
            % Extract predictors and response
            % This code processes the data into the right shape for training the
            % model.
            trainingData=obj.ClassData.ClassLearnerData;
            inputTable = trainingData;
            predictorNames = inputTable.Properties.VariableNames(1:end-1);
            predictors = inputTable(:, predictorNames);
            response = inputTable.Classes;
            
            isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

            % Train a classifier
            % This code specifies all the classifier options and trains the classifier.
            classificationTree = fitctree(...
                predictors, ...
                response, ...
                'SplitCriterion', 'twoing', ...
                'MaxNumSplits', 118, ...
                'Surrogate', 'off', ...
                'ClassNames', {'1'; '10'; '11'; '12'; '13'; '14'; '15'; '16'; '17'; '18'; '19'; '2'; '20'; '21'; '22'; '23'; '24'; '25'; '3'; '4'; '5'; '6'; '7'; '8'; '9'});

            % Create the result struct with predict function
            predictorExtractionFcn = @(t) t(:, predictorNames);
            treePredictFcn = @(x) predict(classificationTree, x);
            trainedClassifier.predictFcn = @(x) treePredictFcn(predictorExtractionFcn(x));

            % Add additional fields to the result struct
            trainedClassifier.RequiredVariables = predictorNames;%{'ASL_dBAE_', 'DomAmp', 'DomFreq', 'DomProm', 'DomWidth', 'Duration', 'Duration_ns_', 'Energy', 'Energy_V_2_Hz_', 'HCount_N_', 'Max_Amplitude_dBAE_', 'RMS_dBAE_', 'Risetime_ASL_dBAE_', 'Risetime_Energy_V_2_Hz_', 'Risetime_RMS_dBAE_'};
            trainedClassifier.ClassificationTree = classificationTree;
            trainedClassifier.About = 'This struct is a trained model exported from Classification Learner R2019b.';
            trainedClassifier.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

            % Extract predictors and response
            % This code processes the data into the right shape for training the
            % model.
            %inputTable = trainingData;
            %predictorNames = predictorNames;%{'DomFreq', 'DomAmp', 'DomWidth', 'DomProm', 'Energy', 'Duration', 'Duration_ns_', 'Max_Amplitude_dBAE_', 'Energy_V_2_Hz_', 'RMS_dBAE_', 'ASL_dBAE_', 'HCount_N_', 'Risetime_Energy_V_2_Hz_', 'Risetime_RMS_dBAE_', 'Risetime_ASL_dBAE_'};
            %predictors = inputTable(:, predictorNames);
            %response = inputTable.Class;
            isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

            % Perform cross-validation
            partitionedModel = crossval(trainedClassifier.ClassificationTree, 'KFold', 5);

            % Compute validation predictions
            [validationPredictions, validationScores] = kfoldPredict(partitionedModel);

            % Compute validation accuracy
            validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
            obj.ClassData.TrainedClassifier=trainedClassifier;
            obj.ClassData.ValidationAccuracy=validationAccuracy;
        end
        %------------------------------------------------------------------
        %ZpracujNavržené tøídy
        %------------------------------------------------------------------
        function ClassStatistics(obj)
            warning('off','all');
            clear obj.ClassData.Stat;
            ClassData=obj.ClassData.ClassLearnerData;
            VarNames=ClassData.Properties.VariableNames;
            
            ClassNames=obj.ClassData.UnqClases;
            Mean=table;
            Std=table;
            Median=table;
            Mode=table;
            Statistics=struct;
            for i=1:obj.ClassData.nClases
                PartClassData=ClassData(ClassData.Classes==ClassNames(i),:);
                MatDim=size(PartClassData);
                for j=1:MatDim(2)-1
                    arr=table2array(PartClassData(:,j));

                    eval(['Mean.' VarNames{j} '(' num2str(i) ')=' num2str(mean(arr)) ';']);
                    %Std(i,j)=std(arr);
                    eval(['Std.' VarNames{j} '(' num2str(i) ')=' num2str(std(arr)) ';']);
                    %Med(i,j)=median(arr);
                    eval(['Median.' VarNames{j} '(' num2str(i) ')=' num2str(median(arr)) ';']);
                    %Mod(i,j)=mode(arr); 
                    eval(['Mode.' VarNames{j} '(' num2str(i) ')=' num2str(mode(arr)) ';']);
                end
                             
            end
            Statistics.VarNames=VarNames;
            Statistics.Classes=ClassNames;
            Statistics.Mean=Mean;
            Statistics.Std=Std;
            Statistics.Median=Median;
            Statistics.Mode=Mode;
            obj.ClassData.Stat=Statistics;
            warning('on','all');
        end
        %------------------------------------------------------------------
        %Vykresli na jednom vzorku všechny jeho hity a zatøiï je dle
        %navržené klasifikace
        %-----------------------------------------------------
        function [Card]=ClassSample(obj,sample)
            Card=struct;
            for i=1:size(obj.Measuremnts(sample).ZKey.Records,1)
                TMain=table;
                
                TMPHits=obj.Measuremnts(sample).ZKey.Records.Hits{i, 1};
                TMPDetector=obj.Measuremnts(sample).ZKey.Records.Detector{i, 1};
                if i==1
                    TMPDetector(end,:) = [];
                end
                
                F=table;
                for n=1:size(TMPHits,1)
                    [hit]=ReadHit([obj.BruteFolder TMPHits(n).folder '\'],TMPHits(n).name);
                    %volání objektu pro extakci featur z akustického
                    %signálu
                    E=SignalExtractor(hit.Signal,hit.SampleFreq);
                    F=[F; E.Feature];
                end
                
                
                Feature=F;
                ColToConnect=[8 11 12 14 16 17 18 20 22];
                FDim=size(Feature,1);
                DDim=size(TMPDetector,1);
                
                if FDim>DDim
                    Feature=[Feature(1:DDim,:), TMPDetector(:,ColToConnect)];
                else
                    if FDim==DDim
                        Feature=[Feature, TMPDetector(:,ColToConnect)];
                    else
                        Feature=[Feature, TMPDetector(1:FDim,ColToConnect)];
                    end
                end
                %Feature=[Feature, TMPDetector(:,ColToConnect)];
                %
                TMain=[TMain; Feature];
                Card(i).Data=TMain;                
                
                nCol=parula(obj.ClassData.nClases);
                for k=1:size(TMain,1)
                    %mam data pro kazdou kartu jdu zatridovat
                    T2=TMain(k,:);
                    Prediction=obj.ClassData.TrainedClassifier.predictFcn(T2);
                    %Prediction=nCol(str2double(Prediction));
                    TMP=string(Prediction);
                    Card(i).PredictedClass(k)=TMP;
                end
                
            end
            obj.ClassData.Guess(sample).Data=Card;
            
            
            
        end
    end %konec public metod
    
    methods (Access = public) %vykreslení grafù
        function  f=DrawClassifiedHits(obj,sample)
            %sample=1;
            f=figure(sample);
            ax(1)=axes('Position',[0.1 0.32 0.86 0.65]);
            ax(2)=axes('position',[.1 .1 .88 .15]);
            

                
            axes(ax(1));
            nColors=parula(obj.ClassData.nClases);
            lowColor=[0.7 0.7 0.7];
            yyaxis right;
            hold on;
            
            if isempty(obj.ClassData.Guess)
                ClassSample(obj,sample);
            end

            Time=obj.Measuremnts(sample).Time;
            Force=obj.Measuremnts(sample).Force;
            pl(3)=plot(Time,Force,'k-','DisplayName','Tensile test');
            
            xlabel('Time [s]');
            ylabel('Force [N]');

            clear ClassColor;  
            znacka={'d';'v'};
            SumClassCount=[];
            
            for i=1:length(obj.Measuremnts(sample).ZKey.Records.Channel)  
                axes(ax(1));
                yyaxis left;
                hold on;
                title(obj.Measuremnts(sample).Name);

                Hits(i).Name=char(obj.Measuremnts(sample).ZKey.Records.Cards{i,1});
                T=obj.Measuremnts(sample).ZKey.Records.Detector{i, 1};
                %.ZKey.Records.Parameters
                TMPTime=T{:,4};
                Hits(i).Time=TMPTime;
                %hits1=linspace(1,1,length(TMPTime));
                hits1=T{:,17};
                hCum1=cumsum(hits1);
                %hCum2=cumsum(hits2);

                Hits(i).hCumSum=hCum1;
                for n=1:size(Hits(i).Time,1)-1     
                    class=str2double(obj.ClassData.Guess(sample).Data(i).PredictedClass(n));
                    ClassColor(n,i)=(obj.ClassData.nClases+1)-class;
                end
                plot(Hits(i).Time,Hits(i).hCumSum,':','Color',[.2 .2 .2],'HandleVisibility','off');
                X=Hits(i).Time(1:end-1);
                Y=Hits(i).hCumSum(1:end-1);

                scatter(X,Y,ClassColor(:,i)/obj.ClassData.nClases*125,...
                    ClassColor(:,i),'filled','Marker',znacka{i},...
                    'DisplayName',obj.Measuremnts(sample).ZKey.Records.Cards(i));
                
                ax(3)=colorbar;
                ax(3).Label.String='Classes';
                colormap(parula);                
                SumClassCount=[SumClassCount; ClassColor(:,i)];
            end
            legend('location','northwest');
            %set(ax(1),'ColorScale','log');
            ylabel('Hits count');
            ax(1).YAxis(1).Color = [0, 0.4470, 0.7410];
            ax(1).YAxis(2).Color = 'k';
            
            axes(ax(2));
            hold on;
            %SumClassCount=sum(ClassColor,2);
            histogram(SumClassCount);
            %ylim([0 60]);
            xlabel('Classes');
            ylabel('Counts');
            %axes(ax(1));
            %caxis([20 25]);
            set(f,'Position',[80 80 1100 720]);
            set(ax,'FontSize',12);
            
        end
        
        %------------------------------------------------------------------
        %Nech uzivatele vybrat kteoru cas hitù a pracovního diagramu chce
        %vybrat a ke kterému vzorku; platí pouze pro jeden vzorek
        %------------------------------------------------------------------
        function PrepareSelectiveSamples(obj)
            samples=obj.Options.Samples;
            
            f=figure;            
            set(f,'Position',[100 200 900 500],'DefaultLegendAutoUpdate','off');  
            nSampleLoop=0;
            for sample=[samples]
                nSampleLoop=nSampleLoop+1;
                clf(f);
                X=obj.Measuremnts(sample).Time;
                Y=obj.Measuremnts(sample).Force;  

                yyaxis right;
                hold on;
                ax(2)=gca;
                pathTMP=[obj.BruteFolder obj.Measuremnts(sample).Name '\'];
                [ZedoKey]=GetKeyOfMea(obj,pathTMP);
                obj.Measuremnts(sample).ZKey=ZedoKey;

                [Hits]=DrawHitsInSelection(obj,sample,f,'begin');            
                


                yyaxis left;
                hold on;
                ax(1)=gca;
                plot(ax(1),X,Y,'-','LineWidth',1.2,'HandleVisibility','off');

                xlabel(obj.Options.XLabel);
                ylabel(obj.Options.YLabel);

                x=[];
                y=[];

                ax(1).YAxis(1).Color = [0, 0.4470, 0.7410];
                ax(1).YAxis(2).Color = 'k';
                
                annotation('textbox',[.1 .9 .1 .1],'String',['Inspected HitDetector: [' num2str(obj.Options.HitDetector) ']'],...
                    'EdgeColor','none');
                for i=1:1:obj.Options.NumberOfInspectionPoints

                    title(['Vzorek: ' num2str(nSampleLoop) '/' num2str(length(samples)) ' Výbìr bodu: ' num2str(i) '/'...
                           num2str(obj.Options.NumberOfInspectionPoints)]);

                    [xi, yi] = ginput(1);
                    x=[x; xi];
                    y=[y; yi];
                    han(i)=scatter(xi,yi,'r+','HandleVisibility','off');
                end
                                
               title(['Vzorek: ' num2str(sample) '/' num2str(length(samples)) ' Vybrany vsechny inspekèní body (' num2str(i) '/'...
                      num2str(obj.Options.NumberOfInspectionPoints) ')']);


                TMP=obj.Options.Overlap;
                delta=TMP;
                TimeStart=x-delta;
                TimeStop=x+delta;
                TimeStop(TimeStop>max(X))=max(X);
                TimeStart(TimeStart<0)=0;

                HitSel=[TimeStart, TimeStop];
                obj.Measuremnts(sample).TimeHitSelection=HitSel;

                yyaxis right;
                hold on;
                DrawHitsInSelection(obj,sample,f,'final');
                
                yyaxis left;
                hold on;

                for i=1:size(HitSel,1)
                    idx=find(X>=HitSel(i,1) & X<=HitSel(i,2));
                    plot(ax(1),X(idx),Y(idx),'-r','LineWidth',1.4,'HandleVisibility','off');
                end

                scatter(x,y,'dk','Filled','HandleVisibility','off');

                [IDSelection]=GetIDSelection(obj,sample);
                obj.Measuremnts(sample).IDSelection=IDSelection;
                pause(2);
            end
           msgbox('You have succesfuly created selective hits selecetion!');
        end
        %------------------------------------------------------------------
        %Vem celý èas akustické emise limitovanou pomocí èasu z
        %sekundárního pøístroje (lis, úchylkomìr ...)
        %------------------------------------------------------------------
        function PrepareFullTime(obj)
            tic;
            samples=obj.Options.Samples;
            
            f = waitbar(0,'Please wait...','Name','Fulltime selection');
            nSampleLoop=0;
            nSampleLoop=0;
            for sample=[samples]
                nSampleLoop=nSampleLoop+1;
                waitbar(nSampleLoop/length(samples),f,['Processing ' num2str(nSampleLoop) '/' num2str(length(samples)) ' samples']);
                %waitbar(poc/length(samples),f,['Processing ' num2str(nSampleLoop) '/' num2str(length(samples)) ' samples']);
                %nSampleLoop=nSampleLoop+1;
                
                pathTMP=[obj.BruteFolder obj.Measuremnts(sample).Name '\'];
                [ZedoKey]=GetKeyOfMea(obj,pathTMP);
                obj.Measuremnts(sample).ZKey=ZedoKey;
                
                HitSel=[obj.Measuremnts(sample).Time(1), obj.Measuremnts(sample).Time(end)];
                obj.Measuremnts(sample).TimeHitSelection=HitSel;

                [IDSelection]=GetIDSelection(obj,sample);
                obj.Measuremnts(sample).IDSelection=IDSelection;
            end
            waitbar(1,f,sprintf('You have succesfuly created fulltime hits selection!\nSamples: %d Elapsed Time: %.4f s',nSampleLoop,toc));
            pause(2);
            close(f);
            %msgbox(sprintf('You have succesfuly created fulltime hits selecetion!\nElapsed Time: %.4f s',toc));
        end
        %------------------------------------------------------------------
        %Vykresli jednotlivé hity v selektoru hitù
        %------------------------------------------------------------------
        function [Hits]=DrawHitsInSelection(obj,sample,f,type)
            lines={'-','-.','--',':'};
            figure(f);
            
            if ~isempty({obj.Measuremnts(sample).ZKey.Records.Cards})
                Cards={obj.Measuremnts(sample).ZKey.Records.Cards};
            else
                Cards={obj.Measuremnts(sample).ZKey.Records.SampleCards};
            end
            
            for HD=1:length(obj.Options.HitDetector)
                Hits=struct;
                nCards=size(Cards,2);
                for i=1:nCards
                    Hits(i).Name=Cards{i};

                    %TMPS={obj.Measuremnts(sample).ZKey.Records(i).Detector.Data};
                    Tfull=obj.Measuremnts(sample).ZKey.Records(i).ConDetector;

                    %IdHD=find(Tfull{:,3}==HD);
                    T=Tfull(Tfull{:,3}==obj.Options.HitDetector(HD),:);
                    %=T;
                    %T=obj.Measuremnts(sample).ZKey.Records.Detector.Data;
                    %.ZKey.Records.Parameters
                    TMPTime=T{:,4};
                    Hits(i).Time=TMPTime;
                    %hits1=linspace(1,1,length(TMPTime));
                    hits1=T{:,17};
                    %hits2=T{:,12};

                    hCum1=cumsum(hits1);
                    %hCum2=cumsum(hits2);

                    Hits(i).hCumSum=hCum1;
                    colDelta=i/nCards;
                    color=[0.7*colDelta 0.7*colDelta 0.7*colDelta];

                    switch type
                        case 'begin'
                            pl(i*HD)=plot(Hits(i).Time,Hits(i).hCumSum,lines{HD},'Color',color,'DisplayName',['HD: ' num2str(obj.Options.HitDetector(HD)) ' ' Hits(i).Name],...
                            'MarkerFaceColor',color,'Marker','o','MarkerSize',2.5);
                            ylabel('HitsCount');
    
                        case 'final'
                            HitSel=obj.Measuremnts(sample).TimeHitSelection;
                            Time=Hits(i).Time;
                            CumSum=Hits(i).hCumSum;
                            for j=1:size(HitSel,1)
                                Idx=find(Time>=HitSel(j,1) & Time<=HitSel(j,2));
                                plot(Time(Idx),CumSum(Idx),lines{HD},'Color','r','HandleVisibility','off',...
                                'MarkerFaceColor','k','LineWidth',5.5);
                            end
                    end
                end %cards
            end %hitdetector
            
            lgd=legend('Location','northwest');
            lgd.Title.String = 'Record cards';
            lgd.Title.FontSize = 12;   
        end
        
        %------------------------------------------------------------------
        %Udelej vyber ID hitù dle èasových oken
        %------------------------------------------------------------------
        function [IDSelection]=GetIDSelection(obj,sample)
            warning('off','all');
            ZKey=obj.Measuremnts(sample).ZKey;
            TimeArrHitSelection=obj.Measuremnts(sample).TimeHitSelection;
            

                   
           if ~isempty(ZKey.Events)
                %mùžu brát id dle eventu (zde mùže být podmínka pro
                %výbìr dle souøadnic)
                IDSelection=struct();
                for n=1:size(TimeArrHitSelection,1)
                    HD=1;
                    Events=ZKey.Events;
                    namesE=Events.Properties.VariableNames;

                    TMPEvents=Events(Events{:,7}>=TimeArrHitSelection(n,1) & Events{:,7}<=TimeArrHitSelection(n,2),:);
                    %HitsID=cellfun(@(s) split(s,','),TMPEventTable{:,6},'UniformOutput',
                    %false);
                    HitsID=cellfun(@(y) str2double(y),split(TMPEvents{:,6},','));
                    TMPCards=[strrep(TMPEvents{:,4},',',''), TMPEvents{:,5}];
                    Cards=string(cellfun(@(s) char(s),TMPCards,'UniformOutput',false));
                    CHitsID=[];
                    CCards=[];

                    for i=1:size(HitsID,2)
                        CHitsID=[CHitsID; HitsID(:,i)];
                        CCards=[CCards; Cards(:,i)];
                    end

                    
                    for i=1:size(ZKey.Records,2)
                        CardVLook=char(ZKey.Records(i).Cards);
                        %Index=find(HitsVLook.CCards==CardVLook);
                        HitsIDOfCardTMP=CHitsID(CCards==CardVLook);
                        HitsIDOfCard=sort(HitsIDOfCardTMP,'ascend');
                        
                        IDSelection(i).Card=char(ZKey.Records(i).Cards);
                        IDSelection(i).Moment(n).Name=n;
                        IDSelection(i).Moment(n).ID{HD}=[HitsIDOfCard];
                        IDSelection(i).Moment(n).HitDetector{HD}=HD;
                        %IDSelection(i).Moment(n).HitDetector=HDNum;
                    end
                end
           else
               %mùžu brát dle parametrù
               IDSelection=struct();
               
                for iCard=1:length(ZKey.Records)
                    
                    
                    IDSelection(iCard).Card=ZKey.Records(iCard).Cards;
                    
                    for n=1:size(TimeArrHitSelection,1)
                    HitsIDOfCard=[];
                    %HDNum=[];
                        for HD=1:length(obj.Options.HitDetector)
                            Table=ZKey.Records(iCard).Detector(HD).Data;
                            namesT=Table.Properties.VariableNames;
                            HitsID=Table(Table{:,4}>=TimeArrHitSelection(n,1) & Table{:,4}<=TimeArrHitSelection(n,2),:);
                            HitsIDOfCard=[HitsIDOfCard; HitsID{:,2}];
                            
                            %HDNum=[HDNum; obj.Options.HitDetector(HD)];
                            
                            IDSelection(iCard).Moment(n).ID{HD}=HitsID{:,2};
                            IDSelection(iCard).Moment(n).HitDetector{HD}=obj.Options.HitDetector(HD);
                        end
                    HitsIDOfCard=sort(HitsIDOfCard,'ascend');    
                    IDSelection(iCard).Moment(n).Name=n;
                    end
                    
                    
                end
           end           
            warning('on','all');
        end
        
        %------------------------------------------------------------------
        %Vykresli zpracovanou statistiku na vytvoøeném modelu
        %------------------------------------------------------------------
        function [handle]=PlotStatistics(obj,varargin)
            
            while length(varargin)>0
                Parameter=lower(varargin{1});
                switch Parameter
                    case 'all'
                        handle=ClassStatPlot(obj.ClassData,{obj.Measuremnts.Name},'all');
                        varargin(1)=[];
                    case 'sample'
                        if (isnumeric(varargin{2}))
                            handle=ClassStatPlot(obj.ClassData,{obj.Measuremnts.Name},varargin{2});
                            varargin(1:2)=[];
                        end
                        
                    case 'colorbar'
                        
                    otherwise
                end
            end    

        end
    end %konec vykreslení grafù
    
    methods (Access = private) %nahrávání souborù apod.   
        %------------------------------------------------------------------
        %Ziskej sily, casy, deformaci z konkretni slozky mereni
        %------------------------------------------------------------------
        function [BaseTest]=GetBasicTest(obj,pathTMP)
            warning('off','all');
            try
                path=[char(pathTMP) '\'];
                
                all_files = dir(path);
                all_dir = all_files([all_files(:).isdir]);
                all_dir(1:2)=[];
                MeaCount = numel(all_dir);
                BruteFolderNames={all_dir.name};

                files =[dir([path '*.xls']); dir([path '*.xlsx']);  dir([path '*.csv'])];
                fileNameTMP=[files(:).name];
                fileName=lower(string(split(fileNameTMP,'.xls')));

                paterrns={'cas sila','cas stlaceni','pentest'};
                sheetNames={'Test Curve Data','Test Curve Data',''};
                VarNames={'Force','Defformation','Categorical'};

                Tab=struct();
                for i=1:length(paterrns)
                    Index=find(contains(fileName,paterrns{i}));
                    if ~isempty(Index)
                        switch i
                            case 1
                                T1=readtable([files(Index).folder '\' files(Index).name],'Sheet','Test Curve Data');    
                                Tab(i).T=ResamplePressData(obj,T1);
                            case 2
                                T2=readtable([files(Index).folder '\' files(Index).name],'Sheet','Test Curve Data');
                                Tab(i).T=ResamplePressData(obj,T2);
                            case 3
                                Tab(i).T=readtable([files(Index).folder '\' files(Index).name]);
                            otherwise                
                        end
                    end
                end

                BaseTest=struct();
                for i=1:MeaCount
                    try
                        if ~isempty(Tab(3).T)
                            tmpName=char(strrep(string(Tab(3).T{i,1}),' ',''));
                            BaseTest(i).Name=BruteFolderNames{i};

                            lenTMP=double(Tab(3).T{i,2});
                            BaseTest(i).Length=lenTMP;

                            speedTMP=double(strrep(string(Tab(3).T{i,7}),',','.'));
                            BaseTest(i).Speed=speedTMP;
                        end
                    catch
                        InfoMessage(obj,'Error: Didnt find pentest data! Make sure that,pentest.xls file is in mea folder!');                     
                    end
                    if ~isempty(Tab(2).T)
                        timeTMP=Tab(2).T{:,(i-1)*2+1};
                        timeTMP=timeTMP(~isnan(timeTMP));
                        BaseTest(i).Time=timeTMP;

                        deffTMP=Tab(2).T{:,(i-1)*2+2};
                        deffTMP=deffTMP(~isnan(deffTMP));
                        BaseTest(i).Deff=deffTMP;
                    end

                    if ~isempty(Tab(1).T)
                        timeTMP=Tab(1).T{:,(i-1)*2+1};
                        timeTMP=timeTMP(~isnan(timeTMP));
                        BaseTest(i).Time=timeTMP;

                        forceTMP=Tab(1).T{:,(i-1)*2+2};
                        forceTMP=forceTMP(~isnan(forceTMP));
                        BaseTest(i).Force=forceTMP;
                        BaseTest(i).TimeHitSelection=[];
                    end
                end
            catch
                InfoMessage(obj,'Error: Unable to load measurments, check the files ...');
            end
            InfoMessage(obj,'Info: Successfuly loaded data!');
            warning('on','all');
        end
        %------------------------------------------------------------------
        %Resample data
        %------------------------------------------------------------------        
        function [T]=ResamplePressData(obj,inT)
            T=table;
            TargetFreq=2;
            for i=1:2:size(inT,2)-1
                Time=inT{:,i};
                OrgFreq=1/(Time(2)-Time(1));
                if OrgFreq<TargetFreq
                    
                    [N,D] = rat(TargetFreq/OrgFreq);                                       % Rational Fraction Approximation
                    Check = [TargetFreq/OrgFreq, N/D] ;


                    tmpTime=resample(inT{:,i},N,D);
                    tmpArr=resample(inT{:,i+1},N,D);
                    
                    T{:,i}=tmpTime;
                    T{:,i+1}=tmpArr;
                else
                    T{:,i}=inT{:,i};
                    T{:,i+1}=inT{:,i+1};
                end
            end
        end

        %------------------------------------------------------------------
        %Nacti zaznam ze zeda
        %------------------------------------------------------------------
        function [ZedoKey]=GetKeyOfMea(obj,pathTMP)
            alpha='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            warning('off','all');
            path=char(pathTMP);
            
            MeaPath=obj.BruteFolder;
            filesORG=dir([path '\*.txt']);
            tmp=strrep({filesORG.folder},MeaPath,'');
            folderTMP=string(tmp);%cell2struct(tmp,'folder');
            for i=1:length(folderTMP)
                filesORG(i).folder=char(folderTMP(i));
            end
            
            files=filesORG;
            fileNameTMP=[files(:).name];
            fileName=string(split(fileNameTMP,'.txt'));
            
            Records=struct;
            %zjistím jaké jsou pøítomné karty
            FileTypePattern={'-hit-','-ae-'};
            paterrns={'parameters','detector-'};
            SignalPatterns={'signal','hitdet'};
            
            for i=1:length(FileTypePattern)
                Idx=find(contains(fileName,FileTypePattern{i}));
                TMPFile=fileName(Idx);
                TMP=extractBefore(TMPFile,FileTypePattern{i});
                UnqCards=unique(TMP);
                break;
            end
            
            IdxE=find(contains(fileName,'event'));
            if length(IdxE)>0
                filename=[MeaPath files(IdxE).folder '\' files(IdxE).name];
                Events = readtable(filename,'ReadVariableNames',true,'HeaderLines', 5);
                [speed,Cards]=GetSpeed(obj,filename);     
            else
                Events=[];
                speed=[];
                Cards=[];
            end
            
            for iCard=1:length(UnqCards)
                clear CardFiles CardNames;
                Records(iCard).SampleCards=char(UnqCards(iCard));
                if ~isempty(Cards)
                    Records(iCard).Cards=char(Cards(iCard));
                else
                    Records(iCard).Cards=['Card ' alpha(iCard)];%char(UnqCards(iCard));
                end
                Records(iCard).Channel=categorical(cellstr(string(alpha(iCard))));                
                IdxCard=find(contains(fileName,Records(iCard).SampleCards));
                BoolSignals=find(contains(fileName,SignalPatterns{1}),1)>0;
                
                CardNames=fileName(IdxCard);   
                CardFiles=files(IdxCard);
                AEFiles=struct;
                
                for i=1:length(paterrns)
                Idx=find(contains(CardNames,paterrns{i}));
                    if ~isempty(Idx)
                        switch i
                            case 1 %parameters
                                Records(iCard).Param.Name=paterrns{i};
                                Records(iCard).Param.Data=readtable([MeaPath CardFiles(Idx).folder '\' CardFiles(Idx).name],'ReadVariableNames',true);
                                CardNames(Idx)=[];    
                                CardFiles(Idx)=[]; 
                            case 2 %detector
                                DetectorsNames=CardNames(Idx);
                                DetectorsFiles=CardFiles(Idx);
                                %ted ještì pro každý hitdetector musím
                                %nahrát signál
                                DecNum=extractAfter(DetectorsNames,paterrns{2});

                                for s=1:length(DecNum) %n hitdetector
                                
                                    DetectorName=[SignalPatterns{2} num2str(DecNum(s))];
                                    %AEFiles(2).Detec(s).Name=DetectorName;                                        
                                    Records(iCard).Detector(s).Name=DetectorName;
                                    Records(iCard).Detector(s).Data=readtable([MeaPath DetectorsFiles(s).folder '\' DetectorsFiles(s).name],'ReadVariableNames',true,'HeaderLines', 2);
                                    
                                    %if BoolSignals==true %signal
                                        IdxSignal=find(contains(CardNames,DetectorName));
                                        if ~isempty(IdxSignal)
                                            %daná karta mìla záznamy
                                            Records(iCard).Detector(s).Signals=AddID(obj,CardFiles(IdxSignal),CardNames(IdxSignal));
                                            Records(iCard).Detector(s).HaveSignals=true;
                                        else
                                            Records(iCard).Detector(s).HaveSignals=false;
                                            %obj.Options.Signals=0;
                                            warning('on','all');
                                            warning(['Card "' Records(iCard).SampleCards '" Didn''t recorded any signals']);
                                            warning('off','all');
                                            %daná karta nemìøila
                                            %Records(iCard).Detector(s).Signals=[];
                                        end
                                    %end
                                end
                            otherwise
                        end
                    end
                end
                
                TMPS={Records(iCard).Detector.Data};
                T=ConnTables(obj,TMPS);
                Records(iCard).ConDetector=T;
            end

            ZedoKey=struct('Speed',speed,'Events',Events,'Records',Records);
            warning('on','all');
           
        end
        
        function [IDFiles]=AddID(obj,IDFiles,Names)
            %HitsTMP=files(Index);
            IDTMP = double(split(Names,'id'));
            IDTMP(:,1)=[];
            ID=num2cell(IDTMP);
            [IDFiles.ID]=ID{:}; %postup rpo pøidání promìnné array do struktury
        end

        %------------------------------------------------------------------
        %Spojí tabulky
        %------------------------------------------------------------------
        function [ConTab]=ConnTables(obj,S)
            ConTab=table;
            for i=1:size(S,2)
                TMPT=S{i};
                ConTab=[ConTab; TMPT];
            end
        end
        %------------------------------------------------------------------
        %Vykresli jednotlivé hity v selektoru hitù
        %------------------------------------------------------------------
        function [BruteFolder]=GetBruteFolder(obj)
            BruteFolder=uigetdir(cd,'Vyber slozku s mìøenými vzorky');
            if BruteFolder==0
                BruteFolder="none";
            end
        end
        %------------------------------------------------------------------
        %Pøeèti jeden hit
        %------------------------------------------------------------------
        function [hit]=ReadHit(obj,folder,file)
            %folder='D:\Data\Vysoké uèení technické v Brnì\Fyzika.NDT - Dokumenty\Projekty\AE_Zedo\DataSource\A1\';
            %file='a-1.65.1a-ae-signal-hitdet0-id00156.txt';

            fileID=fopen([folder file]);
            strBlock = textscan(fileID,'%s'); % Read the file as one block
            fclose(fileID);
            strBlock2=join(string(strBlock{1,1}));
            strArr=split(strBlock2,'#');

            term={' Number-of-samples: ',' PSD-Dominant-Frequency [Hz]: ',' Sampling-Rate[MHz]: ',' Raw-Sample-File: ',' Channel: ',' Hit-ID: ',' Time-Start-Relative[sec]: '};
            hit=struct();

            hit.Description=strArr;
            %Cas hitu
            Index = find(contains(strArr,term{7}));
            hit.RelativeTime=double(strrep(strArr(Index),term{7},''));

            %Nazev karty
            Index = find(contains(strArr,term{5}));
            hit.Card=char(strrep(strArr(Index),term{5},''));

            %ID Hitu
            %Nazev karty
            Index = find(contains(strArr,term{6}));
            hit.ID=double(strrep(strArr(Index),term{6},''));

            %Pocet vzorkù
            Index = find(contains(strArr,term{1}));
            hit.nSamples=double(strrep(strArr(Index),term{1},''));

            %Dominantní frekvence
            Index = find(contains(strArr,term{2}));
            hit.PSDDominantFreq=double(strrep(strArr(Index),term{2},''));

            %Vzorkovací frekvence
            Index = find(contains(strArr,term{3}));
            tmp=double(strrep(strArr(Index),term{3},''));
            hit.SampleFreq=power(tmp(1),7);

            %Název souboru Bin
            Index = find(contains(strArr,term{4}));
            hit.BinFile=char(strrep(strArr(Index),term{4},''));

            %Nacteni datove øady
            fileIDBin=fopen([folder hit.BinFile]);
            hit.Signal = fread(fileID,hit.nSamples,'int16');
            fclose(fileIDBin);
        end
        %------------------------------------------------------------------
        %Pøeèti jeden hit
        %------------------------------------------------------------------
        function DrawExtractedFeatures(obj,sample)
            figure(1);
            hold on;
            box on;
            grid on;
            Feature=obj.ClassData.TrainData(sample).Features;
            Groups=obj.ClassData.TrainData(sample).Groups;
            Colors=obj.ClassData.TrainData(sample).Colors;
            unqGroups=max(Groups);
            
            for i=1:unqGroups
                Idx=find(Groups==i);
                scatter3(Feature.DomFreq(Idx),Feature.DomAmp(Idx),Feature.DomWidth(Idx),...
                    Feature.DomProm(Idx),'MarkerEdgeColor',Colors(Idx(1),:),'MarkerFaceColor',Colors(Idx(1),:),...
                    'DisplayName',num2str(i));
            end
            xlabel('Frequency');
            ylabel('Amplitude');
            zlabel('Width');
            legend;
            view(20,20);
        end
        %------------------------------------------------------------------
        %Ziskej rychlost ze zaznamu od libora
        %------------------------------------------------------------------
        function [speed,Cards]=GetSpeed(obj,filename)
            fileID=fopen(filename);
            strBlock = textscan(fileID,'%s'); % Read the file as one block
            fclose(fileID);
            strBlock2=join(string(strBlock{1,1}));

            strArr=split(strBlock2,'#');
            speedTMP=split(strArr(5,1),' ');
            speed=double(speedTMP(3,1));

            %cardsTMP=strArr([3 4],1);
            cardsTMP=split(strArr([3 4],1),' ');
            cardsTMP(:,[1 2 3])=[];
            cardsTMP=strrep(cardsTMP,' ','');
            CardsTMP=cellfun(@(s) strrep(s,'.Hit0',''),cardsTMP,'UniformOutput',false);
            Cards=string(CardsTMP);
        end
    end %konec private metod
    
    methods (Access = private) %Informování uživatele o práci programu
        function InfoMessage(obj,Msg)
            obj.CL=Msg;
                switch obj.Options.OpenType
                    case 1 %manualni pouzivani programu
                        disp(obj.CL); %ifnormuji v command line o praci porgramu
                    case 2 
                        %informacni hlasku davam do obj.CL aby si to project explorer mohl prevuit a zpracovat
                end
        end
        
    end %Konec private method
    
end %konec objektu


%------------------------------------------------------------------
%Utility functions
%------------------------------------------------------------------
function [output]=string2boolean(string)
   if strcmp(string,'false')
     output = false;
   else
     output = true;
   end
end


