classdef Zedo < AcousticEmission
    %MainTable is a PILOT type for all other possible measurments, ts
    %doesnt has to be present, but is higly recomended for the clarity and
    %clear structure of loaded data. PILOT type means, that it will guid
    %all other types which are present id datatypetable. PILOT has the key variable,
    %by which all other types will be sorted out. This design 
    properties
       HasEvents logical;
    end
    
    properties (Access = private)
        
    end
    
    methods %main methods with abstract interpretations
        function obj = Zedo(parent)
            obj@AcousticEmission(parent);
            
            obj.ContainerType=OperLib.GetContainerTypes(2);
            obj.KeyWord="";
            obj.Sufix="";
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
        function Data=Read(obj,folder)
            obj.Folder=folder;
            alpha='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            warning('off','all');
            path=folder;
            
            MeaPath=folder;
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
                filename=[files(IdxE).folder '\' files(IdxE).name];
                [HeaderLine]=OperLib.GetHeadersLine(filename,'Event');
                
                Events = readtable(filename,'ReadVariableNames',true,'HeaderLines',HeaderLine);
                Events=AdjustEvents(obj,Events);
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
                                Records(iCard).Param.Data=readtable([CardFiles(Idx).folder '\' CardFiles(Idx).name],'ReadVariableNames',true);                                
                                CardNames(Idx)=[];    
                                CardFiles(Idx)=[]; 
                            case 2 %detector
                                DetectorsNames=CardNames(Idx);
                                DetectorsFiles=CardFiles(Idx);
                                %ted ještì pro každý hitdetector musím
                                %nahrát signál
                                DecNum=extractAfter(DetectorsNames,paterrns{2});

                                for s=1:length(DecNum) %n hitdetector
                                    clear NHitDet;
                                    DetectorName=[SignalPatterns{2} num2str(DecNum(s))];
                                    %AEFiles(2).Detec(s).Name=DetectorName;                                        
                                    Records(iCard).Detector(s).Name=DetectorName;
                                    Records(iCard).Detector(s).Data=readtable([DetectorsFiles(s).folder '\' DetectorsFiles(s).name],'ReadVariableNames',true,'HeaderLines', 2);
                                    
                                    NHitDet(1:size(Records(iCard).Detector(s).Data,1),1)=s;
                                    Records(iCard).Detector(s).Data=[Records(iCard).Detector(s).Data table(NHitDet)];
                                    
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
                                            %warning(['Card "' Records(iCard).SampleCards '" Didn''t recorded any signals']);
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
            Zedo=struct('Speed',speed,'Events',Events,'Records',Records);
            obj.Data=Zedo;
            %ZedoKey=struct('Speed',speed,'Events',Events,'Records',Records);
            warning('on','all');
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
        function [IDFiles]=AddID(obj,IDFiles,Names)
            %HitsTMP=files(Index);
            IDTMP = double(split(Names,'id'));
            IDTMP(:,1)=[];
            ID=num2cell(IDTMP);
            [IDFiles.ID]=ID{:}; %postup rpo pøidání promìnné array do struktury
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

        %set property
        function SetVal(obj,val,idx)
            obj.TypeSet{idx}=val;
        end       
        
        %add channel
        function AddChannel(obj,Parent,n)
            DrawUITreeNode(obj,Parent,['Channel ' char(double2str(n))],@UpdateCardInfo);
        end
        
        %function edit card
        function UpdateCardInfo(obj,value,node)
            
        end
        
        function AEbox=ZBlueprint(obj)
            AEbox=struct;
            AEbox.name='ZedoBox';
            AEbox.card(1)=ZCard(obj,1);

        end
        
        function channel=ZChannel(obj,n)
            channel=struct;
            channel.name=string(sprintf('Channel %d',n));
        end
        
        function card=ZCard(obj,n)
            card=struct;
            card.name=string(sprintf('Card %d',n));
            card.channel(1)=ZChannel(obj,1);
            card.channel(2)=ZChannel(obj,2);
        end

        %will initalize gui for first time
        function CreateTypeComponents(obj)
            g=uigridlayout(obj.GuiParent);
            g.RowHeight = {22,250,50};
            g.ColumnWidth = {'1x','2x',44,44};
            
   
            la=uilabel(g,'Text','Columns selection:');
            
            la.Layout.Row=1;
            la.Layout.Column=[1 4];
            
            
            t = uitree(g);
            t.Layout.Row=2;
            t.Layout.Column=[1 3];
            
            
           
            
            MF=OperLib.FindProp(obj.Parent,'MasterFolder');
            
            IconFolder=[MF 'Master\GUI\Icons\'];
            IconFilePlus=[IconFolder 'plus_sign.gif'];
            IconFileMinus=[IconFolder 'cancel_sign.gif'];
            
            
            
            but1=uibutton(g,'Text','',...
                'ButtonPushedFcn',@(src,event)obj.AddCard(obj,event));
            
            but1.Layout.Row=1;
            but1.Layout.Column=3;
            but1.Icon=IconFilePlus;
            
            but2=uibutton(g,'Text','',...
                'ButtonPushedFcn',@(src,event)obj.RemoveCard(obj,event));
            but2.Layout.Row=1;
            but2.Layout.Column=4;
            but2.Icon=IconFileMinus;
            
            
             
            AEbox=ZBlueprint(obj);
            if strcmp(class(obj.TypeSettings),'struct')
                FillTree(obj,obj.TypeSettings,t)
            else
                FillTree(obj,AEbox,t);
            end
            
            
            
            obj.Children=[g;la;t;but1;but2];
        end
        
        function FillTree(obj,AEbox,tree)
            
            a=tree.Children;
            a.delete;
            
            ZB=uitreenode(tree,'Text',AEbox.name);
            for i=1:size(AEbox.card,2)
                CardNode{i}=uitreenode(ZB,'Text',AEbox.card(i).name);
                
                for j=1:size(AEbox.card(i).channel,2)
                    ChNode{i,j}=uitreenode(CardNode{i},'Text',AEbox.card(i).channel(j).name);
                end
            end
            
            
            obj.TypeSettings=AEbox;
        end
        
        function AddCard(obj,event,source)
            AEbox=event.TypeSettings;
            
            cardcount=size(AEbox.card,2);
            card=ZCard(obj,cardcount+1);
            
            AEbox.card(cardcount+1)=card;
            
            node=event.Children(3, 1).Children;
            
            
            cardNode=uitreenode(node,'Text',card.name);
            cha1Node=uitreenode(cardNode,'Text',card.channel(1).name);
            cha2Node=uitreenode(cardNode,'Text',card.channel(2).name);
            
            event.TypeSettings=AEbox;
        end
        
        function RemoveCard(obj,event,source)
            AEbox=event.TypeSettings;
            last=size(AEbox.card,2);
            if last>1
                a=event.Children(3, 1).Children.Children;
                a(end).delete;
                AEbox.card(last)=[];
                event.TypeSettings=AEbox;
            end
        end
    end
    
    %Gui for plotter
    methods 
        function han=PlotType(obj,ax)
            yyaxis(ax,'right');
            hold(ax,'on');
            x=obj.Data.Records.ConDetector{:,4};
            y=cumsum(obj.Data.Records.ConDetector{:,17});
            plot(ax,x,y);
            ylabel(ax,'Cummulative hits \it AE_{hits} \rm [hit]');
            
        end
        
        function Out=GetParams(obj,Name)
            R=obj.Data.Records;
            Out=table;
            
            for card=1:size(R,2)
                
                Names=strings([size(R(card).ConDetector,1),1]);
                Card=strings([size(R(card).ConDetector,1),1]);
                Names(:,1)=Name;
                Card(:,1)=R(card).Cards;
                Out=[Out; table(Names,Card), R(card).ConDetector];                
                %Out{end,:}=[];
            end
        end
        
        function Out=GetEvents(obj,Name)
            Out=obj.Data.Events;
        end
        
        function Out=GetVariables(obj)
            
        end
    end
end

