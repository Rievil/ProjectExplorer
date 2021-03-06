
%% Testing of categorical arrays and their sorting
pr=ProjectExplorer;
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
load('D:\Data\OneDrive\Dizerta�n� pr�ce\Dizerta�n� pr�ce\Programy\Concrete.mat');
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
files=dir('H:\Google drive\�kola\M��en�\2020\Hex v krabici');
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