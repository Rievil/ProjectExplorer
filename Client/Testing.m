%% Start with GUI
clear all;
%%
b=ExplorerAppStartMain;
% clear all;
%% Without gui
c=ExplorerObj(0);
%%
stash=Pack(b.Core.ProjectOverview);
%% Plotter test
plotter=b.Core.ProjectOverview.Projects(1).Plotter;

% plotter.DrawTest;
%% Události - histogram energie
fig=figure('position',[20 200 1600 600]);
popis={200,240,360};
for i=1:3
    Tout=plotter.GetSampleData(3,i);
    subplot(1,3,i);

    hold on;
    grid on;
    xall=[];
    
    for j=1:size(Tout,1)
        x1=Tout.ZedoTime_Zedocas{j};
        % y1=Tout{1,7};
        y1=Tout.Energy_Energie{j};

%         histogram(x1,10,'DisplayName',Tout.Key(j));
    %     scatter(x1,y1);
        xall=[xall; y1];
    end
    
    histfit(xall,10);
    
    if i==1
        ylabel('Počet událostí [-]');
    end
    
    xlabel('Energie [V]');
    xlim([0 5e+4]);
    ylim([0 300]);
    legend;
    title(sprintf('Vzdalenost %d mm',popis{i}));
end

%% Události - histogram pozice
fig=figure('position',[20 200 900 400]);
popis={200,240,360};
n=0;

zesileni=[15,25,35];
% for k=1:3
a=(380-360)/2;
col=lines(3);
xbin=0:10:380;
for i=1:3
    n=n+1;
    Tout=plotter.GetSampleData(3,i);

    xall0=[];
    xall1=[];
    xall2=[];

    for j=1:size(Tout,1)
        xall0=[xall0; Tout.LokalHitD0_x{j}];
        xall1=[xall0; Tout.LokalHitD1_x{j}];
        xall2=[xall0; Tout.LokalHitD2_x{j}];
    end
    subplot(1,3,i);
    hold on;
    grid on;

    [count0,cent0] = hist(xall0);
    plot(cent0,count0,'-o','DisplayName',sprintf('Amp. %d dB',zesileni(1)),'Color',col(1,:),'MarkerFaceColor',col(1,:));
    
    [count1,cent1] = hist(xall1);
    plot(cent1,count1,'-o','DisplayName',sprintf('Amp. %d dB',zesileni(2)),'Color',col(2,:),'MarkerFaceColor',col(2,:));
    
    [count2,cent2] = hist(xall2);
    plot(cent2,count2,'-o','DisplayName',sprintf('Amp. %d dB',zesileni(3)),'Color',col(3,:),'MarkerFaceColor',col(3,:));
%     histogram(xall2);
%     xlim([a,380/2+360/2]);
    
    xlabel('Pozice [mm]');
    if i==1
        ylabel('Počet událostí [-]');
    end
    
    xlim([a,380/2+360/2]);
    ylim([0 350]);
    
    title(sprintf('Vzdalenost %d mm',popis{i}));
end
legend;

%% Lis
Tout=plotter.GetSampleData(3,1);

fig=figure;
hold on;

for i=1:size(Tout,1)
    x1=Tout.PressTime_Caslisu{i};
    % y1=Tout{1,7};
    y1=Tout.PressForce_Liscas{i};
    
    x2=Tout.CumZedoTime_Zedocumtime{i};
    x2=x2-x2(1);
    y2=cumsum(Tout.CemZedoHit_Zedocumcount{i});
    if i==1
        plot(x1,y1,'-k','DisplayName',sprintf('Lis: %s',Tout.Key(i)));
        yyaxis right;
        plot(x2,y2,'-r','DisplayName',sprintf('Zedo: %s',Tout.Key(i)));
    else
        yyaxis left;
        plot(x1,y1,'-k','HandleVisibility','off');
        yyaxis right;
        plot(x2,y2,'-r','HandleVisibility','off');
    end
end
legend;
% xlim([0 380]);
%%
results = GetCurrentData(pr);
%%
d = categorical(listfonts);
%%
T=pr.PR.Projects.TotalTable.Zedo(1,1).Data.Records(1).ConDetector;
x=T{:,4};
y=T{:,9};
z=T{:,10};
arr=[x,y,z];
%%
E=results(1).Type.Data.Events;
x=E{:,16};

Time=E{:,7};
PTime=results(2).Type.Data.Time;
y=interp1(results(2).Type.Data.Time,results(2).Type.Data.Strength,Time);
z=E{:,13};
size=log(E{:,11}*10e+17);
color=E{:,13};
scatter3(x,y,z,size,color,'filled');
arr=[x,y,z,size];
%%
figure(1);
hold on;
s=E{:,11}*10e+14;

scatter3(x,y,z,s,'filled');
%%
load('D:\Data\OneDrive\Dizertační práce\Dizertační práce\Programy\Concrete.mat');
%%
Signals=table;
for i=1:9
    TMP=Concrete(2).IE(1).signal(1).odezva{1, i};
    Signals=[Signals; table(linspace(i,i,numel(TMP))',TMP,'VariableNames',{'ID','Data'})];
end

conn = database('ProjectExplorerDB','ProjectExplorerClient','18@25_LL35_!QR');
sqlwrite(conn,'Signals',Signals);
close(conn);


%%
files=dir('H:\Google drive\Škola\Měření\2020\Hex v krabici');
files([1 2])=[];
data=table;
for i=1:5
    img=imread([files(i).folder '\' files(i).name]);
    data=[data; table(i,{img},'VariableNames',{'ID','Data'})];
end
%%
conn = database('ProjectExplorerDB','ProjectExplorerClient','18@25_LL35_!QR');
sqlwrite(conn,'Images',data);
close(conn);
%%
test=table(i,{img},'VariableNames',{'ID','Data'});
%% Connection to database

conn = database('Project2','ProjectExplorerClient','18@25_LL35_!QR');

selectquery = 'SELECT * FROM Signals WHERE Signals.ID=6';

data = select(conn,selectquery);
close(conn);

figure(1);
hold on;
unqID=unique(data.ID)';
for ID=unqID
    signal=data.Data(data.ID==ID,:);
    plot(signal);
end
%%
conn = database('Project2','ProjectExplorerClient','18@25_LL35_!QR');

selectquery = 'SELECT Signals.ID FROM Signals';

ID = select(conn,selectquery);
close(conn);

unqID=unique(ID)

%%

conn = database('ProjectExplorerDB','ProjectExplorerClient','18@25_LL35_!QR');

rows = sqlread(conn,'Pictures');

close(conn);
%%

plot(rows.PictureData{1,1}  );
%%
RGB2 = im2uint8(data.Data{1,1}  );
%%
B = reshape(data.Data{1,1},1,[]);
%%
tst=TestObj;
%%
Save(tst);
%%
Load(tst);
%%
[keys,vals] = getenvall();
T=table(keys,vals);
%
%%

T1=struct('Val',double(1));
T2=struct('Val',double(4));
T3=struct('S',[T1, T2]);

T4=struct('S2',[T3, T3]);
%%
mystruct=T4;
fn = fieldnames(mystruct);
for k=1:numel(fn)
    if( isnumeric(mystruct.(fn{k})) )
        % do stuff
    end
end
%%
AEbox=struct;
AEbox.box='ZedoBox';
AEbox.card(1).name='Card 1';
AEbox.card(1).channel(1).name='Channel 1';
AEbox.card(1).channel(2).name='Channel 2';
%%
txt = jsonencode(AEbox);
%%
data=b.Core.ProjectOverview.Projects(1, 1).Experiments.SpecGroup.Specimens.Data{1,1};
save('TestVar.mat','data');
%%
load('TestVar.mat');
%%
IntObj = OPInter;

figure;
hold on;

%-----načtení z adresy
x1=data(3).data.Records(1).Detector(1).Data{:,4};
y1=data(3).data.Records(1).Detector(1).Data{:,17};
c1=data(3).data.Records(1).Detector(1).Data{:,12};

s1=data(3).data.Records(1).Detector(1).Data{:,11};

x2=data(2).data.Time;

y2=data(2).data.Defformation;
y2b=data(2).data.Force;

%-----matematické operace
c1=c1-min(c1);

c1=c1+2;
c1=c1.^4;


%----konverze datových typů
x2=IntObj.ConvertToNum(x2);

%---- interpolace dat
IntObj.SetMainX(x1);
IntObj.SetSupX(x2);
IntObj.SetSupY(y2);
IntObj.SelectType(2);
newy1=IntObj.MainY;

%---- vykreslení proměnných
plot(y2,y2b,'-','DisplayName','Press','Color',[0.2 0.5 0.7]);
scatter(newy1,y1,c1,'filled','DisplayName','AE','MarkerFaceColor',[0.2 0.5 0.7]);

%----vykreslení legendy
legend;

%----formátování os
xlabel('Defformation');
ylabel('Counts');



legend;
%% Image in ui table
fig=figure;
hold on;
grid off;

ax=gca;
x=0:0.1:pi()*2;
y=sin(x);
plot(x,y,'k','LineWidth',8);
xlim([0 x(end)]);
xlabel('x axis');
ylabel('y axis');

set(ax,'TickDir','out','FontSize',29,'LineWidth',8,'FontName','Arial');
set(fig,'Renderer','painters');
print(fig,'C:\Users\Richard\OneDrive - Vysoké učení technické v Brně\Dokumenty\Github\ProjectExplorer\Master\GUI\Icons\FigureConcept','-dsvg');