classdef Zedo < DataFrame
    %MainTable is a PILOT type for all other possible measurments, ts
    %doesnt has to be present, but is higly recomended for the clarity and
    %clear structure of loaded data. PILOT type means, that it will guid
    %all other types which are present id datatypetable. PILOT has the key variable,
    %by which all other types will be sorted out. This design 
    properties
       
    end
    
    properties (Access = private)
        
    end
    
    methods
        function obj = Zedo(~)
            obj@DataFrame;
        end
        
        %will read data started from dataloader
        function Data=Read(obj,folder)
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
            %zjist�m jak� jsou p��tomn� karty
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
                                Records(iCard).Param.Data=readtable([CardFiles(Idx).folder '\' CardFiles(Idx).name],'ReadVariableNames',true);                                
                                CardNames(Idx)=[];    
                                CardFiles(Idx)=[]; 
                            case 2 %detector
                                DetectorsNames=CardNames(Idx);
                                DetectorsFiles=CardFiles(Idx);
                                %ted je�t� pro ka�d� hitdetector mus�m
                                %nahr�t sign�l
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
                                            %dan� karta m�la z�znamy
                                            Records(iCard).Detector(s).Signals=AddID(obj,CardFiles(IdxSignal),CardNames(IdxSignal));
                                            Records(iCard).Detector(s).HaveSignals=true;
                                        else
                                            Records(iCard).Detector(s).HaveSignals=false;
                                            %obj.Options.Signals=0;
                                            warning('on','all');
                                            %warning(['Card "' Records(iCard).SampleCards '" Didn''t recorded any signals']);
                                            warning('off','all');
                                            %dan� karta nem��ila
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
        
        function Tab=TabRows(obj,InT)
            Tab=obj.Data;
        end
        
        %------------------------------------------------------------------
        %Nacti zaznam ze zeda
        %------------------------------------------------------------------        
        function [IDFiles]=AddID(obj,IDFiles,Names)
            %HitsTMP=files(Index);
            IDTMP = double(split(Names,'id'));
            IDTMP(:,1)=[];
            ID=num2cell(IDTMP);
            [IDFiles.ID]=ID{:}; %postup rpo p�id�n� prom�nn� array do struktury
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
        %P�e�ti jeden hit
        %------------------------------------------------------------------
        function [hit]=ReadHit(obj,folder,file)
            %folder='D:\Data\Vysok� u�en� technick� v Brn�\Fyzika.NDT - Dokumenty\Projekty\AE_Zedo\DataSource\A1\';
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

            %Pocet vzork�
            Index = find(contains(strArr,term{1}));
            hit.nSamples=double(strrep(strArr(Index),term{1},''));

            %Dominantn� frekvence
            Index = find(contains(strArr,term{2}));
            hit.PSDDominantFreq=double(strrep(strArr(Index),term{2},''));

            %Vzorkovac� frekvence
            Index = find(contains(strArr,term{3}));
            tmp=double(strrep(strArr(Index),term{3},''));
            hit.SampleFreq=power(tmp(1),7);

            %N�zev souboru Bin
            Index = find(contains(strArr,term{4}));
            hit.BinFile=char(strrep(strArr(Index),term{4},''));

            %Nacteni datove �ady
            fileIDBin=fopen([folder hit.BinFile]);
            hit.Signal = fread(fileID,hit.nSamples,'int16');
            fclose(fileIDBin);
        end
        
        %------------------------------------------------------------------
        %Spoj� tabulky
        %------------------------------------------------------------------
        function [ConTab]=ConnTables(obj,S)
            ConTab=table;
            for i=1:size(S,2)
                TMPT=S{i};
                ConTab=[ConTab; TMPT];
            end
        end
        
    end

    %Gui for data type selection 
    methods (Access = public)   
        %set property
        function SetVal(obj,val,idx)
            obj.TypeSet{idx}=val;
        end       
        
        %add card to zedo
        %Key(obj,han.Value,obj.Count,Target);
        function AddCard(obj,n,~,Parent)
            %(obj,Parent,Type,Key)
            DrawUITreeNode(obj,Parent,['Card ' char(num2str(n))],@UpdateCardInfo);
            
        end
        
        %add channel
        function AddChannel(obj,Parent,n)
            DrawUITreeNode(obj,Parent,['Channel ' char(double2str(n))],@UpdateCardInfo);
        end
        
        %function edit card
        function UpdateCardInfo(obj,value,node)
            
        end
        
        %adrow in table
        function TypeAdRow(obj,Value,idx,Target)
            obj.TypeSet{idx}=Value;
            dim=size(Target.Data);
            if dim(1)~=Value
                if Value>dim(1)
                    Target.Data=[Target.Data; OperLib.MTBlueprint];
                    Target.Data{end,4}=Value;
                else
                    Target.Data(end,:)=[];
                end
                obj.TypeSet{Target.UserData{2}}=Target.Data;
            end
        end
        %will initalize gui for first time
        function InitializeOption(obj)
            
            Clear(obj);
            
%             Target=DrawUITree(obj,@SetVal);
%             DrawSpinner(obj,[1 20],Target,@AddCard);
%             DrawUIEditField(obj,"Channel 1",@UpdateCardInfo);
%             
            DrawLabel(obj,['SimpleZedo format at the moment \n',...
                           'Select composition of main table: by spinner select number of columns \n',...
                           'and choose the type of each column, column position in source file.',...
                           'IMPORTANT: there can be only one KeyColumn'],[300 60]);
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
    end
end

