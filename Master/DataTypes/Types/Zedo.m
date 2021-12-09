classdef Zedo < AcousticEmission
    %MainTable is a PILOT type for all other possible measurments, ts
    %doesnt has to be present, but is higly recomended for the clarity and
    %clear structure of loaded data. PILOT type means, that it will guid
    %all other types which are present id datatypetable. PILOT has the key variable,
    %by which all other types will be sorted out. This design 
    properties
       HasEvents logical;
       SensorCoordinates;
    end
    
    properties (Access = private)
        
    end
    
    methods %main methods with abstract interpretations
        function obj = Zedo(parent)
            obj@AcousticEmission(parent);
            
            obj.ContainerType=OperLib.GetContainerTypes(2);
            obj.KeyWord="";
            obj.Sufix="";
            obj.SensorCoordinates=table([],[],[],[],[],[],'VariableNames',{'ID','x','y','z','OrientHor','OrientVert'});
        end
        
        function Tab=TabRows(obj,InT)
            Tab=obj.Data;
        end
        
                
        function [T]=GetVarNames(obj)
            
        end
        
        function obj2=Copy(obj)
            obj2=Zedo;  
            obj2.Data=obj.Data;
            obj2.Filename=obj.Filename;
            obj2.Folder=obj.Folder;
            obj2.GuiParent=obj.GuiParent;
            obj2.Count=obj.Count;
            obj2.Children=obj.Children;
            obj2.TypeSet=obj.TypeSet;
            obj2.Init=obj.Init;
            obj2.Pos=obj.Pos;
        end
        
        function Data=PackUp(obj)
            Data=table({obj.Data},'VariableNames',{'ZedoKey'});
        end
    end
    
    methods %reading
       %will read data started from dataloader
       function result=ReadDb(obj)
       end
       
       function result=Read(obj,folder,~)
           result=struct;
           measfolder=dir(folder);
           measfolder([1,2])=[];
           
           result.key=string({measfolder(:).name})';
           result.count=numel(result.key);
           result.type=class(obj);


           for i=1:result.count
               folder=[measfolder(i).folder '\' measfolder(i).name];
               Data=ReadFolder(obj,folder);
               result.data(i).meas=Data;
           end
       end
       
       
        function data=ReadFolder(obj,folder)
%             data=GetEmptyArr(obj);
            
            obj.Folder=folder;
            alpha=OperLib.GetAlpha;
            warning('off','all');
            parts=split(obj.Folder,'\');
            SpecName=lower([parts{end},'.']);
            
            T=OperLib.GetTypeDir(folder);
            T2=T(T.suffix==".txt",:);
            fileName=T2.name;
            
            Records=struct;
            %zjistím jaké jsou pøítomné karty
            FileTypePattern={'-hit-','-ae-'};
            paterrns={'-parameters','detector-'};
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
                AllEvents=struct;
                for i=IdxE'
                    filename=[char(T2.folder(i)) '\' char(T2.file(i))];
    %                 opts=detectImportOptions(filename,'Delimiter','\t');
                    [HeaderLine]=OperLib.GetHeadersLine(filename,'Event');

                    Events = readtable(filename,'ReadVariableNames',true,'HeaderLines',HeaderLine,'Delimiter','\t');

                    time=string(Events{:,7});
                    Events(:,7)=[];
                    str=replace(time,'/',' ');
                    time=datetime(str,'Format','dd.MM.yyyy hh:mm:ss.s');
                    Events=addvars(Events,time,'Before','Last_Hit_End_Relative_sec_');
                    Events.Properties.VariableNames{7}='DateTime';

                    Order=split(Events{:,4},',');
                    Order(:,1)=replace(Order(:,1),',','');
                    Events(:,4)=[];
                    Events=addvars(Events,lower(Order),'Before','Hits_IDs');
                    Events.Properties.VariableNames{4}='Sensors_Order';

                    Order=split(string(Events{:,5}),',');
                    Order2=double(Order);
                    Events(:,5)=[];
                    Events=addvars(Events,Order2,'Before','First_Hit_Start_Relative_sec_');
                    Events.Properties.VariableNames{5}='Hits_IDs';

                    [speed,Cards]=GetSpeed(obj,filename);
                    if numel(IdxE)==1
                        AllEvents=Events;
                    else
                        AllEvents(i).Part=Events;
                    end
                end
                
                
            else
                AllEvents=[];
                speed=[];
                Cards=[];
            end
            
            
            
            for iCard=1:length(UnqCards)
                clear CardFiles CardNames;
                Records(iCard).SampleCards=replace(char(UnqCards(iCard)),SpecName,'');
                if ~isempty(Cards)
                    Records(iCard).Cards=char(Cards(iCard));
                else
                    Records(iCard).Cards=['Card ' alpha(iCard)];%char(UnqCards(iCard));
                end
                Records(iCard).Channel=char(string(alpha(iCard)));
                IdxCard=find(contains(fileName,Records(iCard).SampleCards));
                BoolSignals=find(contains(fileName,SignalPatterns{1}),1)>0;
                
                CardNames=fileName(IdxCard);   
                CardFiles=T2(IdxCard,:);
                AEFiles=struct;
                
                for i=1:length(paterrns)
                Idx=find(contains(CardNames,paterrns{i}));
                    if ~isempty(Idx)
                        switch i
                            case 1 %Parameters
                                Records(iCard).Parameters=readtable([char(CardFiles.folder(Idx)) '\' char(CardFiles.file(Idx))],'ReadVariableNames',true);                                
                                
                                
                                time=string(Records(iCard).Parameters{:,2});
                                Records(iCard).Parameters(:,2)=[];
                                
                                str=replace(time,'/',' ');
                                time=str;%datetime(str,'InputFormat','dd.MM.yyyy hh:mm:ss.s');
                                names=Records(iCard).Parameters.Properties.VariableNames;
                                Records(iCard).Parameters = addvars(Records(iCard).Parameters,time,'Before',names{2});
                                Records(iCard).Parameters.Properties.VariableNames{2}='DateTime';
                                
%                                 Records(iCard).Parameters.DateTime=time;
                                %remove this file from list, so it wont be
                                %loaded again
                                CardNames(Idx)=[];    
                                CardFiles(Idx,:)=[]; 
                                
                            case 2 %detector
                                DetectorsNames=CardNames(Idx);
                                DetectorsFiles=CardFiles(Idx,:);
                                DecNum=extractAfter(DetectorsNames,paterrns{2});

                                %decide if each detector has its own
                                %signals, or one signal for all detectors
                                IdxSignal=find(contains(CardFiles.name,SignalPatterns{1}));
                                CardSignals=CardFiles(IdxSignal,:);
                                
                                sigperdec=find(contains(CardSignals.name,SignalPatterns{2}));
                                Records(iCard).Signals=table;
                                Records(iCard).Features=table;
                                if numel(sigperdec)==0
                                    %there is only one set of signals, per
                                    %whole channel
                                    Records(iCard).SignalPerEachDetector=false;
                                    
                                    ID=split(CardSignals.name,SignalPatterns{1});
                                    ID(:,1)=[];
                                    ID=abs(double(ID));
                                    
                                    CardSignals=[table(ID,'VariableNames',{'ID'}), CardSignals];
                                    Records(iCard).Signals=CardSignals;
                                else
                                    Records(iCard).SignalPerEachDetector=true;
                                end

                                Records(iCard).ConDetector=table;
                                for s=1:length(DecNum) %n hitdetector

                                    DetectorName=[SignalPatterns{2} num2str(DecNum(s))];
                                    
                                    Records(iCard).Detector(s).Name=DetectorName;
                                    Records(iCard).Detector(s).Data=readtable([char(DetectorsFiles.folder(s)) '\' char(DetectorsFiles.file(s))],...
                                        'ReadVariableNames',true,'HeaderLines', 2);
                                    Records(iCard).Detector(s).Signals=table;
                                    Records(iCard).Detector(s).Features=table;
                                    
                                    if BoolSignals==true
                                        if Records(iCard).SignalPerEachDetector==true
                                            Idx=find(contains(CardFiles.name,DetectorName));
                                            DetSignals=CardFiles(Idx,:);
                                            ID=split(DetSignals.name,[DetectorName '-id']);
                                            ID(:,1)=[];
                                            ID=abs(double(ID));
                                            Records(iCard).Detector(s).Signals=[table(ID,'VariableNames',{'ID'}),DetSignals];
                                        end
                                    end
                                    
                                    rows=size(Records(iCard).Detector(s).Data,1);
                                    hitdet=linspace(1,rows,rows)';
                                    CT=[table(hitdet,'VariableNames',{'HitDetID'}), Records(iCard).Detector(s).Data];
                                    Records(iCard).ConDetector=[Records(iCard).ConDetector; CT];
                                    

                                end
                            otherwise
                        end
                    end
                end
                
%                 TMPS={Records(iCard).Detector.Data};
%                 T=ConnTables(obj,TMPS);
%                 Records(iCard).ConDetector=T;
            end
            
            data=struct('Speed',speed,'Events',AllEvents,'Records',Records);
            %ZedoKey=struct('Speed',speed,'Events',Events,'Records',Records);
            warning('on','all');
        end
        
        function data=GetEmptyArr(obj)
            data=struct("speed",[],"events",[]);
            
%             cardcount=GetTypeProp(obj,name);
            cardcount=obj.TypeSettings.Value{2};
            senpercard=obj.TypeSettings.Value{3};
            
            records=struct;
            n=0;
            for i=1:cardcount
                for j=1:senpercard
                    n=n+1;
                    chann=GetChannel(obj);
                    
                    chann.CardID=i;
                    chann.ChannelID=j;
                    
                    data.records(n)=chann;
                end
            end
        end
        
        function Events=AdjustEvents(obj,Events)
            
            HitsID=cellfun(@(y) str2double(y),split(Events{:,6},','));
            TMPCards=[strrep(Events{:,4},',',''), Events{:,5}];
            Cards=string(cellfun(@(s) char(s),TMPCards,'UniformOutput',false));
            Events=[Events, table(HitsID), table(Cards)];
        end
        %------------------------------------------------------------------
        %Nacti zaznam ze zeda
        %------------------------------------------------------------------        
        function [IDFiles]=ExtractID(obj,IDFiles,Names)
            %HitsTMP=files(Index);
            IDTMP = double(split(Names,'signal'));
            IDTMP(:,1)=[];
            ID=abs(IDTMP);
%             ID=num2cell(ID);
            for i=1:size(IDFiles,1)
                IDFiles(i).ID=ID(i,1);
            end
%             [IDFiles.ID]=ID; %postup rpo pøidání promìnné array do struktury
        end
        
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
        %Spojí tabulky
        %------------------------------------------------------------------
        function [ConTab]=ConnTables(obj,S)
            ConTab=table;
            for i=1:size(S,2)
                TMPT=S{i};
                ConTab=[ConTab; TMPT];
            end
        end
        
        function GetXDeltas(obj,length,velocity,or)
            %1D localization
            if ~isempty(obj.Data.Events)
                E=obj.Data.Events;
                obj.Data.Speed=velocity;
                obj.Data.Records(1).Position=0;
                obj.Data.Records(2).Position=length;

                ECount=size(E,1);
                XDelta=zeros([ECount, 1]);
                %tst=E{i,14}(1);
                if or<0
                    orientation=2;
                else
                    orientation=1;
                end
                
                FirstCard=string(obj.Data.Records(orientation).Cards);
                
                for i=1:ECount
                    if strcmp(E{i,15}(1),FirstCard)
                        TDiff=abs(E{i,7}-E{i,9});
                        LDiff=TDiff*velocity;
                        LDiff=length-(LDiff+(length-LDiff)/2);
                        XDelta(i)=LDiff;   
                    else
                        TDiff=abs(E{i,9}-E{i,7});
                        LDiff=TDiff*velocity;
                        LDiff=LDiff+(length-LDiff)/2;
                        XDelta(i)=LDiff;   
                    end
                end

                if sum(contains(E.Properties.VariableNames,'XDelta'))>0
                    E.XDelta=XDelta;
                else
                    E=[E, table(XDelta)];
                end
                obj.Data.Events=E;
                obj.HasEvents=true;
            else
                obj.HasEvents=false;
            end
        end
    end

    %Gui for data type selection 
    methods (Access = public)   
        

        
        function T=GetZBl(obj)
            loctype=LocType(obj);
            Name={'AE device','Number of cards','Channels per card','Localization','Local type'}';
            Value={'Zedo',...
                1,2,...
                false,...
                loctype(1)}';
            T=table(Name,Value);
        end
        
        

        function SetVal(obj,event)
            sensorCount=event.Source.Data.Value{2}*event.Source.Data.Value{3};
            loctype=LocType(obj);
            test=false;
            while test==false
                switch char(event.Source.Data.Value{5})
                    case '~'
                        test=1;
                    case '1D'
                        if sensorCount<2
                            event.Source.Data.Value{5}=loctype(1);
                        else
                            test=1;
                        end
                    case '2D'
                        if sensorCount<3
                            event.Source.Data.Value{5}=loctype(2);
                        else 
                            test=1;
                        end
                    case '3D'
                        if sensorCount<5
                            event.Source.Data.Value{5}=loctype(3);
                        else 
                            test=1;
                        end
                end
            end
            obj.TypeSettings=event.Source.Data;
        end
        


        %will initalize gui for first time
        function CreateTypeComponents(obj)
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,250,50};
            g.ColumnWidth = {'1x','2x',44,44};
            
   
            la=uilabel(g,'Text','Columns selection:');
            
            la.Layout.Row=1;
            la.Layout.Column=[1 4];
            
            T=GetZBl(obj);
            uit = uitable(g,'Data',T,'ColumnEditable',[false,true],...
                'ColumnWidth','auto','CellEditCallback',@(src,event)SetVal(obj,event));
            
            if strcmp(class(obj.TypeSettings),'table')
                uit.Data=obj.TypeSettings;
            end
            
            uit.Layout.Row = 2;
            uit.Layout.Column = [1 4];
            
           
            
            MF=OperLib.FindProp(obj.Parent,'MasterFolder');
            
            IconFolder=[MF 'Master\GUI\Icons\'];
            IconFilePlus=[IconFolder 'plus_sign.gif'];
            IconFileMinus=[IconFolder 'cancel_sign.gif'];

            
            obj.Children=[g;la;uit];
        end
        
    end
    
    %Gui for plotter
    methods 
        function han=PlotType(obj,ax)

        end
        
        function Out=GetParameterss(obj,Name)
            Out=obj.Data;
        end
        
        function Out=GetVariables(obj)
            
        end
    end
end

