disk='E:\Google drive';
cd([disk '\GitHub\Matlab\AE\']);
%%
%smaže všechny promìné
clear all;
%%
%smaže všechny promìné kromì ...
clearvars  -except h;
%%
b=ProjectExplorer;
%%
h=AEZedo;
%%
PrepareAnalysis(h,'Samples','all','FullTime','hitdetector',0,'Signals','false')
%%
LoadMeasurement(h);
%%
SaveWork(h);
%%
b=ProjectObj;
%%
[h]=LoadWork(h);
%%
test=["A","B","C","D"];
test2=categorical(test');
test3=table(test2);

%%
%tyto pøíkazy již není potøeba používat
Set=struct;
Set(1).Desc="Default";
Set(2).Desc="Set 1";

Set(1).Val=1;
Set(2).Val=2;

tst=string({Set.Desc});
tst2=[Set.Val];
%%
T = table(rand(10,1),categorical(cellstr(('rgbbrgrrbr').')))
% Convert to double and extract with {}
Td = varfun(@double,T)
mat = Td{:,:}
%%
%vše lze zapsat pøímo do volání funkce
%je jedno jestli se píšou malé nebo velké písmena
PrepareAnalysis(h,'Samples','all','FullTime','hitdetector',0,'Signals','false'); 
%tento pøíkaz zpracuje všechny tìlesa ve všch èasech, z hitdetectoru 0 a
%zahrne i signály

%%
PrepareAnalysis(h,'Samples','all','FullTime','hitdetector',0,'Signals','true'); 
%tento pøíkaz zpracuje vzorky 1 a 3 z hitdetectoru 0, 1 a 2 bez zahrnutí
%signálù

%%
ExtractFeatures(h);
%%
%nemusíš spouštìt
ShowFeatures(h);
%%
Learn(h,[10 10]);
%%
NewMeaPath(h);
%%
[h1]=PlotStatistics(h,'sample',[2]); %zatím nejde dìlat všechny
%%
[h2]=PlotStatistics(h,'sample',[1]); %zatím nejde dìlat všechny
%%
[h3]=PlotStatistics(h,'all'); %zatím nejde dìlat všechny
%do data se uloží všechny data, i ty, které zrovna nejsou vykreslené v
%plotu
%%
Data=handle.DataTable;
%%
test=char()
%%
%exportuje tabulku v místì složky s mìøeními
filename=[h.MeaFolder  'DataExport.xlsx'];
writetable(Data,filename,'Sheet','Export');
%%
unq=length(unique(DataLearn.Classes));
%% Shear / tensile - clases
figure(1);
hold on;

DataLearn=[h.ClassData.ClassLearnerData, table(h.ClassData.SampleNames,'VariableNames',{'SampleNames'})];
SelNames={'A1','A2','A3','E1','E2','E3'};
IdSample=contains(DataLearn.SampleNames,SelNames);
DataLearn=DataLearn(IdSample,:);
%
clear AvgFreq;
Dur=DataLearn.Duration_ns_;
HCount=DataLearn.HCount_N_;
AvgFreq=Dur./HCount;

RiseTime=DataLearn.Risetime_ns_;
MaxAmplitude=DataLearn.Max_Amplitude_V_;

RAVal=(RiseTime*1e-8)./MaxAmplitude;

colormap(jet(100));
Size=abs(DataLearn{:,6}.*1e+12);
scatter(RAVal,AvgFreq,10,DataLearn.Classes,'filled');
col=colorbar;
col.Label.String='AE Classes [-]';


Alpha=63;


YMax=max(AvgFreq);
XMax=max(RAVal);

[XCoor,YCoor]=Hypotenuse(XMax,YMax,Alpha);
XLine=[0 XCoor];
YLine=[0 YCoor];
B=0;
plot(XLine,YLine+B,'-k');

xlabel('RA values [ms/V]');
ylabel('Average frequency [Hz]');

red=[0.75 0.8];
STR={'\leftarrow Tensile crack','Shear crack \rightarrow'};
text(XCoor*red(1),YCoor*red(2),STR{1},'HorizontalAlignment','right','Rotation',Alpha-90,'FontSize',10);
text(XCoor*red(2),YCoor*red(1),STR{2},'Rotation',Alpha-90,'FontSize',10);

%ylim(YLine);
%xlim(XLine);
%%
figure(1);
hold on;
%SampleNames=h.ClassData.SampleNames;

DataLearn=[h.ClassData.ClassLearnerData, table(h.ClassData.SampleNames,'VariableNames',{'SampleNames'})];

SelNames={'A1','A2','A3','E1','E2','E3'};
IdSample=contains(DataLearn.SampleNames,SelNames);
DataLearn=DataLearn(IdSample,:);

SampleNames=DataLearn.SampleNames;
UnqNames=unique(SampleNames);
clear AvgFreq NumSampleNames;
for i=1:length(DataLearn.SampleNames)    
    NumSampleNames(i,1)=find(UnqNames==DataLearn.SampleNames(i));
    
end
%DataLearn=DataLearn(DataLearn.SampleNames=="G3",:);
%

Dur=DataLearn.Duration_ns_;
HCount=DataLearn.HCount_N_;
AvgFreq=Dur./HCount;

RiseTime=DataLearn.Risetime_ns_;
MaxAmplitude=DataLearn.Max_Amplitude_V_;

RAVal=(RiseTime*1e-8)./MaxAmplitude;

colormap(copper(length(SelNames)));
Size=abs(DataLearn{:,6}.*1e+12);
for s=1:length(unique(NumSampleNames))
    [row,col]=find(NumSampleNames==s);
    Id=row;
    han(s)=scatter(RAVal(Id),AvgFreq(Id),DataLearn{Id,24},NumSampleNames(Id),'filled','SeriesIndex',s,'DisplayName',SelNames{s});
end
col=colorbar;
col.Label.String='AE Classes [-]';
legend(SelNames);

Alpha=63;


YMax=max(AvgFreq);
XMax=max(RAVal);

[XCoor,YCoor]=Hypotenuse(XMax,YMax,Alpha);
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

%%
clear trainData;
train=h.ClassData.TrainDataSum  ;
class=h.ClassData.Classes;
trainData=[train, class];
%%
figure(1);

hold on;
plot(Hits(1).Time,Hits(1).hCumSum,':','Color',[.2 .2 .2]);
yyaxis right;
scatter(X,Y,ClassColor*5,ClassColor,'filled','Marker','v');
colorbar;
colormap(parula);
caxis([0 25]);
%%
scatter(X,Y,[],Colors,'filled');
%%
h.ClassData.ClassLearnerData
%%
x=h.ClassData.ClassLearnerData;

%%
[test]=TestFun('length',12,'height',13,'width',15)
%%
tmp=h.Measuremnts.Basic(1).TimeHitSelection
%%
predictorNames = x.Properties.VariableNames(1:end-1);
%%
filename=[cd '\' 'AEClassifierVar.mat'];
save(filename,'h','-v7.3');
%%
load([cd '\AEClassifierVar.mat'])
%%
VarNames=h.ClassData.Stat.VarNames(1:end-1);

%%
handle=ClassStatPlot(h.ClassData.Stat);

%ax=f.UIAxes;

%%
fig=uifigure;
ax = uiaxes('Parent',fig,...
    'Position',[10 40 580 440]);
fig.Position(3:4) = [600 500];

hold(ax,'on');

[p]=InitiatePoints(ax,1,2,h);
[cboX,cboY]=DrawUi(fig,h,ax,p)

function [cboY,cboX]=DrawUi(fig,h,ax,p)
cboY = uidropdown(fig,...
    'Position',[120 10 100 28],...
    'Items',h.ClassData.Stat.VarNames,...
    'Value',h.ClassData.Stat.VarNames{2},...
    'ValueChangedFcn',@(cboY,event) selection(cboX,cboY,h,ax,p));

cboX = uidropdown(fig,...
    'Position',[10 10 100 28],...
    'Items',h.ClassData.Stat.VarNames,...
    'Value',h.ClassData.Stat.VarNames{1},...
    'ValueChangedFcn',@(cboX,event) selection(cboX,cboY,h,ax,p));
end



%UpdateData(ax,p,3,4,h)
%data=p(1).XData; 
 
%DrawClases(ax,3,4,h);

function [p]=InitiatePoints(ax,xn,yn,h)
color=parula(h.ClassData.nClases);
str=h.ClassData.Stat.Classes;

X=h.ClassData.Stat.Mean{:,xn};
[Xb,I]=sort(X);
Y=h.ClassData.Stat.Mean{:,yn};

Xstd=h.ClassData.Stat.Std{:,xn};
Ystd=h.ClassData.Stat.Std{:,yn};

    for i=1:h.ClassData.nClases
        Xi=Xb;
        Yi=Y(I);
        YSTDi=Ystd(I);
        XSTDi=Xstd(I);
        p(i)=errorbar(ax,Xi(i),Yi(i),YSTDi(i),YSTDi(i),XSTDi(i),XSTDi(i),'o','Color','k',...
            'MarkerSize',10,'MarkerFaceColor',[color(i,1) color(i,2) color(i,3)],'MarkerEdgeColor','k',...
            'CapSize',10);
    end
%text(Xb+max(Xb)*0.02,Y(I)+max(Y)*0.08,str,'Units','data');

xlabel(ax,h.ClassData.Stat.VarNames{xn});
ylabel(ax,h.ClassData.Stat.VarNames{yn});
%warning('on','all');
c=colorbar(ax);
c.Label.String='Clases';
c.Box='on';
%set(gca,'XScale','log');
end

function UpdateData(ax,p,xn,yn,h)
color=parula(h.ClassData.nClases);
str=h.ClassData.Stat.Classes;

X=h.ClassData.Stat.Mean{:,xn};
Xstd=h.ClassData.Stat.Std{:,xn};
[Xb,I]=sort(X);

Y=h.ClassData.Stat.Mean{:,yn};
Ystd=h.ClassData.Stat.Std{:,yn};

    for i=1:h.ClassData.nClases
        Xi=Xb;
        Yi=Y(I);
        YSTDi=Ystd(I);
        XSTDi=Xstd(I);
        

        p(i).XData=Xi(i);
        p(i).XNegativeDelta=XSTDi(i);
        p(i).XPositiveDelta=XSTDi(i);

        

        p(i).YData=Yi(i);
        p(i).YNegativeDelta=YSTDi(i);
        p(i).YPositiveDelta=YSTDi(i);
        
        p(i).MarkerFaceColor=[color(i,1) color(i,2) color(i,3)];
    end
%text(Xb+max(Xb)*0.02,Y(I)+max(Y)*0.08,str,'Units','data');

xlabel(ax,h.ClassData.Stat.VarNames{xn});
ylabel(ax,h.ClassData.Stat.VarNames{yn});
%warning('on','all');
c=colorbar(ax);
c.Label.String='Clases';
c.Box='on';
%set(gca,'XScale','log');
end

function selection(cboX,cboY,h,ax,p)

names=string(h.ClassData.Stat.VarNames);
valX = string(cboX.Value);
XId=find(names==valX);

valY = string(cboY.Value);
YId=find(names==valY);

UpdateData(ax,p,XId,YId,h);

end
