%% Start with GUI
clear all;
%%
b=ExplorerAppStartMain;
% clear all;
%%
stash=Pack(b.Core.ProjectOverview);
%%
result=Pack(b);
%%
results = GetCurrentData(pr);
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
